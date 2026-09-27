-- ==============================================================
-- MZANSI LIVING WORLD — INTERIORS & LIVING COMMERCIAL LIFE
-- EnEx markers, permanent staff, and armed store robbery dynamics
-- ==============================================================
MzansiLiving = MzansiLiving or {}
MzansiLiving.Interiors = {}

local _interiorStaff = {}
local _robberyCooldowns = {}
local _teleportCooldowns = {}
local TELEPORT_COOLDOWN_MS = 2000

-- Master Catalog of Key RP Interiors
local INTERIOR_HUBS = {
    IDLEWOOD_24_7 = {
        name = "Idlewood 24/7 Supermarket",
        ext = { x = 1833.54, y = -1843.38, z = 13.5 },
        int = { x = -25.88,  y = -185.86,  z = 1003.5, rot = 0, id = 17 },
        staff = {
            { model = 178, x = -27.2, y = -187.3, z = 1003.5, rot = 0, role = "cashier" },
            { model = 141, x = -23.5, y = -184.0, z = 1003.5, rot = 90, role = "shopper", anim = {"COP_AMBIENT", "Coplook_loop"} }
        }
    },
    COMMERCE_24_7 = {
        name = "Commerce 24/7 Supermarket",
        ext = { x = 1315.42, y = -900.25, z = 36.2 },
        int = { x = -30.95,  y = -89.61,   z = 1003.5, rot = 0, id = 18 },
        staff = {
            { model = 178, x = -32.5, y = -91.2, z = 1003.5, rot = 0, role = "cashier" }
        }
    },
    BURGER_SHOT = {
        name = "Burger Shot (Commerce/Marina)",
        ext = { x = 1199.80, y = -918.40, z = 43.1 },
        int = { x = 363.41,  y = -74.58,  z = 1001.5, rot = 180, id = 10 },
        staff = {
            { model = 205, x = 370.2, y = -82.4, z = 1001.5, rot = 180, role = "counter_food" },
            { model = 227, x = 376.5, y = -67.8, z = 1001.5, rot = 90,  role = "diner", anim = {"FOOD", "FF_Sit_Eat1"} }
        }
    },
    CLUCKIN_BELL = {
        name = "Cluckin' Bell (East Los Santos)",
        ext = { x = 928.60,  y = -1352.80, z = 13.3 },
        int = { x = 365.61,  y = -9.85,   z = 1001.8, rot = 180, id = 9 },
        staff = {
            { model = 167, x = 369.8, y = -4.5, z = 1001.8, rot = 180, role = "counter_food" }
        }
    },
    AMMUNATION_CENTRAL = {
        name = "Ammu-Nation Firearms (Downtown LS)",
        ext = { x = 1368.50, y = -1279.50, z = 13.5 },
        int = { x = 286.15,  y = -40.63,   z = 1001.5, rot = 90, id = 1 },
        staff = {
            { model = 179, x = 296.0, y = -38.2, z = 1001.5, rot = 90, role = "gunsmith" }
        }
    },
    CENTRAL_BANK = {
        name = "Standard Bank — Main Vault Lobby",
        ext = { x = 1460.00, y = -1025.00, z = 23.5 },
        int = { x = 389.02,  y = 173.84,   z = 1008.3, rot = 90, id = 3 },
        staff = {
            { model = 150, x = 392.2, y = 173.8, z = 1008.3, rot = 90, role = "bank_teller" }
        }
    }
}

-- Initializes all EnEx door markers and staff
function MzansiLiving.Interiors.init()
    outputDebugString("[Mzansi-LivingWorld] Spawning interior EnEx markers and staff...")

    for key, hub in pairs(INTERIOR_HUBS) do
        -- Exterior Entry Marker (Soft Yellow EnEx Cylinder)
        local extMarker = createMarker(hub.ext.x, hub.ext.y, hub.ext.z - 1.0, "cylinder", 1.8, 255, 230, 80, 150)
        setElementInterior(extMarker, 0)
        setElementDimension(extMarker, 0)
        setElementData(extMarker, "mzansi:interior:target", hub.int)
        setElementData(extMarker, "mzansi:interior:name", hub.name)

        -- Interior Exit Marker
        local intMarker = createMarker(hub.int.x, hub.int.y, hub.int.z - 1.0, "cylinder", 1.8, 255, 230, 80, 150)
        setElementInterior(intMarker, hub.int.id)
        setElementDimension(intMarker, 0)
        setElementData(intMarker, "mzansi:interior:target", { x = hub.ext.x, y = hub.ext.y, z = hub.ext.z, id = 0, rot = 0 })
        setElementData(intMarker, "mzansi:interior:name", hub.name .. " (Exit)")

        -- Spawn permanent staff inside this interior
        if hub.staff then
            for _, s in ipairs(hub.staff) do
                local ped = createPed(s.model, s.x, s.y, s.z, s.rot, false)
                if ped then
                    setElementInterior(ped, hub.int.id)
                    setElementDimension(ped, 0)
                    setElementFrozen(ped, true)
                    setElementData(ped, "mzansi:ai:interiorStaff", true)
                    setElementData(ped, "mzansi:ai:role", s.role)
                    setElementData(ped, "mzansi:ai:shopKey", key)

                    -- Default idle animation
                    if s.role == "cashier" or s.role == "counter_food" or s.role == "bank_teller" or s.role == "gunsmith" then
                        setPedAnimation(ped, "DEALER", "DEALER_IDLE", -1, true, false, false)
                    elseif s.anim then
                        setPedAnimation(ped, s.anim[1], s.anim[2], -1, true, false, false)
                    end

                    table.insert(_interiorStaff, ped)
                end
            end
        end
    end

    addEventHandler("onMarkerHit", resourceRoot, MzansiLiving.Interiors.onDoorHit)
    outputDebugString("[Mzansi-LivingWorld] ✓ " .. #_interiorStaff .. " interior personnel active!")
end

-- Teleport transition between interior and exterior
function MzansiLiving.Interiors.onDoorHit(hitElement, matchingDimension)
    if not matchingDimension or getElementType(hitElement) ~= "player" then return end
    local target = getElementData(source, "mzansi:interior:target")
    if not target then return end

    -- Cooldown guard: prevent teleport loop when landing on exit marker
    local pSerial = getPlayerSerial(hitElement)
    local now = getTickCount()
    if _teleportCooldowns[pSerial] and (now - _teleportCooldowns[pSerial]) < TELEPORT_COOLDOWN_MS then
        return
    end
    _teleportCooldowns[pSerial] = now

    fadeCamera(hitElement, false, 0.3, 0, 0, 0)
    setElementFrozen(hitElement, true)

    setTimer(function()
        if isElement(hitElement) then
            setElementInterior(hitElement, target.id or 0)
            setElementDimension(hitElement, 0)
            setElementPosition(hitElement, target.x, target.y, target.z)
            if target.rot then setPedRotation(hitElement, target.rot) end

            -- Reset cooldown after arrival so player can use door again later
            setTimer(function()
                if isElement(hitElement) then
                    fadeCamera(hitElement, true, 0.3)
                    setElementFrozen(hitElement, false)
                    _teleportCooldowns[getPlayerSerial(hitElement)] = nil
                end
            end, 300, 1)
        end
    end, 350, 1)
end

-- Armed Store Robbery Initiation (Triggered from Client)
addEvent("mzansi:living:startCashierHoldup", true)
addEventHandler("mzansi:living:startCashierHoldup", root, function(cashierPed)
    local player = client or source
    if not isElement(player) or not isElement(cashierPed) then return end

    local role = getElementData(cashierPed, "mzansi:ai:role")
    if role ~= "cashier" then return end

    local shopKey = getElementData(cashierPed, "mzansi:ai:shopKey") or "STORE"
    local now = getRealTime().timestamp

    -- Check cooldown
    if _robberyCooldowns[shopKey] and (now - _robberyCooldowns[shopKey]) < MzansiLiving.Config.Robbery.COOLDOWN_PER_SHOP then
        if Mzansi and Mzansi.Util then
            Mzansi.Util.sendNotification(player, "The till is empty! This store was recently robbed.", "warning")
        end
        return
    end

    _robberyCooldowns[shopKey] = now

    -- Cashier screams and puts hands up
    setPedAnimation(cashierPed, "SHOP", "SHP_Rob_HandsUp", -1, false, false, false)
    if Mzansi and Mzansi.Util then
        Mzansi.Util.sendNotification(player, "Cashier: 'Aweh! Don't shoot! I'm opening the till!' Hold aim for 5s!", "warning")
    end

    -- 5-second countdown to drop cash and alert police
    setTimer(function()
        if isElement(player) and isElement(cashierPed) and not isPedDead(player) then
            -- Cash drop
            local px, py, pz = getElementPosition(cashierPed)
            local cashAmount = math.random(MzansiLiving.Config.Robbery.MIN_CASH, MzansiLiving.Config.Robbery.MAX_CASH)
            
            if Mzansi and Mzansi.Characters and Mzansi.Characters.addCash then
                Mzansi.Characters.addCash(player, cashAmount)
                Mzansi.Characters.addXP(player, 50)
            end

            if Mzansi and Mzansi.Util then
                Mzansi.Util.sendNotification(player, "ROBBERY SUCCESSFUL! You grabbed R " .. Mzansi.Util.formatMoney(cashAmount) .. "! SAPS has been alerted!", "success")
            end

            -- Broadcast SAPS 911 Alert
            local allPlayers = getElementsByType("player")
            for _, cop in ipairs(allPlayers) do
                local faction = getElementData(cop, "mzansi:faction")
                if faction == 1 or faction == "SAPS" then
                    if Mzansi and Mzansi.Util then
                        Mzansi.Util.sendNotification(cop, "[911 DISPATCH] ARMED ROBBERY IN PROGRESS at " .. shopKey .. "! Suspect armed and dangerous!", "error")
                    end
                end
            end

            -- Reset cashier to cower
            setPedAnimation(cashierPed, "ped", "cower", -1, true, false, false)
            setTimer(function()
                if isElement(cashierPed) then
                    setPedAnimation(cashierPed, "DEALER", "DEALER_IDLE", -1, true, false, false)
                end
            end, 20000, 1)
        end
    end, MzansiLiving.Config.Robbery.HOLDUP_TIME, 1)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    MzansiLiving.Interiors.init()
end)

addEventHandler("onResourceStop", resourceRoot, function()
    for _, ped in ipairs(_interiorStaff) do
        if isElement(ped) then destroyElement(ped) end
    end
    _interiorStaff = {}
end)
