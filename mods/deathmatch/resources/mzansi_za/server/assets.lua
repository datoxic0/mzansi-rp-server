Mzansi = Mzansi or {}
Mzansi.Assets = Mzansi.Assets or {}

Mzansi.Assets.VehiclePool = {
    "Sultan",
    "Banshee",
    "Sentinel",
    "Taxi",
    "Roadtrain",
}

Mzansi.Assets.BuildingPool = {
    "Johannesburg CBD",
    "Cape Town Waterfront",
    "Durban Harbour",
    "Pretoria Government Complex",
}

function Mzansi.Assets.listVehicles()
    return Mzansi.Assets.VehiclePool
end

function Mzansi.Assets.listBuildings()
    return Mzansi.Assets.BuildingPool
end
