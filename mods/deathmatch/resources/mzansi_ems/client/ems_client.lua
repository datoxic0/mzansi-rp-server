Mzansi = Mzansi or {}
Mzansi.EMS = Mzansi.EMS or {}

Mzansi.EMS._downMarker = nil
Mzansi.EMS._downBlip = nil

addEvent("mzansi:ems:downMarker", true)

function Mzansi.EMS.isMedic()
    local char = getElementData(localPlayer, "mzansi:character")
    return char and char.faction == Mzansi.Enums.Faction.EMS
end

function isMedic()
    return Mzansi.EMS.isMedic() or false
end

function Mzansi.EMS.healPlayer(target)
    if not Mzansi.EMS.isMedic() then return end
    if not target then
        target = Mzansi.EMS.getClosestPlayer(5) or localPlayer
    end
    if target then
        triggerServerEvent("mzansi:ems:heal", localPlayer, target)
    else
        Mzansi.Util.notify("No patient nearby.", "error")
    end
end

function Mzansi.EMS.revivePlayer(target)
    if not Mzansi.EMS.isMedic() then return end
    if not target then
        target = Mzansi.EMS.getClosestPlayer(5) or localPlayer
    end
    if target then
        triggerServerEvent("mzansi:ems:revive", localPlayer, target)
    else
        Mzansi.Util.notify("No patient nearby.", "error")
    end
end

function Mzansi.EMS.loadIntoAmbulance(target)
    if not Mzansi.EMS.isMedic() then return end
    if not target then
        target = Mzansi.EMS.getClosestPlayer(10)
    end
    if target then
        triggerServerEvent("mzansi:ems:loadInAmbulance", localPlayer, target)
    else
        Mzansi.Util.notify("No patient nearby.", "error")
    end
end

function Mzansi.EMS.getClosestPlayer(range)
    local closest = nil
    local closestDist = range or 5
    local px, py, pz = getElementPosition(localPlayer)
    for _, player in ipairs(getElementsByType("player")) do
        if player ~= localPlayer then
            local tx, ty, tz = getElementPosition(player)
            local dist = Mzansi.Util.distance(px, py, pz, tx, ty, tz)
            if dist < closestDist then
                closest = player
                closestDist = dist
            end
        end
    end
    return closest
end

function Mzansi.EMS.renderDownMarker()
    if not Mzansi.EMS._downMarker then return end
    if not Mzansi.EMS.isMedic() then return end

    local x, y, z = Mzansi.EMS._downMarker.x, Mzansi.EMS._downMarker.y, Mzansi.EMS._downMarker.z
    local px, py, pz = getElementPosition(localPlayer)
    local dist = Mzansi.Util.distance(px, py, pz, x, y, z)

    if dist < 5 then
        local sx, sy = getScreenFromWorldPosition(x, y, z + 1)
        if sx and sy then
            dxDrawText("[E] Revive Patient", sx - 50, sy - 10, sx + 50, sy + 10, tocolor(255, 50, 50, 200), 1.5, "default-bold", "center", "center")
        end
    end

    if dist < 100 then
        local pulse = math.sin(getTickCount() / 300) * 0.3 + 0.7
        dxDrawCircle3D(x, y, z + 1, 1, tocolor(255, 0, 0, pulse * 100))
    end
end

addEventHandler("mzansi:ems:downMarker", root, function(x, y, z, name)
    Mzansi.EMS._downMarker = { x = x, y = y, z = z, name = name }

    if Mzansi.EMS._downBlip then
        destroyElement(Mzansi.EMS._downBlip)
    end
    Mzansi.EMS._downBlip = createBlip(x, y, z, 0, 2, 255, 0, 0)
    setBlipColor(Mzansi.EMS._downBlip, 255, 0, 0)

    setTimer(function()
        if Mzansi.EMS._downBlip and isElement(Mzansi.EMS._downBlip) then
            destroyElement(Mzansi.EMS._downBlip)
            Mzansi.EMS._downBlip = nil
        end
        Mzansi.EMS._downMarker = nil
    end, 60000, 1)
end)

addEventHandler("onClientRender", root, function()
    if Mzansi.EMS.isMedic() then
        Mzansi.EMS.renderDownMarker()
    end
end)

addCommandHandler("heal", function()
    Mzansi.EMS.healPlayer()
end)

addCommandHandler("revive", function()
    Mzansi.EMS.revivePlayer()
end)

addCommandHandler("loadambulance", function()
    Mzansi.EMS.loadIntoAmbulance()
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-EMS] EMS client loaded.")
end)
