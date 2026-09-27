-- ==============================================================
-- MZANSI LIVING WORLD — SERVER SPAWNER & ENTITY POOL
-- Spawns peds at authentic node coordinates with archetype stats
-- ==============================================================
MzansiLiving = MzansiLiving or {}
MzansiLiving.Spawner = {}

local _activePeds = {}

-- Spawns an ambient pedestrian at a specified graph node
function MzansiLiving.Spawner.spawnPedAtNode(nodeId, model, archetype, zoneName)
    local node = MzansiNodes[nodeId]
    if not node then return nil end

    local x, y, z = node[1], node[2], node[3]
    local neighbors = node[4]
    local targetNodeId = nil
    if neighbors and #neighbors > 0 then
        targetNodeId = neighbors[math.random(1, #neighbors)]
    end

    -- Pick model from zone pool if not supplied
    if not model then
        local zoneConfig = MzansiLiving.Config.ModelPools[zoneName] or MzansiLiving.Config.ModelPools.commerce
        local pool = zoneConfig.models
        model = pool[math.random(1, #pool)]
    end

    -- Create synchronized ped element
    local ped = createPed(model, x, y, z + 0.5, math.random(0, 359), true)
    if not ped then return nil end

    -- Set random authentic GTA walking style
    local walkStyles = MzansiLiving.Config.WalkingStyles
    local walkStyle = walkStyles[math.random(1, #walkStyles)]
    setPedWalkingStyle(ped, walkStyle)

    -- Assign psychological attributes based on archetype
    local fear = 50
    local temper = 50
    if archetype == MzansiLiving.Enums.Archetype.CIVILIAN_WEAK then
        fear = math.random(75, 100)
        temper = math.random(10, 30)
    elseif archetype == MzansiLiving.Enums.Archetype.CIVILIAN_TOUGH then
        fear = math.random(15, 35)
        temper = math.random(65, 90)
    elseif archetype == MzansiLiving.Enums.Archetype.GANG_MEMBER then
        fear = math.random(10, 25)
        temper = math.random(75, 95)
        giveWeapon(ped, 22, 50, false) -- Concealed 9mm
    elseif archetype == MzansiLiving.Enums.Archetype.COP then
        fear = 10
        temper = 40
        giveWeapon(ped, 24, 100, false) -- Desert Eagle
        setPedArmor(ped, 100)
    end

    -- Set networked AI element data
    setElementData(ped, "mzansi:ai:enabled", true)
    setElementData(ped, "mzansi:ai:state", MzansiLiving.Enums.State.WANDER)
    setElementData(ped, "mzansi:ai:archetype", archetype or MzansiLiving.Enums.Archetype.CIVILIAN_NORMAL)
    setElementData(ped, "mzansi:ai:currentNode", nodeId)
    setElementData(ped, "mzansi:ai:targetNode", targetNodeId or nodeId)
    setElementData(ped, "mzansi:ai:fear", fear)
    setElementData(ped, "mzansi:ai:temper", temper)
    setElementData(ped, "mzansi:ai:zone", zoneName or "commerce")

    table.insert(_activePeds, ped)
    return ped
end

-- Safely cleans up and recycles a distant or dead ped
function MzansiLiving.Spawner.recyclePed(ped)
    if not isElement(ped) then return end
    for i = #_activePeds, 1, -1 do
        if _activePeds[i] == ped then
            table.remove(_activePeds, i)
            break
        end
    end
    destroyElement(ped)
end

-- Returns list of all active living world peds
function MzansiLiving.Spawner.getActivePeds()
    -- Filter out dead/invalid elements
    local valid = {}
    for i = #_activePeds, 1, -1 do
        local p = _activePeds[i]
        if isElement(p) then
            table.insert(valid, p)
        else
            table.remove(_activePeds, i)
        end
    end
    return valid
end

-- Export wrappers for cross-resource access
function spawnPedAtNode(nodeId, model, archetype, zoneName)
    return MzansiLiving.Spawner.spawnPedAtNode(nodeId, model, archetype, zoneName)
end

function getActivePeds()
    return MzansiLiving.Spawner.getActivePeds()
end

-- Cleanup on resource stop
addEventHandler("onResourceStop", resourceRoot, function()
    for _, ped in ipairs(_activePeds) do
        if isElement(ped) then
            destroyElement(ped)
        end
    end
    _activePeds = {}
end)
