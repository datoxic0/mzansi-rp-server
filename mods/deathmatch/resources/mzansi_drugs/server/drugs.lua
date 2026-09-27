Mzansi = Mzansi or {}
Mzansi.Drugs = Mzansi.Drugs or {}
Mzansi.Drugs._plots = {}
Mzansi.Drugs._addiction = {}
Mzansi.Drugs._activeEffects = {}

local function invHas(player, item, qty)
    local res = getResourceFromName("mzansi_inventory")
    if res and getResourceState(res) == "running" then
        local ok, result = pcall(function()
            return exports.mzansi_inventory:hasItem(player, item, qty or 1)
        end)
        if ok then return result end
    end
    return false
end

local function invAdd(player, item, qty, meta)
    local res = getResourceFromName("mzansi_inventory")
    if res and getResourceState(res) == "running" then
        local ok, result = pcall(function()
            return exports.mzansi_inventory:addItem(player, item, qty or 1, meta)
        end)
        if ok then return result end
    end
    return false
end

local function invRemove(player, item, qty)
    local res = getResourceFromName("mzansi_inventory")
    if res and getResourceState(res) == "running" then
        local ok, result = pcall(function()
            return exports.mzansi_inventory:removeItem(player, item, qty or 1)
        end)
        if ok then return result end
    end
    return false
end

addEvent("mzansi:drugs:plant", true)
addEvent("mzansi:drugs:harvest", true)
addEvent("mzansi:drugs:use", true)
addEvent("mzansi:drugs:sell", true)
addEvent("mzansi:drugs:traffic", true)
addEvent("mzansi:drugs:process", true)
addEvent("mzansi:drugs:getPlots", true)
addEvent("mzansi:drugs:getInventory", true)

function Mzansi.Drugs.init()
    for _, loc in ipairs(Mzansi.Drugs.Config.GrowLocations) do
        Mzansi.Drugs._plots[loc.id] = {
            id = loc.id,
            name = loc.name,
            x = loc.x,
            y = loc.y,
            z = loc.z,
            radius = loc.radius,
            slots = loc.slots,
            plants = {},
        }
    end

    outputDebugString("[Mzansi-Drugs] Drug system initialized.")
end

function Mzansi.Drugs.plantSeed(source, drugId, locationId)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local drug = nil
    for _, d in ipairs(Mzansi.Drugs.Config.Drugs) do
        if d.id == drugId then
            drug = d
            break
        end
    end

    if not drug then
        Mzansi.Util.sendNotification(source, "Invalid drug type.", "error")
        return false
    end

    if not invHas(source, drugId .. "_seed") then
        Mzansi.Util.sendNotification(source, "You need " .. drug.name .. " seeds.", "error")
        return false
    end

    local plot = Mzansi.Drugs._plots[locationId]
    if not plot then
        Mzansi.Util.sendNotification(source, "Invalid grow location.", "error")
        return false
    end

    local x, y, z = getElementPosition(source)
    if Mzansi.Util.distance(x, y, z, plot.x, plot.y, plot.z) > plot.radius then
        Mzansi.Util.sendNotification(source, "Not at grow location.", "error")
        return false
    end

    local plantCount = 0
    for _ in pairs(plot.plants) do
        plantCount = plantCount + 1
    end

    if plantCount >= plot.slots then
        Mzansi.Util.sendNotification(source, "No available slots.", "error")
        return false
    end

    local plantId = #plot.plants + 1
    plot.plants[plantId] = {
        id = plantId,
        drugId = drugId,
        plantedBy = char.id,
        plantedAt = getRealTime().timestamp,
        growth = 0,
        ready = false,
        x = plot.x + math.random(-plot.radius, plot.radius),
        y = plot.y + math.random(-plot.radius, plot.radius),
        z = plot.z,
    }

    invRemove(source, drugId .. "_seed", 1)
    Mzansi.Util.sendNotification(source, "Planted " .. drug.name .. " seed.", "success")

    setTimer(function()
        Mzansi.Drugs.growPlant(locationId, plantId)
    end, drug.growTime, 1)

    return true
end

function Mzansi.Drugs.growPlant(locationId, plantId)
    local plot = Mzansi.Drugs._plots[locationId]
    if not plot then return end

    local plant = plot.plants[plantId]
    if not plant then return end

    plant.growth = 100
    plant.ready = true

    outputDebugString("[Mzansi-Drugs] Plant ready at " .. plot.name)
end

function Mzansi.Drugs.harvestPlant(source, locationId, plantId)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local plot = Mzansi.Drugs._plots[locationId]
    if not plot then return false end

    local plant = plot.plants[plantId]
    if not plant then return false end

    if not plant.ready then
        Mzansi.Util.sendNotification(source, "Plant not ready yet.", "error")
        return false
    end

    local x, y, z = getElementPosition(source)
    if Mzansi.Util.distance(x, y, z, plant.x, plant.y, plant.z) > 5 then
        Mzansi.Util.sendNotification(source, "Too far from plant.", "error")
        return false
    end

    local drug = nil
    for _, d in ipairs(Mzansi.Drugs.Config.Drugs) do
        if d.id == plant.drugId then
            drug = d
            break
        end
    end

    if not drug then return false end

    local amount = math.random(drug.harvestAmount.min, drug.harvestAmount.max)
    invAdd(source, plant.drugId, amount)
    Mzansi.Characters.addXP(source, 100)

    Mzansi.Util.sendNotification(source, "Harvested " .. amount .. "x " .. drug.name, "success")

    plot.plants[plantId] = nil
    return true
end

function Mzansi.Drugs.useDrug(source, drugId)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    if not invHas(source, drugId) then
        Mzansi.Util.sendNotification(source, "You don't have this drug.", "error")
        return false
    end

    local effect = Mzansi.Drugs.Config.Effects[drugId]
    if not effect then return false end

    invRemove(source, drugId, 1)

    if not Mzansi.Drugs._addiction[source] then
        Mzansi.Drugs._addiction[source] = {}
    end

    local drug = nil
    for _, d in ipairs(Mzansi.Drugs.Config.Drugs) do
        if d.id == drugId then
            drug = d
            break
        end
    end

    if drug then
        Mzansi.Drugs._addiction[source][drugId] = (Mzansi.Drugs._addiction[source][drugId] or 0) + drug.addiction
    end

    Mzansi.Drugs._activeEffects[source] = {
        drugId = drugId,
        effect = effect,
        startTime = getTickCount(),
        duration = effect.duration,
    }
    setElementData(source, "mzansi:drugEffect", drugId)

    if effect.healthRegen > 0 then
        setElementHealth(source, math.min(100, getElementHealth(source) + effect.healthRegen * 5))
    end

    if effect.speedMod ~= 1.0 then
        setPedWalkingStyle(source, effect.speedMod > 1 and 128 or 0)
    end

    Mzansi.Util.sendNotification(source, effect.message, "info")
    Mzansi.Characters.addXP(source, 50)

    setTimer(function()
        Mzansi.Drugs.clearEffect(source)
    end, effect.duration, 1)

    return true
end

function Mzansi.Drugs.clearEffect(source)
    local effect = Mzansi.Drugs._activeEffects[source]
    if not effect then return end

    if isElement(source) then
        setPedWalkingStyle(source, 0)
        removeElementData(source, "mzansi:drugEffect")
        Mzansi.Util.sendNotification(source, "Drug effects wore off.", "info")
    end
    Mzansi.Drugs._activeEffects[source] = nil
end

function Mzansi.Drugs.sellDrugs(source, drugId, amount)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    amount = tonumber(amount) or 1

    if not invHas(source, drugId, amount) then
        Mzansi.Util.sendNotification(source, "You don't have enough.", "error")
        return false
    end

    local drug = nil
    for _, d in ipairs(Mzansi.Drugs.Config.Drugs) do
        if d.id == drugId then
            drug = d
            break
        end
    end

    if not drug then return false end

    local totalPay = drug.sellPrice * amount
    invRemove(source, drugId, amount)
    Mzansi.Characters.addCash(source, totalPay)
    Mzansi.Characters.addXP(source, 150 * amount)

    Mzansi.Util.sendNotification(source, "Sold " .. amount .. "x " .. drug.name .. " for " .. Mzansi.Util.formatMoney(totalPay), "success")
    Mzansi.Database.logAction("DRUGS", char.id, char.firstName .. " " .. char.lastName, "Sold drugs", drug.name .. " x" .. amount .. " for " .. Mzansi.Util.formatMoney(totalPay), "")

    setElementData(source, "mzansi:wantedLevel", (getElementData(source, "mzansi:wantedLevel") or 0) + 1)
    return true
end

function Mzansi.Drugs.startTrafficRun(source, routeId)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local route = nil
    for _, r in ipairs(Mzansi.Drugs.Config.TrafficRoutes) do
        if r.id == routeId then
            route = r
            break
        end
    end

    if not route then return false end

    local x, y, z = getElementPosition(source)
    if Mzansi.Util.distance(x, y, z, route.start.x, route.start.y, route.start.z) > 30 then
        Mzansi.Util.sendNotification(source, "Not at traffic start point.", "error")
        return false
    end

    local dropoff = route.dropoffs[math.random(1, #route.dropoffs)]

    local blip = createBlip(dropoff.x, dropoff.y, dropoff.z, 0, 2, 255, 0, 255)
    setTimer(function()
        if isElement(blip) then destroyElement(blip) end
    end, 300000, 1)

    Mzansi.Util.sendNotification(source, "Traffic run: " .. route.name .. " - Deliver to " .. dropoff.name, "info")

    setTimer(function()
        if isElement(source) then
            local px, py, pz = getElementPosition(source)
            if Mzansi.Util.distance(px, py, pz, dropoff.x, dropoff.y, dropoff.z) < 15 then
                Mzansi.Characters.addCash(source, dropoff.pay)
                Mzansi.Characters.addXP(source, 400)
                Mzansi.Util.sendNotification(source, "Delivery complete! " .. Mzansi.Util.formatMoney(dropoff.pay), "success")
                setElementData(source, "mzansi:wantedLevel", (getElementData(source, "mzansi:wantedLevel") or 0) + 2)
            else
                Mzansi.Util.sendNotification(source, "Delivery failed. Too far from drop point.", "error")
            end
        end
    end, 300000, 1)

    return true
end

function Mzansi.Drugs.processDrugs(source, processId)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local process = nil
    for _, p in ipairs(Mzansi.Drugs.Config.Processing) do
        if p.id == processId then
            process = p
            break
        end
    end

    if not process then return false end

    local x, y, z = getElementPosition(source)
    if Mzansi.Util.distance(x, y, z, process.location.x, process.location.y, process.location.z) > 20 then
        Mzansi.Util.sendNotification(source, "Not at processing location.", "error")
        return false
    end

    if not invHas(source, process.input.drug, process.input.amount) then
        Mzansi.Util.sendNotification(source, "Need " .. process.input.amount .. "x " .. process.input.drug, "error")
        return false
    end

    invRemove(source, process.input.drug, process.input.amount)

    setTimer(function()
        if isElement(source) then
            invAdd(source, process.output.drug, process.output.amount)
            Mzansi.Util.sendNotification(source, "Processing complete! " .. process.output.amount .. "x " .. process.output.drug, "success")
            Mzansi.Characters.addXP(source, 200)
        end
    end, process.time, 1)

    Mzansi.Util.sendNotification(source, "Processing... " .. process.name, "info")
    return true
end

addEventHandler("mzansi:drugs:plant", root, function(drugId, locationId)
    local source = client or source
    Mzansi.Drugs.plantSeed(source, drugId, locationId)
end)

addEventHandler("mzansi:drugs:harvest", root, function(locationId, plantId)
    local source = client or source
    Mzansi.Drugs.harvestPlant(source, locationId, plantId)
end)

addEventHandler("mzansi:drugs:use", root, function(drugId)
    local source = client or source
    Mzansi.Drugs.useDrug(source, drugId)
end)

addEventHandler("mzansi:drugs:sell", root, function(drugId, amount)
    local source = client or source
    Mzansi.Drugs.sellDrugs(source, drugId, amount)
end)

addEventHandler("mzansi:drugs:traffic", root, function(routeId)
    local source = client or source
    Mzansi.Drugs.startTrafficRun(source, routeId)
end)

addEventHandler("mzansi:drugs:process", root, function(processId)
    local source = client or source
    Mzansi.Drugs.processDrugs(source, processId)
end)

addEventHandler("onPlayerQuit", root, function()
    Mzansi.Drugs._activeEffects[source] = nil
    Mzansi.Drugs._addiction[source] = nil
end)

addEventHandler("onResourceStart", resourceRoot, function()
    Mzansi.Drugs.init()
end)
