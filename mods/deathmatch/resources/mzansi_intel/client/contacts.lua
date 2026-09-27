-- ============================================================
-- MZANSI INTEL: CLIENT CONTACTS
-- Live aircraft / vessel / heli roster near localPlayer
-- ============================================================

Mzansi = Mzansi or {}
Mzansi.Intel = Mzansi.Intel or {}

local contacts = {}       -- array of contact DTOs
local trackedId = nil     -- element id being tracked
local trail = {}          -- trail positions for tracked element
local intelActive = false
local scanTimer = nil

local function classify(vehicle)
    local model = getElementModel(vehicle)
    local cfg = Mzansi.Intel.Config
    if cfg.planeModels[model] then return "aircraft", cfg.planeModels[model] end
    if cfg.heliModels[model] then return "rotor", cfg.heliModels[model] end
    if cfg.boatModels[model] then return "vessel", cfg.boatModels[model] end
    local typ = getElementType(vehicle)
    if typ == "vehicle" then return "ground", getVehicleName(vehicle) end
    return "unknown", "?"
end

local function scanContacts()
    if not isElement(localPlayer) then return end
    local px, py, pz = getElementPosition(localPlayer)
    local radius = Mzansi.Intel.Config.contactRadius
    local found = {}

    for _, veh in ipairs(getElementsByType("vehicle")) do
        if #found >= Mzansi.Intel.Config.maxContacts then break end
        if isElementStreamedIn(veh) then
            local x, y, z = getElementPosition(veh)
            local dist = getDistanceBetweenPoints3D(px, py, pz, x, y, z)
            if dist <= radius then
                local kind, label = classify(veh)
                local vx, vy, vz = getElementVelocity(veh)
                local speed = math.floor(math.sqrt(vx * vx + vy * vy + vz * vz) * 180)
                local occupants = getVehicleOccupants(veh)
                local driverName = ""
                if occupants and occupants[0] then
                    driverName = getPlayerName(occupants[0]) or ""
                end
                table.insert(found, {
                    id = veh,
                    kind = kind,
                    label = label,
                    model = getElementModel(veh),
                    x = x, y = y, z = z,
                    dist = math.floor(dist),
                    speed = speed,
                    driver = driverName,
                    health = math.floor(getElementHealth(veh)),
                })
            end
        end
    end

    -- sort by distance
    table.sort(found, function(a, b) return a.dist < b.dist end)
    contacts = found
end

function getContacts()
    return contacts
end

function Mzansi.Intel.isActive()
    return intelActive
end

function Mzansi.Intel.getTracked()
    return trackedId
end

function Mzansi.Intel.setTracked(elem)
    trackedId = elem
    trail = {}
end

function Mzansi.Intel.getTrail()
    return trail
end

function Mzansi.Intel.pushTrail(x, y, z)
    if not Mzansi.Intel.Config.showTrail then return end
    table.insert(trail, { x, y, z })
    if #trail > 60 then
        table.remove(trail, 1)
    end
end

function Mzansi.Intel.setActive(state)
    intelActive = state
    if state then
        scanContacts()
        if isTimer(scanTimer) then killTimer(scanTimer) end
        scanTimer = setTimer(scanContacts, Mzansi.Intel.Config.refreshMs, 0)
    else
        if isTimer(scanTimer) then killTimer(scanTimer) end
        scanTimer = nil
        trackedId = nil
        trail = {}
    end
end

-- Refresh trail for tracked element
setTimer(function()
    if intelActive and isElement(trackedId) then
        local x, y, z = getElementPosition(trackedId)
        Mzansi.Intel.pushTrail(x, y, z)
    end
end, 500, 0)

addEvent("mzansi:intel:toggle", true)
addEventHandler("mzansi:intel:toggle", resourceRoot, function()
    local newState = not intelActive
    Mzansi.Intel.setActive(newState)
    triggerEvent("mzansi:intel:uiToggle", resourceRoot, newState)
    if newState then
        -- Close others FIRST (they may call showCursor(false)), then intel takes over
        triggerEvent("mzansi:phone:close", localPlayer)
        triggerEvent("mzansi:dashboard:close", localPlayer)
        triggerEvent("mzansi:radio:close", localPlayer)
        triggerEvent("mzansi:freeroam:close", localPlayer)
        triggerEvent("mzansi:admin:close", localPlayer)
        triggerEvent("mzansi:flight:close", localPlayer)
        triggerEvent("mzansi:market:close", localPlayer)
        triggerEvent("mzansi:bank:close", localPlayer)
        triggerEvent("mzansi:shop:closeUI", localPlayer)
    end
    outputChatBox("#00E5FF[INTEL] #FFFFFFGod's Eye View " .. (newState and "#00E5FFONLINE" or "#FF4444OFFLINE") .. "#FFFFFF. /eye to toggle.", 255, 255, 255, true)
end)

addEvent("mzansi:intel:accessResult", true)
addEventHandler("mzansi:intel:accessResult", resourceRoot, function(ok)
    if ok then
        Mzansi.Intel.setActive(true)
        triggerEvent("mzansi:intel:uiToggle", resourceRoot, true)
    end
end)