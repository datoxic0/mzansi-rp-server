Mzansi = Mzansi or {}
Mzansi.Jobs = Mzansi.Jobs or {}
Mzansi.Jobs._activeJobs = {}

addEvent("mzansi:jobs:apply", true)
addEvent("mzansi:jobs:quit", true)
addEvent("mzansi:jobs:payday", true)
addEvent("mzansi:jobs:startRoute", true)
addEvent("mzansi:jobs:completeRoute", true)
addEvent("mzansi:jobs:fish", true)
addEvent("mzansi:jobs:startActivity", true)
addEvent("mzansi:jobs:completeStop", true)
addEvent("mzansi:jobs:cancelActivity", true)

-- ==============================================================
-- CROSS-RESOURCE HELPERS (exports only — globals do not cross VMs)
-- ==============================================================
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

function Mzansi.Jobs.applyJob(source, jobId)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    local jobConfig = Mzansi.Config.Jobs[jobId]
    if not jobConfig then
        Mzansi.Util.sendNotification(source, "Invalid job.", "error")
        return false
    end

    if jobConfig.faction and char.faction ~= jobConfig.faction then
        Mzansi.Util.sendNotification(source, "You don't meet the faction requirement.", "error")
        return false
    end

    Mzansi.Characters.setJob(source, jobId)
    Mzansi.Util.sendNotification(source, "You are now working as: " .. jobConfig.name, "success")
    local pName = (char.first_name or char.firstName or "Citizen") .. " " .. (char.last_name or char.lastName or "")
    if Mzansi.Database and Mzansi.Database.logAction then
        pName = string.gsub(pName, "%s+$", "")
        pName = string.len(pName) > 0 and pName or "Unknown"
        Mzansi.Database.logAction("JOB", char.id, pName, "Applied for job", jobConfig.name, "")
    end
    return true
end

function Mzansi.Jobs.quitJob(source)
    local char = Mzansi.Characters.getCharacter(source)
    if not char then return false end

    if char.job == Mzansi.Enums.Job.UNEMPLOYED then
        Mzansi.Util.sendNotification(source, "You don't have a job.", "error")
        return false
    end

    local jobName = Mzansi.Config.Jobs[char.job] and Mzansi.Config.Jobs[char.job].name or "Unknown"
    Mzansi.Characters.setJob(source, Mzansi.Enums.Job.UNEMPLOYED)
    Mzansi.Util.sendNotification(source, "You quit your job as " .. jobName, "info")
    return true
end

function Mzansi.Jobs.payday()
    for _, player in ipairs(getElementsByType("player")) do
        local char = Mzansi.Characters.getCharacter(player)
        if char then
            local jobConfig = Mzansi.Config.Jobs[char.job]
            if jobConfig and jobConfig.pay > 0 then
                local pay = jobConfig.pay
                Mzansi.Characters.addBank(player, pay)
                Mzansi.Util.sendNotification(player, "Payday! You received " .. Mzansi.Util.formatMoney(pay) .. " for " .. jobConfig.name, "success")
                Mzansi.Characters.addXP(player, 100)
            end

            -- P3: prefer reserve policy rate when available (synced into Config.Server.interestRate by reserve_bank)
            local interestRate = Mzansi.Config.Server.interestRate or 0.02
            local interest = math.floor(char.bank * interestRate)
            if interest > 0 then
                Mzansi.Characters.addBank(player, interest)
                Mzansi.Util.sendNotification(player, "Bank interest: " .. Mzansi.Util.formatMoney(interest), "info")
            end
        end
    end
end

function Mzansi.Jobs.startTruckerRoute(source)
    local char = Mzansi.Characters.getCharacter(source)
    if not char or char.job ~= Mzansi.Enums.Job.TRUCKER then
        Mzansi.Util.sendNotification(source, "You are not a trucker.", "error")
        return false
    end

    local vehicle = getPedOccupiedVehicle(source)
    if not vehicle then
        Mzansi.Util.sendNotification(source, "You must be in a truck.", "error")
        return false
    end

    local routes = Mzansi.Jobs.Config.TruckerRoutes
    local route = routes[math.random(1, #routes)]

    Mzansi.Jobs._activeJobs[source] = {
        type = "trucker",
        route = route,
        startTime = getTickCount(),
    }

    local blip = createBlip(route.endX, route.endY, route.endZ, 0, 2, 0, 200, 0)
    setElementData(source, "mzansi:jobBlip", blip)

    Mzansi.Util.sendNotification(source, "Route started: " .. route.name .. " - Pay: " .. Mzansi.Util.formatMoney(route.pay), "info")
    return true
end

function Mzansi.Jobs.completeTruckerRoute(source)
    local job = Mzansi.Jobs._activeJobs[source]
    if not job or job.type ~= "trucker" then
        Mzansi.Util.sendNotification(source, "No active trucking route.", "error")
        return false
    end

    local vehicle = getPedOccupiedVehicle(source)
    if not vehicle then
        Mzansi.Util.sendNotification(source, "You must be in a truck.", "error")
        return false
    end

    local x, y, z = getElementPosition(source)
    local route = job.route
    local dist = Mzansi.Util.distance(x, y, z, route.endX, route.endY, route.endZ)

    if dist > 20 then
        Mzansi.Util.sendNotification(source, "You are not at the delivery point.", "error")
        return false
    end

    Mzansi.Characters.addCash(source, route.pay)
    Mzansi.Characters.addXP(source, 200)
    Mzansi.Util.sendNotification(source, "Delivery complete! You received " .. Mzansi.Util.formatMoney(route.pay), "success")

    local blip = getElementData(source, "mzansi:jobBlip")
    if blip and isElement(blip) then
        destroyElement(blip)
    end

    Mzansi.Jobs._activeJobs[source] = nil
    return true
end

function Mzansi.Jobs.fish(source)
    local char = Mzansi.Characters.getCharacter(source)
    if not char or char.job ~= Mzansi.Enums.Job.FISHERMAN then
        Mzansi.Util.sendNotification(source, "You are not a fisherman.", "error")
        return false
    end

    if not invHas(source, "fishing_rod") then
        Mzansi.Util.sendNotification(source, "You need a fishing rod.", "error")
        return false
    end

    local fishTypes = Mzansi.Jobs.Config.FishTypes
    local caught = nil
    local roll = math.random()

    for _, fish in ipairs(fishTypes) do
        if roll <= fish.chance then
            caught = fish
            break
        end
        roll = roll - fish.chance
    end

    if not caught then
        Mzansi.Util.sendNotification(source, "No fish caught. Try again.", "info")
        return false
    end

    local weight = Mzansi.Util.round(math.random() * (caught.maxWeight - caught.minWeight) + caught.minWeight, 1)
    local pay = math.floor(caught.price * weight)

    invAdd(source, "fish", 1, caught.name .. " (" .. weight .. "kg)")
    Mzansi.Characters.addCash(source, pay)
    Mzansi.Characters.addXP(source, 50)
    Mzansi.Util.sendNotification(source, "Caught a " .. caught.name .. " (" .. weight .. "kg)! Sold for " .. Mzansi.Util.formatMoney(pay), "success")

    return true
end

-- ==============================================================
-- GENERIC ACTIVITY LOOP (taxi, bus, farm, mine, mail, mechanic)
-- ==============================================================
local function clearJobBlip(player)
    local blip = getElementData(player, "mzansi:jobBlip")
    if blip and isElement(blip) then
        destroyElement(blip)
    end
    removeElementData(player, "mzansi:jobBlip")
    removeElementData(player, "mzansi:jobStop")
end

function Mzansi.Jobs.startActivity(player)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return false end

    local jobId = char.job
    local route = Mzansi.Jobs.Config.Activities[jobId]
    if not route or #route == 0 then
        Mzansi.Util.sendNotification(player, "Your job has no active route. Try trucking or fishing.", "error")
        return false
    end

    if Mzansi.Jobs._activeJobs[player] then
        Mzansi.Util.sendNotification(player, "You already have an active job. Finish or cancel it first.", "error")
        return false
    end

    local jobName = Mzansi.Config.Jobs[jobId] and Mzansi.Config.Jobs[jobId].name or "Job"
    Mzansi.Jobs._activeJobs[player] = {
        type = "activity",
        jobId = jobId,
        route = route,
        stopIndex = 1,
        earned = 0,
        startTime = getTickCount(),
    }

    local stop = route[1]
    local blip = createBlip(stop.x, stop.y, stop.z, 0, 2, 255, 200, 0)
    setElementData(player, "mzansi:jobBlip", blip)
    setElementData(player, "mzansi:jobStop", {
        x = stop.x, y = stop.y, z = stop.z,
        name = stop.name, index = 1, total = #route,
    })

    Mzansi.Util.sendNotification(player, jobName .. " shift started! Stop 1/" .. #route .. ": " .. stop.name, "info")
    outputChatBox("#FFC850[JOB] #FFFFFFHead to the yellow blip: #FFC850" .. stop.name, player, 255, 255, 255, true)
    return true
end

function Mzansi.Jobs.completeStop(player)
    local job = Mzansi.Jobs._activeJobs[player]
    if not job or job.type ~= "activity" then
        Mzansi.Util.sendNotification(player, "No active job route. Type /job work to start.", "error")
        return false
    end

    local route = job.route
    local stop = route[job.stopIndex]
    if not stop then
        Mzansi.Jobs.cancelActivity(player, true)
        return false
    end

    local px, py, pz = getElementPosition(player)
    local dist = Mzansi.Util.distance(px, py, pz, stop.x, stop.y, stop.z)
    local reach = Mzansi.Jobs.Config.ActivityReach or 12.0
    if dist > reach then
        Mzansi.Util.sendNotification(player, "You are not at the job point (" .. math.floor(dist) .. "m away).", "error")
        return false
    end

    if stop.requiresVehicle then
        local veh = getPedOccupiedVehicle(player)
        if not veh then
            Mzansi.Util.sendNotification(player, "You must be in a vehicle for this stop.", "error")
            return false
        end
    end

    local pay = stop.pay or 0
    if pay > 0 then
        Mzansi.Characters.addCash(player, pay)
        job.earned = job.earned + pay
    end
    Mzansi.Characters.addXP(player, 75)

    Mzansi.Util.sendNotification(player, "Completed: " .. stop.name .. " (+ " .. Mzansi.Util.formatMoney(pay) .. ")", "success")

    job.stopIndex = job.stopIndex + 1

    if job.stopIndex > #route then
        local total = job.earned
        local elapsed = math.floor((getTickCount() - job.startTime) / 1000)
        outputChatBox("#00CC66[JOB] #FFFFFFShift complete! Earned #00CC66" .. Mzansi.Util.formatMoney(total) ..
            "#FFFFFF in " .. Mzansi.Util.formatTime(elapsed), player, 255, 255, 255, true)
        Mzansi.Util.sendNotification(player, "Shift complete! Total earned: " .. Mzansi.Util.formatMoney(total), "success")
        clearJobBlip(player)
        Mzansi.Jobs._activeJobs[player] = nil
        return true
    end

    local nextStop = route[job.stopIndex]
    local blip = getElementData(player, "mzansi:jobBlip")
    if blip and isElement(blip) then
        setElementPosition(blip, nextStop.x, nextStop.y, nextStop.z)
    else
        blip = createBlip(nextStop.x, nextStop.y, nextStop.z, 0, 2, 255, 200, 0)
        setElementData(player, "mzansi:jobBlip", blip)
    end
    setElementData(player, "mzansi:jobStop", {
        x = nextStop.x, y = nextStop.y, z = nextStop.z,
        name = nextStop.name, index = job.stopIndex, total = #route,
    })
    outputChatBox("#FFC850[JOB] #FFFFFFStop " .. job.stopIndex .. "/" .. #route .. ": #FFC850" .. nextStop.name, player, 255, 255, 255, true)
    return true
end

function Mzansi.Jobs.cancelActivity(player, silent)
    local job = Mzansi.Jobs._activeJobs[player]
    if not job then
        if not silent then
            Mzansi.Util.sendNotification(player, "No active job to cancel.", "error")
        end
        return false
    end
    clearJobBlip(player)
    Mzansi.Jobs._activeJobs[player] = nil
    if not silent then
        Mzansi.Util.sendNotification(player, "Job route cancelled. Earned so far: " .. Mzansi.Util.formatMoney(job.earned or 0), "info")
    end
    return true
end

addEventHandler("mzansi:jobs:startActivity", root, function()
    local player = client or source
    Mzansi.Jobs.startActivity(player)
end)

addEventHandler("mzansi:jobs:completeStop", root, function()
    local player = client or source
    Mzansi.Jobs.completeStop(player)
end)

addEventHandler("mzansi:jobs:cancelActivity", root, function()
    local player = client or source
    Mzansi.Jobs.cancelActivity(player)
end)

addEventHandler("onPlayerQuit", root, function()
    clearJobBlip(source)
    Mzansi.Jobs._activeJobs[source] = nil
end)

addEventHandler("mzansi:jobs:apply", root, function(jobId)
    local source = client or source
    Mzansi.Jobs.applyJob(source, jobId)
end)

addEventHandler("mzansi:jobs:quit", root, function()
    local source = client or source
    Mzansi.Jobs.quitJob(source)
end)

addEventHandler("mzansi:jobs:startRoute", root, function()
    local source = client or source
    Mzansi.Jobs.startTruckerRoute(source)
end)

addEventHandler("mzansi:jobs:completeRoute", root, function()
    local source = client or source
    Mzansi.Jobs.completeTruckerRoute(source)
end)

addEventHandler("mzansi:jobs:fish", root, function()
    local source = client or source
    Mzansi.Jobs.fish(source)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    local interval = (Mzansi.Jobs.Config and tonumber(Mzansi.Jobs.Config.PaydayInterval)) or 3600000
    setTimer(Mzansi.Jobs.payday, interval, 0)
    outputDebugString("[Mzansi-Jobs] Job system loaded (activities: taxi/bus/farm/mine/mail/mechanic + trucker/fishing).")
end)
