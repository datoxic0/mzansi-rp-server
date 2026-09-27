-- ==============================================================
-- MZANSI LIVING WORLD — SERVER STATE MACHINE
-- Authoritative state transitions, damage, and event dispatch
-- ==============================================================
MzansiLiving = MzansiLiving or {}
MzansiLiving.StateMachine = {}

-- Handles state mutation request
function MzansiLiving.StateMachine.setPedState(ped, newState, extraData)
    if not isElement(ped) then return end
    setElementData(ped, "mzansi:ai:state", newState)

    if newState == MzansiLiving.Enums.State.PANIC_FLEE then
        -- Flee for 8-15 seconds before calming down to WANDER
        local calmTime = math.random(8000, 15000)
        setTimer(function()
            if isElement(ped) and not isPedDead(ped) then
                local curState = getElementData(ped, "mzansi:ai:state")
                if curState == MzansiLiving.Enums.State.PANIC_FLEE or curState == MzansiLiving.Enums.State.COWER then
                    setElementData(ped, "mzansi:ai:state", MzansiLiving.Enums.State.WANDER)
                end
            end
        end, calmTime, 1)
    elseif newState == MzansiLiving.Enums.State.COWER then
        setPedAnimation(ped, "ped", "cower", -1, true, false, false)
        setTimer(function()
            if isElement(ped) and not isPedDead(ped) then
                setPedAnimation(ped, false)
                setElementData(ped, "mzansi:ai:state", MzansiLiving.Enums.State.WANDER)
            end
        end, 6000, 1)
    end
end

-- Advances ped to next connected node in topological graph
addEvent("mzansi:living:nodeReached", true)
addEventHandler("mzansi:living:nodeReached", root, function(reachedNodeId)
    local ped = source
    if not isElement(ped) then return end

    local node = MzansiNodes[reachedNodeId]
    if not node then return end

    local neighbors = node[4]
    if neighbors and #neighbors > 0 then
        -- Filter out backward node if possible for smooth forward walking
        local prevNode = getElementData(ped, "mzansi:ai:currentNode")
        local candidates = {}
        for _, nId in ipairs(neighbors) do
            if nId ~= prevNode then
                table.insert(candidates, nId)
            end
        end

        local nextNode = nil
        if #candidates > 0 then
            nextNode = candidates[math.random(1, #candidates)]
        else
            nextNode = neighbors[math.random(1, #neighbors)]
        end

        setElementData(ped, "mzansi:ai:currentNode", reachedNodeId)
        setElementData(ped, "mzansi:ai:targetNode", nextNode)
    end
end)

-- Handles client reporting gunfire or panic
addEvent("mzansi:living:broadcastPanic", true)
addEventHandler("mzansi:living:broadcastPanic", root, function(dangerX, dangerY, dangerZ, noiseRadius)
    local peds = MzansiLiving.Spawner.getActivePeds()
    for _, ped in ipairs(peds) do
        if isElement(ped) and not isPedDead(ped) then
            local px, py, pz = getElementPosition(ped)
            local dist = getDistanceBetweenPoints3D(px, py, pz, dangerX, dangerY, dangerZ)
            if dist <= noiseRadius then
                local archetype = getElementData(ped, "mzansi:ai:archetype") or 1
                if archetype == MzansiLiving.Enums.Archetype.CIVILIAN_WEAK then
                    MzansiLiving.StateMachine.setPedState(ped, MzansiLiving.Enums.State.COWER)
                elseif archetype == MzansiLiving.Enums.Archetype.GANG_MEMBER then
                    MzansiLiving.StateMachine.setPedState(ped, MzansiLiving.Enums.State.COMBAT_RETALIATE)
                else
                    MzansiLiving.StateMachine.setPedState(ped, MzansiLiving.Enums.State.PANIC_FLEE)
                end
            end
        end
    end
end)

-- Ped death handler: auto cleanup after 15 seconds
addEventHandler("onPedWasted", root, function(totalAmmo, killer, killerWeapon, bodypart)
    local ped = source
    if getElementData(ped, "mzansi:ai:enabled") then
        setElementData(ped, "mzansi:ai:state", MzansiLiving.Enums.State.IDLE)
        
        -- If killed by player, broadcast police awareness
        if killer and getElementType(killer) == "player" then
            if Mzansi and Mzansi.Crime and Mzansi.Crime.addWantedLevel then
                Mzansi.Crime.addWantedLevel(killer, 1)
            end
        end

        -- Recycle corpse after 15s
        setTimer(function()
            if isElement(ped) then
                MzansiLiving.Spawner.recyclePed(ped)
            end
        end, 15000, 1)
    end
end)
