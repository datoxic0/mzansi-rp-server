-- ==============================================================
-- MZANSI LIVING WORLD — CLIENT TRAFFIC CONTROLLER
-- Syncer-driven smooth driving, collision avoidance & node tracking
-- FIXES: raycast excludes own driver ped; bumper gap check; 35 km/h cap
-- ==============================================================
local _lastVehNodeAdvance = {}

-- Returns true if there is another traffic vehicle within minGap metres ahead
local function hasTrafficAhead(veh, vx, vy, vz, curRot, minGap)
    local curRad   = math.rad(-curRot)
    local checkDist = minGap
    local fwdX = vx + math.sin(curRad) * checkDist
    local fwdY = vy + math.cos(curRad) * checkDist

    local vehicles = getElementsByType("vehicle", root, true)
    for _, other in ipairs(vehicles) do
        if other ~= veh and getElementData(other, "mzansi:traffic:vehicle") then
            local ox, oy, oz = getElementPosition(other)
            local d = getDistanceBetweenPoints2D(vx, vy, ox, oy)
            if d < minGap then return true end
        end
    end
    return false
end

addEventHandler("onClientPreRender", root, function()
    local vehicles = getElementsByType("vehicle", root, true)

    for _, veh in ipairs(vehicles) do
        if getElementData(veh, "mzansi:traffic:vehicle") and isElementSyncer(veh) then
            local driver = getElementData(veh, "mzansi:traffic:driverPed")
            if isElement(driver) and not isPedDead(driver) then
                local targetNodeId = getElementData(veh, "mzansi:traffic:targetNode")
                local node = MzansiRoadNodes and MzansiRoadNodes[targetNodeId]

                if node then
                    local tx, ty, tz = node[1], node[2], node[3]
                    local vx, vy, vz = getElementPosition(veh)
                    local dist = getDistanceBetweenPoints2D(vx, vy, tx, ty)

                    -- Target node reached; report to server for next link
                    if dist < 4.0 then
                        local now = getTickCount()
                        if not _lastVehNodeAdvance[veh] or (now - _lastVehNodeAdvance[veh]) > 1000 then
                            _lastVehNodeAdvance[veh] = now
                            triggerServerEvent("mzansi:traffic:nodeReached", veh, targetNodeId)
                        end
                    end

                    -- Calculate target heading
                    local targetAngle = math.deg(math.atan2(ty - vy, tx - vx)) - 90
                    if targetAngle < 0 then targetAngle = targetAngle + 360 end

                    local _, _, curRot = getElementRotation(veh)
                    local angleDiff = (targetAngle - curRot + 180) % 360 - 180

                    -- Steer vehicle
                    if angleDiff > 10 then
                        setPedControlState(driver, "vehicle_right", true)
                        setPedControlState(driver, "vehicle_left",  false)
                    elseif angleDiff < -10 then
                        setPedControlState(driver, "vehicle_left",  true)
                        setPedControlState(driver, "vehicle_right", false)
                    else
                        setPedControlState(driver, "vehicle_left",  false)
                        setPedControlState(driver, "vehicle_right", false)
                    end

                    -- Forward obstacle raycast
                    -- CRITICAL FIX: exclude the driver ped from raycast hits.
                    -- Previous code hit the driver ped (sitting inside car) as an obstacle,
                    -- making the car perpetually brake for its own passenger.
                    local curRad  = math.rad(-curRot)
                    local lookDist = 7.5
                    local forwardX = vx + math.sin(curRad) * lookDist
                    local forwardY = vy + math.cos(curRad) * lookDist

                    local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(
                        vx, vy, vz + 0.5,
                        forwardX, forwardY, vz + 0.5,
                        true, true, true, true, false, false, false, false, veh
                    )

                    -- Exclude driver ped and walking players (only block for vehicles + static world)
                    local isRealObstacle = hit and hitElement
                                        and hitElement ~= veh
                                        and hitElement ~= driver
                                        and getElementType(hitElement) ~= "player"

                    -- Bumper gap: also stop if another traffic vehicle is within 5m ahead
                    local bumpBlock = hasTrafficAhead(veh, vx, vy, vz, curRot, 5.0)

                    -- Measure vehicle speed
                    local velX, velY, velZ = getElementVelocity(veh)
                    local speed = (velX^2 + velY^2 + velZ^2) ^ 0.5 * 180 -- km/h

                    if isRealObstacle or bumpBlock then
                        -- Obstacle detected: apply brakes
                        setPedControlState(driver, "accelerate",    false)
                        setPedControlState(driver, "brake_reverse", true)
                    else
                        -- Clear ahead: urban speed cap reduced to 35 km/h (was 42)
                        if speed < 35 then
                            setPedControlState(driver, "accelerate",    true)
                            setPedControlState(driver, "brake_reverse", false)
                        else
                            setPedControlState(driver, "accelerate",    false)
                            setPedControlState(driver, "brake_reverse", false)
                        end
                    end
                end
            end
        end
    end
end)

-- ================================================================
-- CLIENT-SIDE: Set driver ped safety flags (client-only functions)
-- ================================================================
local _driverFlagsSet = {}

addEventHandler("onClientPreRender", root, function()
    local vehicles = getElementsByType("vehicle", root, true)
    for _, veh in ipairs(vehicles) do
        if getElementData(veh, "mzansi:traffic:vehicle") and not _driverFlagsSet[veh] then
            local driver = getElementData(veh, "mzansi:traffic:driverPed")
            if isElement(driver) then
                setPedCanBeKnockedOffBike(driver, false)
                setPedCameraRotation(driver, 0)
                _driverFlagsSet[veh] = true
            end
        end

        -- Clean up table for destroyed vehicles
        if _driverFlagsSet[veh] and not isElement(veh) then
            _driverFlagsSet[veh] = nil
        end
    end
end)

-- ================================================================
-- TRAFFIC LIGHT PAUSE & OVERTAKE
-- Only resumes after path is confirmed clear (not force-resume).
-- ================================================================
local _stationaryStart = {}
local _blockedStart    = {}

addEventHandler("onClientPreRender", root, function()
    local now = getTickCount()
    local vehicles = getElementsByType("vehicle", root, true)

    for _, veh in ipairs(vehicles) do
        if getElementData(veh, "mzansi:traffic:vehicle") and isElementSyncer(veh) then
            local driver = getElementData(veh, "mzansi:traffic:driverPed")
            if isElement(driver) and not isPedDead(driver) then
                local velX, velY, velZ = getElementVelocity(veh)
                local speedKmh = (velX^2 + velY^2 + velZ^2) ^ 0.5 * 180

                if speedKmh < 5 then
                    if not _stationaryStart[veh] then
                        _stationaryStart[veh] = now
                    end

                    local stoppedFor = now - _stationaryStart[veh]
                    if stoppedFor > 3500 and stoppedFor < 5500 then
                        -- Brief "red light" hold
                        setPedControlState(driver, "accelerate",    false)
                        setPedControlState(driver, "brake_reverse", false)
                    elseif stoppedFor >= 5500 then
                        -- Attempt to resume — but only if no obstacle detected ahead
                        local vx, vy, vz = getElementPosition(veh)
                        local _, _, curRot = getElementRotation(veh)
                        local clearPath = not hasTrafficAhead(veh, vx, vy, vz, curRot, 6.0)
                        if clearPath then
                            setPedControlState(driver, "accelerate", true)
                            _stationaryStart[veh] = nil
                        end
                    end

                    -- Overtake if stuck > 6s and still blocked
                    if not _blockedStart[veh] then
                        _blockedStart[veh] = now
                    elseif (now - _blockedStart[veh]) > 6000 then
                        setPedControlState(driver, "vehicle_right", true)
                        setPedControlState(driver, "accelerate",    true)
                        setTimer(function()
                            if isElement(driver) then
                                setPedControlState(driver, "vehicle_right", false)
                            end
                        end, 2500, 1)
                        _blockedStart[veh] = nil
                    end
                else
                    _stationaryStart[veh] = nil
                    _blockedStart[veh]    = nil
                end
            end
        end
    end
end)

