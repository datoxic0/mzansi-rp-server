Mzansi = Mzansi or {}
Mzansi.ShopSystem = Mzansi.ShopSystem or {}

addEvent("mzansi:shop:openWeapons", true)
addEvent("mzansi:shop:openClothing", true)
addEvent("mzansi:shop:buyWeapon", true)
addEvent("mzansi:shop:buyAmmo", true)
addEvent("mzansi:shop:buySkin", true)
addEvent("mzansi:shop:requestCatalog", true)

local function money(amount)
    return Mzansi.Util.formatMoney(amount)
end

local function playerName(char)
    local n = (char.firstName or char.first_name or "Citizen") .. " " .. (char.lastName or char.last_name or "")
    return string.gsub(n, "%s+$", "")
end

-- ==============================================================
-- DISTANCE VALIDATION
-- ==============================================================
local function validateDistance(player, loc, maxDist)
    if not loc then return false end
    local px, py, pz = getElementPosition(player)
    local dist = Mzansi.Util.distance(px, py, pz, loc.x, loc.y, loc.z)
    if dist > (maxDist or 15) then
        Mzansi.Util.sendNotification(player, "You are too far from the shop.", "error")
        return false
    end
    return true
end

-- ==============================================================
-- WEAPON PURCHASE
-- ==============================================================
function Mzansi.ShopSystem.buyWeapon(player, weaponId, ammoCount)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    weaponId = tonumber(weaponId)
    if not weaponId then
        Mzansi.Util.sendNotification(player, "Invalid weapon.", "error")
        return false
    end

    local weaponCfg = Mzansi.Config.Weapons[weaponId]
    if not weaponCfg then
        Mzansi.Util.sendNotification(player, "This weapon is not sold at Ammu-Nation.", "error")
        return false
    end

    -- License check
    if weaponCfg.license and not char.weaponLicense then
        Mzansi.Util.sendNotification(player, "You need a weapon license. Visit the DMV or City Hall.", "error")
        return false
    end

    -- Cash check
    if char.cash < weaponCfg.price then
        Mzansi.Util.sendNotification(player, "Not enough cash. Need " .. money(weaponCfg.price), "error")
        return false
    end

    ammoCount = tonumber(ammoCount) or 50
    if ammoCount < 1 then ammoCount = 1 end
    if ammoCount > 500 then ammoCount = 500 end

    -- Deduct cash
    Mzansi.Characters.removeCash(player, weaponCfg.price)

    -- Give weapon
    giveWeapon(player, weaponId, ammoCount, true)

    -- Audit
    Mzansi.Database.logAction("SHOP", char.id, playerName(char), "Bought weapon",
        weaponCfg.name .. " x" .. ammoCount .. " ammo for " .. money(weaponCfg.price), getPlayerIP(player))

    Mzansi.Util.sendNotification(player, "Purchased " .. weaponCfg.name .. " with " .. ammoCount .. " rounds for " .. money(weaponCfg.price), "success")
    playSoundFrontEnd(player, 41)
    return true
end

-- ==============================================================
-- AMMO PURCHASE
-- ==============================================================
function Mzansi.ShopSystem.buyAmmo(player, weaponId, ammoCount)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    weaponId = tonumber(weaponId)
    ammoCount = tonumber(ammoCount) or 50
    if ammoCount < 1 then ammoCount = 1 end
    if ammoCount > 500 then ammoCount = 500 end

    local ammoPrice = Mzansi.Shops.AmmoPrices[weaponId]
    if not ammoPrice then
        Mzansi.Util.sendNotification(player, "Ammo not available for this weapon.", "error")
        return false
    end

    -- Player must own the weapon (has ammo for it)
    local hasWeapon = getPedWeapon(player, 0) -- check primary
    -- MTA: check all slots
    local owns = false
    for slot = 0, 12 do
        if getPedWeapon(player, slot) == weaponId then
            owns = true
            break
        end
    end
    if not owns then
        Mzansi.Util.sendNotification(player, "You don't own this weapon. Buy it first.", "error")
        return false
    end

    local totalCost = ammoPrice * ammoCount
    if char.cash < totalCost then
        Mzansi.Util.sendNotification(player, "Not enough cash. Need " .. money(totalCost), "error")
        return false
    end

    Mzansi.Characters.removeCash(player, totalCost)
    giveWeapon(player, weaponId, ammoCount, false)

    Mzansi.Database.logAction("SHOP", char.id, playerName(char), "Bought ammo",
        "Weapon " .. weaponId .. " x" .. ammoCount .. " for " .. money(totalCost), getPlayerIP(player))

    Mzansi.Util.sendNotification(player, "Bought " .. ammoCount .. " rounds for " .. money(totalCost), "success")
    playSoundFrontEnd(player, 41)
    return true
end

-- ==============================================================
-- SKIN / CLOTHING PURCHASE
-- ==============================================================
function Mzansi.ShopSystem.buySkin(player, skinId)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    skinId = tonumber(skinId)
    if not skinId then
        Mzansi.Util.sendNotification(player, "Invalid skin.", "error")
        return false
    end

    -- Find skin in catalog
    local gender = char.gender or 0
    local catalog = (gender == 1) and Mzansi.Shops.ClothingCatalog.female or Mzansi.Shops.ClothingCatalog.male
    local skinEntry = nil
    for _, s in ipairs(catalog) do
        if s.id == skinId then
            skinEntry = s
            break
        end
    end

    if not skinEntry then
        Mzansi.Util.sendNotification(player, "That clothing item is not available.", "error")
        return false
    end

    -- Cash check (free defaults cost 0)
    if skinEntry.price > 0 and char.cash < skinEntry.price then
        Mzansi.Util.sendNotification(player, "Not enough cash. Need " .. money(skinEntry.price), "error")
        return false
    end

    -- Deduct
    if skinEntry.price > 0 then
        Mzansi.Characters.removeCash(player, skinEntry.price)
    end

    -- Apply skin
    setElementModel(player, skinId)

    -- Persist
    char.skin = skinId
    setElementData(player, "mzansi:skin", skinId)
    Mzansi.Database.update("UPDATE mzansi_characters SET skin = ? WHERE id = ?", skinId, char.id)

    Mzansi.Database.logAction("SHOP", char.id, playerName(char), "Bought clothing",
        skinEntry.name .. " (skin " .. skinId .. ") for " .. money(skinEntry.price), getPlayerIP(player))

    Mzansi.Util.sendNotification(player, "Equipped: " .. skinEntry.name .. (skinEntry.price > 0 and (" for " .. money(skinEntry.price)) or " (free)"), "success")
    playSoundFrontEnd(player, 41)
    return true
end

-- ==============================================================
-- CATALOG REQUEST (for UI)
-- ==============================================================
local function sendCatalog(player, shopType, shopId)
    local cat = {
        shopType = shopType,
        shopId = shopId,
        cash = 0,
        weaponLicense = false,
        weapons = {},
        clothing = {},
        ammoPrices = Mzansi.Shops.AmmoPrices,
        currentSkin = 0,
    }

    local char = Mzansi.Characters.getCharacter(player)
    if char then
        cat.cash = char.cash or 0
        cat.weaponLicense = char.weaponLicense or false
        cat.currentSkin = char.skin or 0
    end

    if shopType == "weapons" then
        for id, cfg in pairs(Mzansi.Config.Weapons) do
            cat.weapons[#cat.weapons + 1] = {
                id = id,
                name = cfg.name,
                price = cfg.price,
                license = cfg.license,
                ammoPrice = Mzansi.Shops.AmmoPrices[id] or 50,
            }
        end
        table.sort(cat.weapons, function(a, b) return a.price < b.price end)
    elseif shopType == "clothing" then
        local gender = (char and char.gender) or 0
        local catalog = (gender == 1) and Mzansi.Shops.ClothingCatalog.female or Mzansi.Shops.ClothingCatalog.male
        for _, s in ipairs(catalog) do
            cat.clothing[#cat.clothing + 1] = {
                id = s.id,
                name = s.name,
                price = s.price,
                owned = (s.id == cat.currentSkin),
            }
        end
    end

    triggerClientEvent(player, "mzansi:shop:setCatalog", player, cat)
end

-- ==============================================================
-- EVENT HANDLERS
-- ==============================================================
addEventHandler("mzansi:shop:openWeapons", root, function(shopId)
    local player = client or source
    local loc = Mzansi.Shops.getAmmunationById(shopId)
    if not loc then
        -- fallback: find nearest ammunation within range
        local px, py, pz = getElementPosition(player)
        local best, bestDist = nil, 999999
        for _, l in ipairs(Mzansi.Shops.Ammunation) do
            local d = Mzansi.Util.distance(px, py, pz, l.x, l.y, l.z)
            if d < bestDist then best, bestDist = l, d end
        end
        if best and bestDist < 20 then loc = best end
    end
    if not validateDistance(player, loc, 25) then return end
    sendCatalog(player, "weapons", loc.id)
    triggerClientEvent(player, "mzansi:shop:openUI", player, "weapons")
end)

addEventHandler("mzansi:shop:openClothing", root, function(shopId)
    local player = client or source
    local loc = Mzansi.Shops.getClothingById(shopId)
    if not loc then
        local px, py, pz = getElementPosition(player)
        local best, bestDist = nil, 999999
        for _, l in ipairs(Mzansi.Shops.Clothing) do
            local d = Mzansi.Util.distance(px, py, pz, l.x, l.y, l.z)
            if d < bestDist then best, bestDist = l, d end
        end
        if best and bestDist < 20 then loc = best end
    end
    if not validateDistance(player, loc, 25) then return end
    sendCatalog(player, "clothing", loc.id)
    triggerClientEvent(player, "mzansi:shop:openUI", player, "clothing")
end)

addEventHandler("mzansi:shop:buyWeapon", root, function(weaponId, ammo)
    local player = client or source
    -- Validate distance to any ammunation
    local px, py, pz = getElementPosition(player)
    local nearShop = false
    for _, l in ipairs(Mzansi.Shops.Ammunation) do
        if Mzansi.Util.distance(px, py, pz, l.x, l.y, l.z) < 25 then
            nearShop = true
            break
        end
    end
    if not nearShop then
        Mzansi.Util.sendNotification(player, "You are not at an Ammu-Nation store.", "error")
        return
    end
    Mzansi.ShopSystem.buyWeapon(player, weaponId, ammo)
    -- Refresh catalog
    sendCatalog(player, "weapons", nil)
end)

addEventHandler("mzansi:shop:buyAmmo", root, function(weaponId, ammo)
    local player = client or source
    local px, py, pz = getElementPosition(player)
    local nearShop = false
    for _, l in ipairs(Mzansi.Shops.Ammunation) do
        if Mzansi.Util.distance(px, py, pz, l.x, l.y, l.z) < 25 then
            nearShop = true
            break
        end
    end
    if not nearShop then
        Mzansi.Util.sendNotification(player, "You are not at an Ammu-Nation store.", "error")
        return
    end
    Mzansi.ShopSystem.buyAmmo(player, weaponId, ammo)
    sendCatalog(player, "weapons", nil)
end)

addEventHandler("mzansi:shop:buySkin", root, function(skinId)
    local player = client or source
    local px, py, pz = getElementPosition(player)
    local nearShop = false
    for _, l in ipairs(Mzansi.Shops.Clothing) do
        if Mzansi.Util.distance(px, py, pz, l.x, l.y, l.z) < 25 then
            nearShop = true
            break
        end
    end
    if not nearShop then
        Mzansi.Util.sendNotification(player, "You are not at a clothing shop.", "error")
        return
    end
    Mzansi.ShopSystem.buySkin(player, skinId)
    sendCatalog(player, "clothing", nil)
end)

addEventHandler("mzansi:shop:requestCatalog", root, function(shopType)
    local player = client or source
    sendCatalog(player, shopType, nil)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Shop] Weapon + Clothing shops loaded. Ammunation: " .. #Mzansi.Shops.Ammunation .. ", Clothing: " .. #Mzansi.Shops.Clothing)
end)
