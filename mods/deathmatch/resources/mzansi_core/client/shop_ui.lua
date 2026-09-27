Mzansi = Mzansi or {}
Mzansi.ShopUI = Mzansi.ShopUI or {}
Mzansi.ShopUI._visible = false
Mzansi.ShopUI._shopType = nil
Mzansi.ShopUI._catalog = nil
Mzansi.ShopUI._anim = 0
Mzansi.ShopUI._scroll = 0
Mzansi.ShopUI._selected = 1
Mzansi.ShopUI._prompt = nil  -- { label, value, onSubmit }

local FONT_TITLE = "default-bold"
local FONT_BODY = "default"
local FONT_SMALL = "default-small"

local TABS_WEAPONS = { "Pistols", "SMGs", "Rifles", "Shotguns", "Ammo" }
local TABS_CLOTHING = { "Outfits" }

local WEAPON_CATEGORIES = {
    Pistols = { 22, 23, 24 },
    SMGs = { 28, 29, 32 },
    Rifles = { 30, 31, 33, 34 },
    Shotguns = { 25, 26, 27 },
}

local function screen()
    return guiGetScreenSize()
end

local function isMouseIn(mx, my, x, y, w, h)
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

local function closeOthers()
    triggerEvent("mzansi:phone:close", localPlayer)
    triggerEvent("mzansi:radio:close", localPlayer)
    triggerEvent("mzansi:freeroam:close", localPlayer)
    triggerEvent("mzansi:admin:close", localPlayer)
    triggerEvent("mzansi:dashboard:close", localPlayer)
    triggerEvent("mzansi:flight:close", localPlayer)
    triggerEvent("mzansi:market:close", localPlayer)
    triggerEvent("mzansi:bank:close", localPlayer)
end

function Mzansi.ShopUI.open(shopType)
    if Mzansi.Cutscene and Mzansi.Cutscene.isPlaying() then return end
    if isChatBoxInputActive() or isConsoleActive() then return end
    if Mzansi.ShopUI._visible then return end
    closeOthers()
    Mzansi.ShopUI._shopType = shopType or "weapons"
    Mzansi.ShopUI._visible = true
    Mzansi.ShopUI._anim = 0
    Mzansi.ShopUI._scroll = 0
    Mzansi.ShopUI._selected = 1
    showCursor(true)
    playSoundFrontEnd(41)
    triggerServerEvent("mzansi:shop:requestCatalog", localPlayer, Mzansi.ShopUI._shopType)
end

function Mzansi.ShopUI.close()
    if not Mzansi.ShopUI._visible then return end
    Mzansi.ShopUI._visible = false
    Mzansi.ShopUI._anim = 0
    Mzansi.ShopUI._prompt = nil
    showCursor(false)
    playSoundFrontEnd(42)
end

function Mzansi.ShopUI.toggle(shopType)
    if Mzansi.ShopUI._visible then
        Mzansi.ShopUI.close()
    else
        Mzansi.ShopUI.open(shopType)
    end
end

-- ==============================================================
-- PROMPT MODAL (for ammo quantity)
-- ==============================================================
function Mzansi.ShopUI.showPrompt(label, default, onSubmit)
    Mzansi.ShopUI._prompt = { label = label, value = tostring(default or ""), onSubmit = onSubmit }
end

-- ==============================================================
-- EVENTS
-- ==============================================================
addEvent("mzansi:shop:openUI", true)
addEventHandler("mzansi:shop:openUI", root, function(shopType)
    Mzansi.ShopUI.open(shopType)
end)

addEvent("mzansi:shop:closeUI", true)
addEventHandler("mzansi:shop:closeUI", root, function()
    Mzansi.ShopUI.close()
end)

addEvent("mzansi:shop:setCatalog", true)
addEventHandler("mzansi:shop:setCatalog", root, function(cat)
    if type(cat) == "table" then
        Mzansi.ShopUI._catalog = cat
    end
end)

-- ==============================================================
-- KEYBINDS
-- ==============================================================
bindKey("x", "down", function()
    if Mzansi.ShopUI._visible then
        Mzansi.ShopUI.close()
    end
end)

addCommandHandler("shopui", function()
    Mzansi.ShopUI.toggle("weapons")
end)

addCommandHandler("buyguns", function()
    triggerServerEvent("mzansi:shop:openWeapons", localPlayer, nil)
end)

addCommandHandler("clothes", function()
    triggerServerEvent("mzansi:shop:openClothing", localPlayer, nil)
end)

-- ==============================================================
-- GET CURRENT LIST
-- ==============================================================
local function currentList()
    local cat = Mzansi.ShopUI._catalog
    if not cat then return {} end
    if Mzansi.ShopUI._shopType == "weapons" then
        return cat.weapons or {}
    else
        return cat.clothing or {}
    end
end

-- ==============================================================
-- RENDER
-- ==============================================================
addEventHandler("onClientRender", root, function()
    if not Mzansi.ShopUI._visible then return end

    local sx, sy = screen()
    local w, h = 780, 520
    local x = (sx - w) / 2
    local y = (sy - h) / 2
    Mzansi.ShopUI._anim = math.min(1, Mzansi.ShopUI._anim + 0.08)

    -- Backdrop
    dxDrawRectangle(0, 0, sx, sy, tocolor(5, 10, 18, 150), false)
    dxDrawRectangle(x, y, w, h, tocolor(10, 18, 30, 250), false)

    local isWeapons = Mzansi.ShopUI._shopType == "weapons"
    local accent = isWeapons and tocolor(200, 80, 50, 255) or tocolor(200, 170, 50, 255)

    dxDrawRectangle(x, y, w, 3, accent, false)
    dxDrawRectangle(x, y, w, 50, tocolor(15, 26, 44, 255), false)

    local title = isWeapons and "AMMU-NATION" or "CLOTHING STORE"
    dxDrawText(title, x + 25, y, x + w - 160, y + 50, accent, 1.1, FONT_TITLE, "left", "center")
    dxDrawText("[X to Close]", x + w - 150, y, x + w - 25, y + 50, tocolor(150, 170, 190, 200), 0.9, FONT_TITLE, "right", "center")

    local cat = Mzansi.ShopUI._catalog
    if not cat then
        dxDrawText("Loading catalog...", x, y + h / 2, x + w, y + h / 2 + 20, tocolor(150, 170, 190), 1, FONT_BODY, "center", "center")
        return
    end

    -- Info bar
    local infoY = y + 55
    local info = "Cash: " .. Mzansi.Util.formatMoney(cat.cash or 0)
    if isWeapons then
        info = info .. "   |   Weapon License: " .. (cat.weaponLicense and "VALID" or "NONE")
    else
        info = info .. "   |   Current Outfit ID: " .. tostring(cat.currentSkin or 0)
    end
    dxDrawText(info, x + 25, infoY, x + w - 25, infoY + 20, tocolor(170, 200, 230, 255), 0.9, FONT_BODY, "left", "center")

    -- Tabs
    local tabs = isWeapons and TABS_WEAPONS or TABS_CLOTHING
    local tabX = x + 20
    local tabY = y + 80
    local tabW = (w - 40) / #tabs
    local activeTab = tabs[Mzansi.ShopUI._selected] or tabs[1]

    for i, tabName in ipairs(tabs) do
        local tx = tabX + (i - 1) * tabW
        local isActive = (i == Mzansi.ShopUI._selected)
        local mx, my = getCursorPosition()
        mx, my = (mx or 0) * sx, (my or 0) * sy
        local hover = isMouseIn(mx, my, tx, tabY, tabW - 4, 32)
        local bg = isActive and accent or (hover and tocolor(30, 50, 80, 255) or tocolor(20, 32, 50, 240))
        dxDrawRectangle(tx, tabY, tabW - 4, 32, bg, false)
        dxDrawText(tabName, tx, tabY, tx + tabW - 4, tabY + 32,
            isActive and tocolor(10, 10, 10, 255) or tocolor(170, 190, 210, 255),
            0.85, FONT_BODY, "center", "center")
    end

    -- Filter list by active tab
    local list = currentList()
    local filtered = {}
    if isWeapons then
        local weaponIds = WEAPON_CATEGORIES[activeTab] or {}
        if activeTab == "Ammo" then
            -- Show all owned-capable weapons for ammo
            for _, w in ipairs(list) do
                filtered[#filtered + 1] = w
            end
        else
            for _, w in ipairs(list) do
                for _, wid in ipairs(weaponIds) do
                    if w.id == wid then
                        filtered[#filtered + 1] = w
                        break
                    end
                end
            end
        end
    else
        filtered = list
    end

    -- Scroll
    local listY = tabY + 40
    local listH = h - (listY - y) - 60
    local itemH = 44
    local maxVisible = math.floor(listH / itemH)
    if Mzansi.ShopUI._scroll > #filtered - maxVisible then
        Mzansi.ShopUI._scroll = math.max(0, #filtered - maxVisible)
    end

    -- Draw items
    local mx, my = getCursorPosition()
    mx, my = (mx or 0) * sx, (my or 0) * sy

    for i = 1, maxVisible do
        local idx = Mzansi.ShopUI._scroll + i
        if idx > #filtered then break end
        local item = filtered[idx]
        local iy = listY + (i - 1) * itemH
        local isSelected = (idx == Mzansi.ShopUI._selected)
        local hover = isMouseIn(mx, my, x + 20, iy, w - 40, itemH - 4)

        local rowBg = isSelected and tocolor(30, 50, 80, 255) or (hover and tocolor(25, 42, 68, 255) or tocolor(18, 30, 48, 255))
        dxDrawRectangle(x + 20, iy, w - 40, itemH - 4, rowBg, false)

        if isWeapons then
            local canBuy = (not item.license) or cat.weaponLicense
            local priceColor = canBuy and tocolor(255, 215, 0, 255) or tocolor(200, 80, 80, 255)
            dxDrawText(item.name, x + 35, iy + 4, x + w - 250, iy + 22, tocolor(220, 230, 240, 255), 0.95, FONT_BODY, "left", "top")
            dxDrawText("Ammo: R" .. tostring(item.ammoPrice) .. "/rd", x + 35, iy + 22, x + w - 250, iy + 38,
                tocolor(130, 150, 170, 255), 0.75, FONT_SMALL, "left", "top")
            if item.license and not cat.weaponLicense then
                dxDrawText("LICENSE REQUIRED", x + w - 380, iy + 8, x + w - 160, iy + 30,
                    tocolor(200, 80, 80, 255), 0.8, FONT_SMALL, "center", "top")
            end
            dxDrawText(Mzansi.Util.formatMoney(item.price), x + w - 240, iy + 8, x + w - 160, iy + 30,
                priceColor, 0.95, FONT_BODY, "right", "top")

            -- BUY button
            local btnHover = isMouseIn(mx, my, x + w - 145, iy + 6, 70, 28)
            local canAfford = (cat.cash or 0) >= item.price
            local btnBg = (canBuy and canAfford) and (btnHover and tocolor(50, 160, 70, 255) or tocolor(40, 130, 55, 255))
                or (btnHover and tocolor(120, 60, 50, 255) or tocolor(90, 50, 45, 255))
            dxDrawRectangle(x + w - 145, iy + 6, 70, 28, btnBg, false)
            dxDrawText("BUY", x + w - 145, iy + 6, x + w - 75, iy + 34, tocolor(255, 255, 255, 255), 0.8, FONT_BODY, "center", "center")

            -- +AMMO button
            local ammoHover = isMouseIn(mx, my, x + w - 70, iy + 6, 55, 28)
            dxDrawRectangle(x + w - 70, iy + 6, 55, 28, ammoHover and tocolor(50, 100, 160, 255) or tocolor(40, 80, 130, 255), false)
            dxDrawText("+AMMO", x + w - 70, iy + 6, x + w - 15, iy + 34, tocolor(255, 255, 255, 255), 0.7, FONT_SMALL, "center", "center")
        else
            -- Clothing row
            local isOwned = item.owned
            dxDrawText(item.name, x + 35, iy + 4, x + w - 250, iy + 22, tocolor(220, 230, 240, 255), 0.95, FONT_BODY, "left", "top")
            dxDrawText("Skin ID: " .. tostring(item.id), x + 35, iy + 22, x + w - 250, iy + 38,
                tocolor(130, 150, 170, 255), 0.75, FONT_SMALL, "left", "top")

            if isOwned then
                dxDrawText("EQUIPPED", x + w - 240, iy + 8, x + w - 160, iy + 30,
                    tocolor(80, 220, 100, 255), 0.85, FONT_BODY, "right", "top")
            else
                local priceColor = (item.price == 0) and tocolor(80, 220, 100, 255) or tocolor(255, 215, 0, 255)
                dxDrawText(item.price == 0 and "FREE" or Mzansi.Util.formatMoney(item.price),
                    x + w - 240, iy + 8, x + w - 160, iy + 30, priceColor, 0.95, FONT_BODY, "right", "top")
            end

            -- EQUIP button
            local btnHover = isMouseIn(mx, my, x + w - 145, iy + 6, 70, 28)
            local canAfford = (item.price == 0) or ((cat.cash or 0) >= item.price)
            local btnBg
            if isOwned then
                btnBg = btnHover and tocolor(60, 140, 80, 255) or tocolor(50, 120, 70, 255)
            elseif canAfford then
                btnBg = btnHover and tocolor(50, 160, 70, 255) or tocolor(40, 130, 55, 255)
            else
                btnBg = btnHover and tocolor(120, 60, 50, 255) or tocolor(90, 50, 45, 255)
            end
            dxDrawRectangle(x + w - 145, iy + 6, 70, 28, btnBg, false)
            dxDrawText(isOwned and "ON" or "BUY", x + w - 145, iy + 6, x + w - 75, iy + 34,
                tocolor(255, 255, 255, 255), 0.8, FONT_BODY, "center", "center")
        end
    end

    -- Scrollbar
    if #filtered > maxVisible then
        local sbX = x + w - 14
        local sbY = listY
        local sbH = listH
        dxDrawRectangle(sbX, sbY, 6, sbH, tocolor(20, 32, 50, 255), false)
        local thumbH = math.max(30, sbH * maxVisible / #filtered)
        local thumbY = sbY + (sbH - thumbH) * (Mzansi.ShopUI._scroll / math.max(1, #filtered - maxVisible))
        dxDrawRectangle(sbX, thumbY, 6, thumbH, accent, false)
    end

    -- Footer
    local footerY = y + h - 45
    dxDrawText("Scroll: Mouse Wheel  |  Select: Click  |  Close: X", x + 25, footerY, x + w - 25, footerY + 20,
        tocolor(120, 140, 160, 255), 0.8, FONT_SMALL, "left", "top")

    -- Prompt modal
    if Mzansi.ShopUI._prompt then
        local p = Mzansi.ShopUI._prompt
        local pw, ph = 400, 160
        local px, py = (sx - pw) / 2, (sy - ph) / 2
        dxDrawRectangle(px, py, pw, ph, tocolor(15, 26, 44, 255), false)
        dxDrawRectangle(px, py, pw, 3, accent, false)
        dxDrawText(p.label, px + 20, py + 15, px + pw - 20, py + 40, tocolor(200, 170, 50, 255), 1.0, FONT_TITLE, "left", "top")
        dxDrawRectangle(px + 20, py + 50, pw - 40, 35, tocolor(10, 18, 30, 255), false)
        dxDrawText(p.value .. "_", px + 30, py + 50, px + pw - 30, py + 85, tocolor(255, 255, 255, 255), 1.0, FONT_BODY, "left", "center")

        local okHover = isMouseIn(mx, my, px + 20, py + 100, 110, 35)
        dxDrawRectangle(px + 20, py + 100, 110, 35, okHover and tocolor(50, 160, 70, 255) or tocolor(40, 130, 55, 255), false)
        dxDrawText("CONFIRM", px + 20, py + 100, px + 130, py + 135, tocolor(255, 255, 255), 0.9, FONT_BODY, "center", "center")

        local cancelHover = isMouseIn(mx, my, px + 145, py + 100, 110, 35)
        dxDrawRectangle(px + 145, py + 100, 110, 35, cancelHover and tocolor(160, 60, 50, 255) or tocolor(130, 50, 45, 255), false)
        dxDrawText("CANCEL", px + 145, py + 100, px + 255, py + 135, tocolor(255, 255, 255), 0.9, FONT_BODY, "center", "center")
    end
end)

-- ==============================================================
-- CLICK HANDLER
-- ==============================================================
addEventHandler("onClientClick", root, function(button, state, mx, my)
    if button ~= "left" or state ~= "down" then return end
    if not Mzansi.ShopUI._visible then return end

    local sx, sy = screen()
    local w, h = 780, 520
    local x = (sx - w) / 2
    local y = (sy - h) / 2
    local cat = Mzansi.ShopUI._catalog
    if not cat then return end

    local isWeapons = Mzansi.ShopUI._shopType == "weapons"
    local accent = isWeapons and tocolor(200, 80, 50, 255) or tocolor(200, 170, 50, 255)

    -- Prompt modal clicks
    if Mzansi.ShopUI._prompt then
        local p = Mzansi.ShopUI._prompt
        local pw, ph = 400, 160
        local px, py = (sx - pw) / 2, (sy - ph) / 2

        if isMouseIn(mx, my, px + 20, py + 100, 110, 35) then
            local val = tonumber(p.value)
            if val and val > 0 then
                p.onSubmit(val)
            end
            Mzansi.ShopUI._prompt = nil
            return
        elseif isMouseIn(mx, my, px + 145, py + 100, 110, 35) then
            Mzansi.ShopUI._prompt = nil
            return
        elseif isMouseIn(mx, my, px + 20, py + 50, pw - 40, 35) then
            -- Click on input field - keyboard handled in onClientKey
            return
        end
        -- Block clicks behind modal
        return
    end

    -- Tab clicks
    local tabs = isWeapons and TABS_WEAPONS or TABS_CLOTHING
    local tabX = x + 20
    local tabY = y + 80
    local tabW = (w - 40) / #tabs
    for i, _ in ipairs(tabs) do
        local tx = tabX + (i - 1) * tabW
        if isMouseIn(mx, my, tx, tabY, tabW - 4, 32) then
            Mzansi.ShopUI._selected = i
            Mzansi.ShopUI._scroll = 0
            playSoundFrontEnd(41)
            return
        end
    end

    -- Item clicks
    local list = currentList()
    local activeTab = tabs[Mzansi.ShopUI._selected] or tabs[1]
    local filtered = {}
    if isWeapons then
        local weaponIds = WEAPON_CATEGORIES[activeTab] or {}
        if activeTab == "Ammo" then
            filtered = list
        else
            for _, w in ipairs(list) do
                for _, wid in ipairs(weaponIds) do
                    if w.id == wid then
                        filtered[#filtered + 1] = w
                        break
                    end
                end
            end
        end
    else
        filtered = list
    end

    local listY = tabY + 40
    local itemH = 44

    for i = 1, 15 do
        local idx = Mzansi.ShopUI._scroll + i
        if idx > #filtered then break end
        local item = filtered[idx]
        local iy = listY + (i - 1) * itemH

        if isWeapons then
            -- BUY weapon
            if isMouseIn(mx, my, x + w - 145, iy + 6, 70, 28) then
                Mzansi.ShopUI._selected = idx
                local canBuy = (not item.license) or cat.weaponLicense
                if not canBuy then
                    Mzansi.Util.sendNotification(localPlayer, "You need a weapon license.", "error")
                    return
                end
                if (cat.cash or 0) < item.price then
                    Mzansi.Util.sendNotification(localPlayer, "Not enough cash.", "error")
                    return
                end
                triggerServerEvent("mzansi:shop:buyWeapon", localPlayer, item.id, 50)
                return
            end
            -- +AMMO button
            if isMouseIn(mx, my, x + w - 70, iy + 6, 55, 28) then
                Mzansi.ShopUI._selected = idx
                Mzansi.ShopUI.showPrompt("Ammo quantity for " .. item.name .. " (R" .. item.ammoPrice .. "/rd):", 50, function(qty)
                    triggerServerEvent("mzansi:shop:buyAmmo", localPlayer, item.id, qty)
                end)
                return
            end
        else
            -- BUY/EQUIP clothing
            if isMouseIn(mx, my, x + w - 145, iy + 6, 70, 28) then
                Mzansi.ShopUI._selected = idx
                if item.owned then
                    Mzansi.Util.sendNotification(localPlayer, "Already equipped.", "info")
                    return
                end
                if item.price > 0 and (cat.cash or 0) < item.price then
                    Mzansi.Util.sendNotification(localPlayer, "Not enough cash.", "error")
                    return
                end
                triggerServerEvent("mzansi:shop:buySkin", localPlayer, item.id)
                return
            end
        end
    end
end)

-- ==============================================================
-- KEYBOARD INPUT FOR PROMPT
-- ==============================================================
addEventHandler("onClientKey", root, function(button, pressed)
    if not Mzansi.ShopUI._visible or not Mzansi.ShopUI._prompt then return end
    if not pressed then return end

    local p = Mzansi.ShopUI._prompt
    if button == "backspace" then
        p.value = string.sub(p.value, 1, -2)
        cancelEvent()
    elseif button == "enter" then
        local val = tonumber(p.value)
        if val and val > 0 then
            p.onSubmit(val)
        end
        Mzansi.ShopUI._prompt = nil
        cancelEvent()
    elseif button == "escape" then
        Mzansi.ShopUI._prompt = nil
        cancelEvent()
    elseif #button == 1 then
        local ch = button
        if ch:match("%d") then
            p.value = p.value .. ch
            cancelEvent()
        end
    end
end)

-- Mouse wheel scroll (MTA has no onClientMouseWheel — use onClientKey)
addEventHandler("onClientKey", root, function(button, pressed)
    if not Mzansi.ShopUI._visible or Mzansi.ShopUI._prompt then return end
    if not pressed then return end
    if button == "mouse_wheel_up" then
        Mzansi.ShopUI._scroll = math.max(0, Mzansi.ShopUI._scroll - 1)
        cancelEvent()
    elseif button == "mouse_wheel_down" then
        Mzansi.ShopUI._scroll = Mzansi.ShopUI._scroll + 1
        cancelEvent()
    end
end)
