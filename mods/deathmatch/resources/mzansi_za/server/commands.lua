Mzansi = Mzansi or {}
Mzansi.Commands = Mzansi.Commands or {}

local function openBank(player)
    triggerClientEvent(player, "mzansi:openUI", player, Mzansi.Enums.UI.BANK)
end

local function openMdt(player)
    triggerClientEvent(player, "mzansi:openUI", player, Mzansi.Enums.UI.MDT)
end

local function openProperty(player)
    triggerClientEvent(player, "mzansi:openUI", player, Mzansi.Enums.UI.PROPERTY)
end

addCommandHandler("bank", function(player)
    if Mzansi.Player.authenticate(player) then
        openBank(player)
    end
end)

addCommandHandler("mdt", function(player)
    if Mzansi.Player.authenticate(player) then
        openMdt(player)
    end
end)

addCommandHandler("register", function(player)
    triggerClientEvent(player, "mzansi:openRegister", player)
end)

addCommandHandler("property", function(player)
    if Mzansi.Player.authenticate(player) then
        openProperty(player)
    end
end)

addCommandHandler("spawn", function(player)
    if Mzansi.Player.authenticate(player) then
        Mzansi.Spawn.spawnPlayer(player, "city")
    end
end)

addCommandHandler("mza", function(player, cmd, action)
    if action == "bank" then
        openBank(player)
    elseif action == "mdt" then
        openMdt(player)
    elseif action == "spawn" then
        Mzansi.Spawn.spawnPlayer(player, "city")
    elseif action == "property" then
        openProperty(player)
    end
end)
