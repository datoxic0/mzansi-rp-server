Mzansi = Mzansi or {}
Mzansi.ActivityClient = {}

-- ============================================================
-- CONFIG
-- ============================================================
local NPC_RENDER_DIST   = 30.0   -- Nameplate render distance
local NPC_INTERACT_DIST = 3.5    -- E to interact distance
local GANG_ZONE_DIST    = 50.0   -- Gang territory warning radius

-- ============================================================
-- GANG ZONE WARNING COLORS (client-side detection)
-- ============================================================
local GANG_ZONES = {
    -- Cape Town / Western Cape (LS)
    { name = "South Side Kings Territory (Cape Town)", x = 2244.5,  y = -1665.5, z = 15.5, color = tocolor(30,  144, 255, 200) },
    { name = "Cape Flats 28s Territory (Cape Town)",   x = 1950.0,  y = -1450.0, z = 13.5, color = tocolor(255, 200, 0,   200) },
    { name = "Crazy Dragons Territory (Cape Town)",    x = 1920.0,  y = -1760.0, z = 13.5, color = tocolor(255, 50,  50,  200) },

    -- Durban / KwaZulu-Natal (SF)
    { name = "Zulu Warriors Hostels (Durban)",         x = -2160.0, y = -240.0,  z = 36.5, color = tocolor(0,   200, 0,   200) },
    { name = "Zulu Warriors Docks (Durban Harbour)",   x = -1600.0, y = 150.0,   z = 10.5, color = tocolor(0,   200, 0,   200) },
    { name = "Durban Golden Mile Beachfront (SF)",     x = -2720.0, y = -320.0,  z = 7.5,  color = tocolor(0,   200, 0,   200) },

    -- Johannesburg (Jozi) / Gauteng (LV)
    { name = "Boere Mafia Territory (Jozi)",           x = 2270.0,  y = 1430.0,  z = 11.5, color = tocolor(200, 150, 0,   200) },
    { name = "Nyau Dust Cartel (Jozi Strip)",          x = 2480.0,  y = 2110.0,  z = 11.0, color = tocolor(150, 0,   200, 200) },
    { name = "Egoli Gold Reef Casino Turf (Jozi)",     x = 2028.0,  y = 1008.0,  z = 10.8, color = tocolor(255, 215, 0,   200) },
}

local lastGangZone = nil
local zoneCheckTimer = 0

-- ============================================================
-- RENDER LOOP — NPC Nameplates + Gang Zone HUD
-- ============================================================
addEventHandler("onClientRender", root, function()
    local pX, pY, pZ = getElementPosition(localPlayer)
    local camX, camY, camZ = getCameraMatrix()
    local tick = getTickCount()

    -- ---- NPC Floating Nameplates ----
    for _, ped in ipairs(getElementsByType("ped", root, true)) do
        if getElementData(ped, "mzansi:isNPC") and not isPedDead(ped) then
            local nx, ny, nz = getElementPosition(ped)
            local dist = getDistanceBetweenPoints3D(pX, pY, pZ, nx, ny, nz)

            if dist < NPC_RENDER_DIST then
                local inSight = isLineOfSightClear(camX, camY, camZ, nx, ny, nz + 1.0, true, false, false, true, false, false, false, ped)
                if inSight then
                    local sx, sy = getScreenFromWorldPosition(nx, ny, nz + 1.25)
                    if sx and sy then
                        local scale  = math.max(0.65, 1.25 - (dist / NPC_RENDER_DIST))
                        local name   = getElementData(ped, "mzansi:npcName") or "Citizen"
                        local role   = getElementData(ped, "mzansi:npcRole") or "Roleplay NPC"
                        local nType  = getElementData(ped, "mzansi:npcType") or ""

                        -- Color by NPC type
                        local nameColor
                        if nType == "police" or nType == "police_guard" then
                            nameColor = tocolor(80, 150, 255, 240)
                        elseif nType == "doctor" or nType == "ems_nurse" then
                            nameColor = tocolor(255, 80, 80, 240)
                        elseif nType:sub(1, 5) == "gang_" then
                            nameColor = tocolor(255, 100, 30, 240)
                        elseif nType == "arms" or nType == "drug_dealer" then
                            nameColor = tocolor(200, 50, 255, 240)
                        elseif nType == "mechanic" then
                            nameColor = tocolor(255, 165, 0, 240)
                        elseif nType == "clerk" then
                            nameColor = tocolor(50, 220, 100, 240)
                        else
                            nameColor = tocolor(200, 170, 50, 240)
                        end

                        -- Background pill for readability
                        local tw = 160
                        dxDrawRectangle(sx - tw/2 - 4, sy - 24, tw + 8, 20, tocolor(0, 0, 0, 130))
                        dxDrawText(name, sx - tw/2, sy - 24, sx + tw/2, sy - 4, nameColor, scale, "default-bold", "center", "center")

                        -- Role line
                        dxDrawRectangle(sx - tw/2 - 4, sy - 4, tw + 8, 16, tocolor(0, 0, 0, 90))
                        dxDrawText(role, sx - tw/2, sy - 4, sx + tw/2, sy + 12, tocolor(180, 200, 220, 210), scale * 0.82, "default", "center", "center")

                        -- E-prompt when close
                        if dist < NPC_INTERACT_DIST then
                            local pulse = math.sin(tick / 300) * 40 + 215
                            dxDrawRectangle(sx - tw/2 - 4, sy + 14, tw + 8, 16, tocolor(0, 0, 0, 110))
                            dxDrawText("[ E ] Talk", sx - tw/2, sy + 14, sx + tw/2, sy + 30, tocolor(50, 220, 100, math.floor(pulse)), scale * 0.88, "default-bold", "center", "center")
                        end
                    end
                end
            end
        end
    end

    -- ---- Gang Zone Territory Warning (top-center HUD) ----
    if tick - zoneCheckTimer > 1000 then
        zoneCheckTimer = tick
        local inZone = nil
        for _, zone in ipairs(GANG_ZONES) do
            local d = getDistanceBetweenPoints3D(pX, pY, pZ, zone.x, zone.y, zone.z)
            if d < GANG_ZONE_DIST then
                inZone = zone
                break
            end
        end
        if inZone ~= lastGangZone then
            lastGangZone = inZone
            if inZone then
                outputChatBox("⚠ You are entering " .. inZone.name .. "! Stay alert.", 255, 200, 0)
            end
        end
    end

    -- ---- Live Gang Zone Banner (while inside territory) ----
    if lastGangZone then
        local sw, sh = guiGetScreenSize()
        local pulse  = math.abs(math.sin(tick / 600)) * 80 + 140
        local bannerW = 360
        local bx = (sw - bannerW) / 2
        local by = sh * 0.08
        dxDrawRectangle(bx - 4, by - 4, bannerW + 8, 36, tocolor(0, 0, 0, 140))
        dxDrawRectangle(bx, by, bannerW, 28, tocolor(0, 0, 0, 100))

        local zoneR, zoneG, zoneB, zoneA = getColorFromString and getColorFromString("#ffffff") or 255, 200, 0, math.floor(pulse)
        local nameR, nameG, nameB, nameA = 255, 200, 0, math.floor(pulse)
        dxDrawText("⚠ " .. lastGangZone.name, bx, by, bx + bannerW, by + 28,
            tocolor(255, 200, 0, math.floor(pulse)), 1.1, "default-bold", "center", "center")
    end
end)

-- ============================================================
-- KEY 'E' — Interact with Nearest NPC
-- ============================================================
bindKey("e", "down", function()
    if Mzansi.Util and Mzansi.Util.bindBlocked and Mzansi.Util.bindBlocked() then return end
    if isPedInVehicle(localPlayer) then return end

    local pX, pY, pZ = getElementPosition(localPlayer)
    local closestNPC  = nil
    local closestDist = NPC_INTERACT_DIST

    for _, ped in ipairs(getElementsByType("ped", root, true)) do
        if getElementData(ped, "mzansi:isNPC") and not isPedDead(ped) then
            local nx, ny, nz = getElementPosition(ped)
            local dist = getDistanceBetweenPoints3D(pX, pY, pZ, nx, ny, nz)
            if dist < closestDist then
                closestDist = dist
                closestNPC  = ped
            end
        end
    end

    if closestNPC then
        local npcType = getElementData(closestNPC, "mzansi:npcType")
        triggerServerEvent("mzansi:activity:interactNPC", localPlayer, npcType)
    end
end)

-- ============================================================
-- GANG EVENT NOTIFICATION (from server)
-- ============================================================
addEventHandler("mzansi:client:gangEvent", root, function(zoneName)
    local sw, sh = guiGetScreenSize()
    -- Flash a short warning on screen
    setTimer(function()
        outputChatBox("🔥 GANG ALERT: Skirmish near " .. (zoneName or "unknown area") .. "!", 255, 150, 0)
    end, 100, 1)
end)

-- ============================================================
-- 3D SPATIAL SOUNDSCAPES & AMPIANO CULTURAL AUDIO
-- Angel: 3D Spatial Audio & Radio Dispatcher
-- ============================================================
local SOUNDSCAPE_HUBS = {
    { name = "Commerce Taxi Rank Radio", x = 1785.0, y = -1700.0, z = 13.5, maxDist = 45.0, vol = 0.55 },
    { name = "Soweto Spaza Sound Hub",   x = 2240.0, y = -1665.0, z = 15.0, maxDist = 35.0, vol = 0.50 },
    { name = "Joburg CBD Market Beats",  x = 1485.0, y = -1660.0, z = 13.5, maxDist = 40.0, vol = 0.45 },
}

local activeSoundEmitters = {}

local function startSoundscapes()
    for _, hub in ipairs(SOUNDSCAPE_HUBS) do
        -- Stream authentic SA broadcast audio or ambient radio
        local sound = playSound3D("http://stream.zeno.fm/f3wvbbqmdg8uv", hub.x, hub.y, hub.z, true)
        if sound then
            setSoundMaxDistance(sound, hub.maxDist)
            setSoundVolume(sound, hub.vol)
            table.insert(activeSoundEmitters, sound)
        end
    end
    outputDebugString("[Mzansi-Audio] 3D Spatial Soundscapes initialized at " .. #SOUNDSCAPE_HUBS .. " township cultural hubs.")
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    setTimer(startSoundscapes, 3000, 1)
    setTimer(updateAmbientCrowd, 2000, 0)
end)

-- ============================================================
-- GROUND SNAPPING ENGINE (Eliminates underground/floating vehicles)
-- Angel: Client Terrain Snapper
-- ============================================================
addEventHandler("onClientElementStreamIn", root, function()
    if getElementType(source) == "vehicle" then
        if not getVehicleController(source) then
            local vx, vy, vz = getElementPosition(source)
            local groundZ = getGroundPosition(vx, vy, vz + 2.0)
            if groundZ and math.abs(vz - groundZ) > 0.15 and math.abs(vz - groundZ) < 3.0 then
                setElementPosition(source, vx, vy, groundZ + 0.35)
            end
        end
    end
end)

-- ============================================================
-- CLIENT-SIDE AMBIENT SIDEWALK PEDESTRIAN LIFE
-- Spawns animated walking citizens and conversation duos at key hubs
-- ============================================================
local CROWD_HUBS = {
    {
        name = "Airport Terminal Concourse",
        center = { x = 1685.0, y = -2250.0, z = 13.5 },
        peds = {
            { model = 9,   offset = { x = 3, y = -2 }, anim = { "PED", "IDLE_stance" } },
            { model = 35,  offset = { x = 4, y = -2 }, anim = { "GANGS", "prtial_gngtlkA" } },
            { model = 17,  offset = { x = -8, y = 3 }, anim = { "PED", "IDLE_stance" } },
            { model = 163, offset = { x = -15, y = 5 }, anim = { "COP_AMBIENT", "Cop_look" } },
        }
    },
    {
        name = "All Saints Hospital Walkway",
        center = { x = 1185.0, y = -1320.0, z = 13.5 },
        peds = {
            { model = 274, offset = { x = 2, y = 3 }, anim = { "GANGS", "prtial_gngtlkA" } },
            { model = 276, offset = { x = 3, y = 3 }, anim = { "GANGS", "prtial_gngtlkE" } },
            { model = 70,  offset = { x = -6, y = -4 }, anim = { "SMOKING", "M_smk_in" } },
        }
    },
    {
        name = "Commerce Taxi Rank Hustle",
        center = { x = 1780.0, y = -1860.0, z = 13.5 },
        peds = {
            { model = 17,  offset = { x = 2, y = 1 }, anim = { "DEALER", "dealer_idle" } },
            { model = 35,  offset = { x = 3.2, y = 1 }, anim = { "GANGS", "prtial_gngtlkA" } },
            { model = 105, offset = { x = -4, y = 2 }, anim = { "SMOKING", "M_smk_in" } },
            { model = 106, offset = { x = -5, y = 2 }, anim = { "GANGS", "hndshkfa" } },
        }
    }
}

local activeCrowdPeds = {}

function updateAmbientCrowd()
    local px, py, pz = getElementPosition(localPlayer)

    for _, hub in ipairs(CROWD_HUBS) do
        local dist = getDistanceBetweenPoints3D(px, py, pz, hub.center.x, hub.center.y, hub.center.z)
        if dist < 65.0 then
            if not activeCrowdPeds[hub.name] then
                activeCrowdPeds[hub.name] = {}
                for _, pData in ipairs(hub.peds) do
                    local sx = hub.center.x + pData.offset.x
                    local sy = hub.center.y + pData.offset.y
                    local sz = getGroundPosition(sx, sy, hub.center.z + 2.0) or hub.center.z
                    local ped = createPed(pData.model, sx, sy, sz + 0.1)
                    if ped then
                        setElementDimension(ped, getElementDimension(localPlayer))
                        setElementInterior(ped, getElementInterior(localPlayer))
                        if pData.anim then
                            setPedAnimation(ped, pData.anim[1], pData.anim[2], -1, true, false, false, false)
                        end
                        table.insert(activeCrowdPeds[hub.name], ped)
                    end
                end
            end
        elseif dist > 85.0 then
            if activeCrowdPeds[hub.name] then
                for _, ped in ipairs(activeCrowdPeds[hub.name]) do
                    if isElement(ped) then destroyElement(ped) end
                end
                activeCrowdPeds[hub.name] = nil
            end
        end
    end
end
