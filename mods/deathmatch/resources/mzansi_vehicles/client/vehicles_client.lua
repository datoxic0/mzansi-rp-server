Mzansi = Mzansi or {}
Mzansi.Vehicles = Mzansi.Vehicles or {}

local function getElementSpeed(element, unit)
    if not isElement(element) then return 0 end
    unit = unit or "kmh"
    local vx, vy, vz = getElementVelocity(element)
    if not vx then return 0 end
    local speed = (vx * vx + vy * vy + vz * vz) ^ 0.5
    if unit == "kmh" or unit == 1 or unit == "kph" then
        return speed * 180
    elseif unit == "mph" or unit == 2 then
        return speed * 111.847
    else
        return speed
    end
end

-- Angel: Vehicle Fuel Consumption Monitor
Mzansi.Vehicles._fuelThread = nil
Mzansi.Vehicles._speedLimiter = true

addEvent("mzansi:vehicles:syncFuel", true)
addEvent("mzansi:vehicles:syncDamage", true)

function Mzansi.Vehicles.startFuelSystem()
    if Mzansi.Vehicles._fuelThread then return end
    Mzansi.Vehicles._fuelThread = setTimer(function()
        local vehicle = getPedOccupiedVehicle(localPlayer)
        if not vehicle then return end

        local engine = getVehicleEngineState(vehicle)
        if not engine then return end

        local fuel = getElementData(vehicle, "mzansi:fuel") or 100
        local speed = getElementSpeed(vehicle, "kmh")
        local consumption = Mzansi.Config.Vehicles.fuelConsumptionRate * (1 + speed / 200)
        fuel = fuel - consumption

        if fuel <= 0 then
            fuel = 0
            setVehicleEngineState(vehicle, false)
            Mzansi.Util.notify("Out of fuel!", "error")
        end

        setElementData(vehicle, "mzansi:fuel", fuel)
    end, 5000, 0)
end

function Mzansi.Vehicles.stopFuelSystem()
    if Mzansi.Vehicles._fuelThread then
        killTimer(Mzansi.Vehicles._fuelThread)
        Mzansi.Vehicles._fuelThread = nil
    end
end

function Mzansi.Vehicles.lock()
    triggerServerEvent("mzansi:vehicles:lock", localPlayer)
end

function Mzansi.Vehicles.engine()
    triggerServerEvent("mzansi:vehicles:engine", localPlayer)
end

function Mzansi.Vehicles.respawn()
    triggerServerEvent("mzansi:vehicles:respawn", localPlayer)
end

function Mzansi.Vehicles.refuel()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then
        Mzansi.Util.notify("You must be in a vehicle.", "error")
        return
    end

    local fuel = getElementData(vehicle, "mzansi:fuel") or 0
    if fuel >= 100 then
        Mzansi.Util.notify("Fuel tank is full.", "info")
        return
    end

    triggerServerEvent("mzansi:vehicles:refuel", localPlayer)
end

function Mzansi.Vehicles.fuelHUD()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return end

    local fuel = getElementData(vehicle, "mzansi:fuel") or 100
    if fuel > 20 then return end

    local screenW, screenH = guiGetScreenSize()
    local alpha = math.sin(getTickCount() / 300) * 50 + 200

    dxDrawText("LOW FUEL: " .. math.floor(fuel) .. "%", screenW / 2 - 100, screenH - 200, screenW / 2 + 100, screenH - 180, tocolor(255, 150, 0, alpha), 1.2, "default-bold", "center", "center")
end

addEventHandler("onClientPlayerVehicleEnter", localPlayer, function(vehicle)
    Mzansi.Vehicles.startFuelSystem()
end)

addEventHandler("onClientPlayerVehicleExit", localPlayer, function(vehicle)
    Mzansi.Vehicles.stopFuelSystem()
end)

addEventHandler("onClientRender", root, function()
    Mzansi.Vehicles.fuelHUD()
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Vehicles] Vehicle client loaded.")
end)

-- lock/engine/refuel commands are SERVER-owned (mzansi_core/server/vehicles.lua)
-- to prevent double-toggle: client command -> triggerServerEvent AND server
-- command handler would both fire on one keystroke.
addCommandHandler("respawn", Mzansi.Vehicles.respawn)
