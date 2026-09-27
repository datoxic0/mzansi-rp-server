Mzansi = Mzansi or {}
Mzansi.Vehicles = Mzansi.Vehicles or {}

Mzansi.Vehicles.Pool = {
    {
        id = 1,
        name = "Toyota Corolla Quest",
        class = "Civilian",
        region = "Johannesburg",
        model = 562,
        color = "White",
    },
    {
        id = 2,
        name = "VW Polo Vivo",
        class = "Civilian",
        region = "Cape Town",
        model = 496,
        color = "Silver",
    },
    {
        id = 3,
        name = "Ford Ranger XL",
        class = "Utility",
        region = "Pretoria",
        model = 577,
        color = "Blue",
    },
    {
        id = 4,
        name = "Mini Cooper S",
        class = "Lifestyle",
        region = "Durban",
        model = 458,
        color = "Black",
    },
    {
        id = 5,
        name = "Toyota Hilux",
        class = "Business",
        region = "Gqeberha",
        model = 571,
        color = "Orange",
    },
}

function Mzansi.Vehicles.getVehiclesByRegion(region)
    local result = {}
    for _, veh in ipairs(Mzansi.Vehicles.Pool) do
        if not region or veh.region == region then
            table.insert(result, veh)
        end
    end
    return result
end

addEvent("mzansi:vehicles:list", true)
addEventHandler("mzansi:vehicles:list", root, function(region)
    triggerClientEvent(client, "mzansi:vehicles:response", client, Mzansi.Vehicles.getVehiclesByRegion(region))
end)
