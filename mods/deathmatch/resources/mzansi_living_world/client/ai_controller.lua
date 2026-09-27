-- ==============================================================
-- MZANSI LIVING WORLD — CLIENT AI CONTROLLER
-- Syncer-driven smooth movement, steering, and obstacle raycasts
-- ==============================================================
local _lastNodeAdvance  = {}
local _lastFireTime     = {}   -- Rate-limit: tracks last fire timestamp per ped
local _combatStartTime  = {}   -- Combat timeout: tracks when ped entered combat

local COMBAT_ARCHETYPES = { [4] = true, [5] = true }  -- GANG_MEMBER=4, COP=5 only
local FIRE_COOLDOWN_MS  = 800   -- Minimum ms between shots per ped
local COMBAT_TIMEOUT_MS = 12000 -- Auto-exit combat after 12 seconds
local MAX_COMBAT_RANGE  = 20.0  -- Exit combat if target is farther than this

-- Evaluates smooth movement on every client frame for synced peds
addEventHandler("onClientPreRender", root, function()
    local peds = getElementsByType("ped", root, true)
    local localX, localY, localZ = getElementPosition(localPlayer)
    local now = getTickCount()

    for _, ped in ipairs(peds) do
        -- Only simulate if living world AI is enabled and ped is alive
        if getElementData(ped, "mzansi:ai:enabled") and not isPedDead(ped) then
            -- Verify if local client is the designated syncer for this ped
            if isElementSyncer(ped) then
                local state = getElementData(ped, "mzansi:ai:state") or MzansiLiving.Enums.State.WANDER
                local px, py, pz = getElementPosition(ped)

                -- ------------------------------------------------------
                -- STATE: WANDER (Smooth Node-Following Navigation)
                -- ------------------------------------------------------
                if state == MzansiLiving.Enums.State.WANDER then
                    local targetNodeId = getElementData(ped, "mzansi:ai:targetNode")
                    local node = MzansiNodes[targetNodeId]

                    if node then
                        local nx, ny, nz = node[1], node[2], node[3]
                        local dist = getDistanceBetweenPoints2D(px, py, nx, ny)

                        -- Target node reached (advance to next linked node)
                        if dist < 1.4 then
                            if not _lastNodeAdvance[ped] or (now - _lastNodeAdvance[ped]) > 1200 then
                                _lastNodeAdvance[ped] = now
                                triggerServerEvent("mzansi:living:nodeReached", ped, targetNodeId)
                            end
                        else
                            -- Calculate target heading angle
                            local targetAngle = math.deg(math.atan2(ny - py, nx - px)) - 90
                            if targetAngle < 0 then targetAngle = targetAngle + 360 end

                            -- Short forward obstacle raycasting (walls, cars, obstacles)
                            local forwardRad = math.rad(-targetAngle)
                            local checkDist = 1.8
                            local rayX = px + math.sin(forwardRad) * checkDist
                            local rayY = py + math.cos(forwardRad) * checkDist

                            local hit, _, _, _, hitElement = processLineOfSight(
                                px, py, pz + 0.6,
                                rayX, rayY, pz + 0.6,
                                true, true, false, true, true
                            )

                            -- If blocked, deflect steering angle to bypass obstacle
                            if hit then
                                targetAngle = targetAngle + 35.0
                            end

                            -- Apply heading and walk keystroke
                            setPedCameraRotation(ped, targetAngle)
                            setPedControlState(ped, "forwards", true)
                            setPedControlState(ped, "sprint", false)
                            setPedControlState(ped, "crouch", false)
                        end
                    end

                -- ------------------------------------------------------
                -- STATE: PANIC_FLEE (Sprint away from threat)
                -- ------------------------------------------------------
                elseif state == MzansiLiving.Enums.State.PANIC_FLEE then
                    local targetNodeId = getElementData(ped, "mzansi:ai:targetNode")
                    local node = MzansiNodes[targetNodeId]

                    if node then
                        local nx, ny = node[1], node[2]
                        local dist = getDistanceBetweenPoints2D(px, py, nx, ny)
                        if dist < 1.6 then
                            triggerServerEvent("mzansi:living:nodeReached", ped, targetNodeId)
                        else
                            local targetAngle = math.deg(math.atan2(ny - py, nx - px)) - 90
                            setPedCameraRotation(ped, targetAngle)
                            setPedControlState(ped, "forwards", true)
                            setPedControlState(ped, "sprint", true) -- Panic sprint
                        end
                    else
                        setPedControlState(ped, "forwards", true)
                        setPedControlState(ped, "sprint", true)
                    end

                -- ------------------------------------------------------
                -- STATE: COWER (Hands over head, stationary)
                -- ------------------------------------------------------
                elseif state == MzansiLiving.Enums.State.COWER then
                    setPedControlState(ped, "forwards", false)
                    setPedControlState(ped, "sprint", false)

                -- ------------------------------------------------------
                -- STATE: COMBAT_RETALIATE (Gangster/Cop combat ONLY)
                -- STRICT RULES:
                --   1. Only GANG_MEMBER (4) and COP (5) archetypes may fight.
                --   2. Fire is rate-limited to once per FIRE_COOLDOWN_MS.
                --   3. Combat auto-exits after COMBAT_TIMEOUT_MS (12 seconds).
                --   4. Combat exits if target is > MAX_COMBAT_RANGE away.
                -- ------------------------------------------------------
                elseif state == MzansiLiving.Enums.State.COMBAT_RETALIATE then
                    local archetype = getElementData(ped, "mzansi:ai:archetype") or 1

                    -- GUARD: Only gang members and cops are allowed to fight
                    if not COMBAT_ARCHETYPES[archetype] then
                        -- Civilian accidentally in combat state — revert immediately
                        setElementData(ped, "mzansi:ai:state", MzansiLiving.Enums.State.PANIC_FLEE)
                        _combatStartTime[ped] = nil
                        _lastFireTime[ped]    = nil
                    else
                        -- Combat timeout check
                        if not _combatStartTime[ped] then
                            _combatStartTime[ped] = now
                        end

                        local distToPlayer = getDistanceBetweenPoints3D(px, py, pz, localX, localY, localZ)

                        -- Auto-exit combat: timeout OR target out of range
                        if (now - _combatStartTime[ped]) >= COMBAT_TIMEOUT_MS
                        or distToPlayer > MAX_COMBAT_RANGE then
                            setElementData(ped, "mzansi:ai:state", MzansiLiving.Enums.State.WANDER)
                            setPedControlState(ped, "aim_weapon", false)
                            setPedControlState(ped, "fire", false)
                            _combatStartTime[ped] = nil
                            _lastFireTime[ped]    = nil
                        else
                            -- Rate-limited fire: max once per FIRE_COOLDOWN_MS
                            setPedControlState(ped, "forwards", false)
                            setPedAimTarget(ped, localX, localY, localZ)
                            setPedControlState(ped, "aim_weapon", true)

                            local canFire = (not _lastFireTime[ped]) or
                                            (now - _lastFireTime[ped]) >= FIRE_COOLDOWN_MS
                            if canFire and math.random(1, 100) > 35 then
                                setPedControlState(ped, "fire", true)
                                _lastFireTime[ped] = now
                            else
                                setPedControlState(ped, "fire", false)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- -------------------------------------------------------------
-- GROUND SNAPPING FOR ATMOSPHERIC LANDMARK PEDS
-- Ensures peds sit precisely on sidewalks and concourses without clipping
-- -------------------------------------------------------------
addEventHandler("onClientElementStreamIn", root, function()
    if getElementType(source) == "ped" and getElementData(source, "mzansi:ai:landmark") then
        local px, py, pz = getElementPosition(source)
        local gz = getGroundPosition(px, py, pz + 2.0)
        if gz and math.abs(gz - pz) < 2.5 then
            setElementPosition(source, px, py, gz)
        end
    end
end)
