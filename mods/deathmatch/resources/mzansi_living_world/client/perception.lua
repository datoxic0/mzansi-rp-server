-- ==============================================================
-- MZANSI LIVING WORLD — CLIENT SENSORY PERCEPTION
-- Gunfire detection, aiming cone raycasts, and vehicle collision radar
-- ==============================================================
local _perceptionTimer = nil
local _lastHoldupAttempt = 0

-- Gunfire & Explosion Listener (Acoustic Sphere)
addEventHandler("onClientPlayerWeaponFire", root, function(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
    local shooter = source
    local sx, sy, sz = getElementPosition(shooter)
    local noiseRadius = MzansiLiving.Config.WeaponNoiseRadius[weapon] or 45.0

    -- Only report if within local hearing range to avoid spam
    local lx, ly, lz = getElementPosition(localPlayer)
    if getDistanceBetweenPoints3D(lx, ly, lz, sx, sy, sz) <= (noiseRadius + 30.0) then
        triggerServerEvent("mzansi:living:broadcastPanic", resourceRoot, sx, sy, sz, noiseRadius)
    end
end)

-- Explosion acoustic propagation
addEventHandler("onClientExplosion", root, function(x, y, z, explosionType)
    triggerServerEvent("mzansi:living:broadcastPanic", resourceRoot, x, y, z, 90.0)
end)

-- Periodic 200ms Ticker for Aiming Cone and Vehicle Radar
function MzansiLiving_PerceptionTick()
    local lx, ly, lz = getElementPosition(localPlayer)

    -- 1. Check if Local Player is aiming a weapon
    if getPedControlState(localPlayer, "aim_weapon") then
        local weapon = getPedWeapon(localPlayer)
        -- Ignore fists and cameras
        if weapon >= 22 and weapon <= 38 then
            local cx, cy, cz, tx, ty, tz = getCameraMatrix()
            local dirX = tx - cx
            local dirY = ty - cy
            local dirZ = tz - cz
            local len = math.sqrt(dirX*dirX + dirY*dirY + dirZ*dirZ)

            if len > 0 then
                dirX = dirX / len
                dirY = dirY / len
                dirZ = dirZ / len

                local checkRange = 25.0
                local endX = cx + dirX * checkRange
                local endY = cy + dirY * checkRange
                local endZ = cz + dirZ * checkRange

                local hit, hx, hy, hz, hitElement = processLineOfSight(
                    cx, cy, cz, endX, endY, endZ,
                    false, false, true, false, false
                )

                if hit and hitElement and getElementType(hitElement) == "ped" then
                    -- Check if it's an interior cashier
                    local isStaff = getElementData(hitElement, "mzansi:ai:interiorStaff")
                    local role = getElementData(hitElement, "mzansi:ai:role")

                    if isStaff and role == "cashier" then
                        local now = getTickCount()
                        if (now - _lastHoldupAttempt) > 6000 then
                            _lastHoldupAttempt = now
                            triggerServerEvent("mzansi:living:startCashierHoldup", resourceRoot, hitElement)
                        end
                    -- Check if it's an ambient pedestrian on street
                    elseif getElementData(hitElement, "mzansi:ai:enabled") then
                        local dist = getDistanceBetweenPoints3D(lx, ly, lz, hx, hy, hz)
                        if dist < MzansiLiving.Config.Visual.AIM_RADAR then
                            setPedControlState(hitElement, "forwards", false)
                            setPedControlState(hitElement, "sprint", false)
                            setPedAnimation(hitElement, "ped", "cower", -1, true, false, false)
                        end
                    end
                end
            end
        end
    end

    -- 2. Vehicle Threat Radar (Near-miss dive)
    local vehicles = getElementsByType("vehicle", root, true)
    local peds = getElementsByType("ped", root, true)

    for _, veh in ipairs(vehicles) do
        local vx, vy, vz = getElementVelocity(veh)
        local speed = math.sqrt(vx*vx + vy*vy + vz*vz) * 180.0 -- km/h approximation

        if speed > 40.0 then
            local vehX, vehY, vehZ = getElementPosition(veh)
            for _, ped in ipairs(peds) do
                if getElementData(ped, "mzansi:ai:enabled") and isElementSyncer(ped) then
                    local pedX, pedY, pedZ = getElementPosition(ped)
                    local dist = getDistanceBetweenPoints3D(vehX, vehY, vehZ, pedX, pedY, pedZ)

                    if dist < 8.0 then
                        -- Execute dodge dive
                        setPedAnimation(ped, "ped", "ev_dive", -1, false, false, false)
                    end
                end
            end
        end
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    _perceptionTimer = setTimer(MzansiLiving_PerceptionTick, MzansiLiving.Config.TICK_INTERVAL_CLIENT, 0)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if isTimer(_perceptionTimer) then killTimer(_perceptionTimer) end
end)
