Mzansi = Mzansi or {}
Mzansi.World = {}
Mzansi.World._markers = {}
Mzansi.World._blips = {}
Mzansi.World._rentalVehicles = {}

-- ==============================================================
-- WORLD LOCATIONS — All major RP points
-- ==============================================================
local LOCATIONS = {
    AIRPORT_SPAWN   = { x = 1682.5,  y = -2267.0, z = 13.5,  name = "Los Santos International Airport" },
    AIRPORT_RENTAL  = { x = 1665.0,  y = -2246.0, z = 13.8,  name = "Airport Starter Rentals" },
    SAPS_HQ         = { x = 1547.5,  y = -1675.5, z = 13.5,  name = "SAPS Police Headquarters" },
    EMS_HOSPITAL    = { x = 1176.8,  y = -1323.0, z = 13.5,  name = "All Saints General Hospital" },
    CITY_HALL       = { x = 1481.5,  y = -1745.5, z = 13.5,  name = "City Hall & Job Center" },
    CENTRAL_BANK    = { x = 1460.0,  y = -1025.0, z = 23.5,  name = "Standard Bank — Central" },
    DEALERSHIP      = { x = 2131.5,  y = -1150.5, z = 24.0,  name = "Mzansi Auto Dealership" },
    AMMUNATION      = { x = 1368.5,  y = -1279.5, z = 13.5,  name = "Ammu-Nation Firearms" },
    TRUCKER_DEPOT   = { x = -532.5,  y = -488.5,  z = 25.5,  name = "Ocean Docks Trucking Depot" },
    FISHING_PIER    = { x = 385.0,   y = -2088.0, z = 7.8,   name = "Santa Maria Fishing Pier" },
    TAXI_RANK       = { x = 1778.0,  y = -1860.0, z = 13.5,  name = "Commerce Taxi Rank" },
    REPAIR_BAY      = { x = 1505.8,  y = -1664.2, z = 13.4,  name = "Johannesburg Auto Repair" },
    VINEWOOD        = { x = 610.0,   y = -1272.5, z = 19.5,  name = "Vinewood District" },
    PARACHUTE_DROP  = { x = 1680.0,  y = -2270.0, z = 50.0,  name = "Parachute Drop Zone (Airport)" },
    -- Gang Strongholds (Distributed across 3 Provinces)
    GANG_SSK        = { x = 2244.5,  y = -1665.5, z = 15.5,  name = "South Side Kings (Cape Town - Ganton)" },
    GANG_CD         = { x = 1920.5,  y = -1760.5, z = 13.5,  name = "Crazy Dragons (Cape Town - Market)" },
    GANG_28S        = { x = 1950.0,  y = -1450.0, z = 13.5,  name = "Cape Flats 28s (Cape Town - Idlewood)" },
    GANG_ZW         = { x = -2160.5, y = -235.5,  z = 36.5,  name = "Zulu Warriors (Durban - Garcia Hostels)" },
    GANG_ZW_DOCKS   = { x = -1600.0, y = 150.0,   z = 10.5,  name = "Zulu Warriors (Durban Harbour Basin)" },
    GANG_BM         = { x = 2270.5,  y = 1430.5,  z = 11.5,  name = "Boere Mafia (Jozi - Redsands East)" },
    GANG_NDC        = { x = 2480.5,  y = 2110.5,  z = 11.0,  name = "Nyau Dust Cartel (Jozi - Old Venturas)" },
    DRUG_LAB_1      = { x = 1975.0,  y = -1800.0, z = 13.5,  name = "Illicit Drug Lab (Idlewood)" },
    DRUG_LAB_2      = { x = 2270.0,  y = -1660.0, z = 13.5,  name = "Crack House (Ganton)" },
    STORAGE_UNIT    = { x = 2450.0,  y = -1600.0, z = 13.5,  name = "Ganton Storage Units" },
    BEACH           = { x = 360.0,   y = -2090.0, z = 3.0,   name = "Santa Maria Beach" },
    CASINO          = { x = 2031.0,  y = -1894.0, z = 13.5,  name = "Four Dragons Casino (LS)" },
}

-- ==============================================================
-- WORLD INIT — Blips, Markers, Faction Vehicles
-- ==============================================================
function Mzansi.World.init()
    outputDebugString("[Mzansi-World] Initializing full-scale roleplay world...")

    -- ============================
    -- RADAR MAP BLIPS
    -- ============================
    -- Emergency Services
    createBlip(LOCATIONS.SAPS_HQ.x,      LOCATIONS.SAPS_HQ.y,      LOCATIONS.SAPS_HQ.z,      30, 2, 255, 0,   0,   255, 0, 500)  -- Police star
    createBlip(LOCATIONS.EMS_HOSPITAL.x,  LOCATIONS.EMS_HOSPITAL.y,  LOCATIONS.EMS_HOSPITAL.z,  22, 2, 255, 255, 255, 255, 0, 500)  -- Hospital cross
    createBlip(LOCATIONS.AIRPORT_SPAWN.x, LOCATIONS.AIRPORT_SPAWN.y, LOCATIONS.AIRPORT_SPAWN.z, 16, 2, 0,   200, 255, 255, 0, 500)  -- Plane icon

    -- Civic / Commerce
    createBlip(LOCATIONS.CITY_HALL.x,     LOCATIONS.CITY_HALL.y,     LOCATIONS.CITY_HALL.z,     56, 2, 255, 215, 0,   255, 0, 500)  -- Briefcase
    createBlip(LOCATIONS.CENTRAL_BANK.x,  LOCATIONS.CENTRAL_BANK.y,  LOCATIONS.CENTRAL_BANK.z,  52, 2, 0,   255, 100, 255, 0, 500)  -- Dollar sign
    createBlip(LOCATIONS.DEALERSHIP.x,    LOCATIONS.DEALERSHIP.y,    LOCATIONS.DEALERSHIP.z,    55, 2, 0,   200, 255, 255, 0, 500)  -- Car
    createBlip(LOCATIONS.AMMUNATION.x,    LOCATIONS.AMMUNATION.y,    LOCATIONS.AMMUNATION.z,    6,  2, 255, 100, 0,   255, 0, 500)  -- Gun
    createBlip(LOCATIONS.TRUCKER_DEPOT.x, LOCATIONS.TRUCKER_DEPOT.y, LOCATIONS.TRUCKER_DEPOT.z, 51, 2, 200, 150, 50,  255, 0, 500)  -- Truck
    createBlip(LOCATIONS.TAXI_RANK.x,     LOCATIONS.TAXI_RANK.y,     LOCATIONS.TAXI_RANK.z,     8,  2, 255, 255, 0,   255, 0, 450)  -- Yellow cab
    createBlip(LOCATIONS.FISHING_PIER.x,  LOCATIONS.FISHING_PIER.y,  LOCATIONS.FISHING_PIER.z,  9,  2, 0,   180, 255, 255, 0, 500)  -- Fish
    createBlip(LOCATIONS.REPAIR_BAY.x,    LOCATIONS.REPAIR_BAY.y,    LOCATIONS.REPAIR_BAY.z,    27, 2, 255, 150, 0,   255, 0, 450)  -- Mechanic wrench
    createBlip(LOCATIONS.AIRPORT_RENTAL.x,LOCATIONS.AIRPORT_RENTAL.y,LOCATIONS.AIRPORT_RENTAL.z,55, 2, 50,  220, 50,  255, 0, 450)  -- Rental vehicle
    createBlip(LOCATIONS.CASINO.x,        LOCATIONS.CASINO.y,        LOCATIONS.CASINO.z,        2,  2, 255, 215, 0,   255, 0, 400)  -- Casino star
    createBlip(LOCATIONS.BEACH.x,         LOCATIONS.BEACH.y,         LOCATIONS.BEACH.z,         0,  2, 0,   200, 255, 255, 0, 350)  -- General icon

    -- Cape Town Gang Blips
    createBlip(LOCATIONS.GANG_SSK.x,  LOCATIONS.GANG_SSK.y,  LOCATIONS.GANG_SSK.z,  19, 2, 30,  144, 255, 255, 0, 350)  -- SSK Blue
    createBlip(LOCATIONS.GANG_CD.x,   LOCATIONS.GANG_CD.y,   LOCATIONS.GANG_CD.z,   19, 2, 255, 50,  50,  255, 0, 350)  -- CD Red
    createBlip(LOCATIONS.GANG_28S.x,  LOCATIONS.GANG_28S.y,  LOCATIONS.GANG_28S.z,  19, 2, 255, 200, 0,   255, 0, 350)  -- 28s Gold

    -- Durban Gang Blips
    createBlip(LOCATIONS.GANG_ZW.x,       LOCATIONS.GANG_ZW.y,       LOCATIONS.GANG_ZW.z,       19, 2, 0,   200, 0,   255, 0, 400)  -- ZW Green
    createBlip(LOCATIONS.GANG_ZW_DOCKS.x, LOCATIONS.GANG_ZW_DOCKS.y, LOCATIONS.GANG_ZW_DOCKS.z, 19, 2, 0,   180, 50,  255, 0, 400)  -- ZW Docks

    -- Jozi / Gauteng Gang Blips
    createBlip(LOCATIONS.GANG_BM.x,   LOCATIONS.GANG_BM.y,   LOCATIONS.GANG_BM.z,   19, 2, 200, 150, 0,   255, 0, 400)  -- BM Ochre Gold
    createBlip(LOCATIONS.GANG_NDC.x,  LOCATIONS.GANG_NDC.y,  LOCATIONS.GANG_NDC.z,  19, 2, 150, 0,   200, 255, 0, 400)  -- NDC Purple

    -- Drug Lab Blips (small, criminal)
    createBlip(LOCATIONS.DRUG_LAB_1.x, LOCATIONS.DRUG_LAB_1.y, LOCATIONS.DRUG_LAB_1.z, 1, 1, 180, 0, 255, 200, 0, 200)  -- small purple
    createBlip(LOCATIONS.DRUG_LAB_2.x, LOCATIONS.DRUG_LAB_2.y, LOCATIONS.DRUG_LAB_2.z, 1, 1, 180, 0, 255, 200, 0, 200)

    -- ============================
    -- INTERACTIVE 3D MARKERS
    -- ============================

    -- Airport Rental (Green)
    local rentalMarker = createMarker(LOCATIONS.AIRPORT_RENTAL.x, LOCATIONS.AIRPORT_RENTAL.y, LOCATIONS.AIRPORT_RENTAL.z - 1.0, "cylinder", 2.5, 50, 220, 50, 150)
    setElementData(rentalMarker, "mzansi:markerType", "rental")

    -- SAPS Duty (Blue)
    local sapsMarker = createMarker(LOCATIONS.SAPS_HQ.x, LOCATIONS.SAPS_HQ.y, LOCATIONS.SAPS_HQ.z - 1.0, "cylinder", 2.5, 30, 120, 255, 180)
    setElementData(sapsMarker, "mzansi:markerType", "saps_duty")

    -- Hospital / EMS Duty (Red+White)
    local emsMarker = createMarker(LOCATIONS.EMS_HOSPITAL.x, LOCATIONS.EMS_HOSPITAL.y, LOCATIONS.EMS_HOSPITAL.z - 1.0, "cylinder", 2.5, 255, 50, 50, 180)
    setElementData(emsMarker, "mzansi:markerType", "ems_duty")

    -- Job Center (Yellow)
    local jobMarker = createMarker(LOCATIONS.CITY_HALL.x, LOCATIONS.CITY_HALL.y, LOCATIONS.CITY_HALL.z - 1.0, "cylinder", 2.5, 255, 215, 0, 180)
    setElementData(jobMarker, "mzansi:markerType", "job_center")

    -- Central Bank (Gold)
    local bankMarker = createMarker(LOCATIONS.CENTRAL_BANK.x, LOCATIONS.CENTRAL_BANK.y, LOCATIONS.CENTRAL_BANK.z - 1.0, "cylinder", 2.5, 218, 165, 32, 180)
    setElementData(bankMarker, "mzansi:markerType", "bank")

    -- Fishing Pier (Cyan)
    local fishMarker = createMarker(LOCATIONS.FISHING_PIER.x, LOCATIONS.FISHING_PIER.y, LOCATIONS.FISHING_PIER.z - 1.0, "cylinder", 3.0, 0, 200, 255, 180)
    setElementData(fishMarker, "mzansi:markerType", "fishing")

    -- Auto Repair Bay (Orange)
    local repairMarker = createMarker(LOCATIONS.REPAIR_BAY.x, LOCATIONS.REPAIR_BAY.y, LOCATIONS.REPAIR_BAY.z - 1.0, "cylinder", 4.0, 255, 140, 0, 160)
    setElementData(repairMarker, "mzansi:markerType", "repair_bay")

    -- Taxi Rank (Yellow)
    local taxiMarker = createMarker(LOCATIONS.TAXI_RANK.x, LOCATIONS.TAXI_RANK.y, LOCATIONS.TAXI_RANK.z - 1.0, "cylinder", 2.5, 255, 255, 0, 150)
    setElementData(taxiMarker, "mzansi:markerType", "taxi_rank")

    -- Auto Dealership (Cyan)
    local dealerMarker = createMarker(LOCATIONS.DEALERSHIP.x, LOCATIONS.DEALERSHIP.y, LOCATIONS.DEALERSHIP.z - 1.0, "cylinder", 3.0, 0, 200, 255, 160)
    setElementData(dealerMarker, "mzansi:markerType", "dealership")

    -- Province vehicle shops (P2)
    if Mzansi.VehicleShops and Mzansi.VehicleShops.Locations then
        for _, shop in ipairs(Mzansi.VehicleShops.Locations) do
            if not (math.abs(shop.x - LOCATIONS.DEALERSHIP.x) < 1 and math.abs(shop.y - LOCATIONS.DEALERSHIP.y) < 1) then
                local m = createMarker(shop.x, shop.y, shop.z - 1.0, "cylinder", 3.0, 0, 200, 255, 150)
                setElementData(m, "mzansi:markerType", "vehicle_shop")
                setElementData(m, "mzansi:shopId", shop.id)
                createBlip(shop.x, shop.y, shop.z, 55, 1, 0, 200, 255, 200, 0, 450)
            end
        end
    end

    -- Ammu-Nation (Orange-Red)
    local ammuMarker = createMarker(LOCATIONS.AMMUNATION.x, LOCATIONS.AMMUNATION.y, LOCATIONS.AMMUNATION.z - 1.0, "cylinder", 2.0, 255, 100, 0, 160)
    setElementData(ammuMarker, "mzansi:markerType", "ammunation")

    -- Shop markers from shop_config (all provinces)
    if Mzansi.Shops then
        if Mzansi.Shops.Ammunation then
            for _, loc in ipairs(Mzansi.Shops.Ammunation) do
                if not (math.abs(loc.x - LOCATIONS.AMMUNATION.x) < 1 and math.abs(loc.y - LOCATIONS.AMMUNATION.y) < 1) then
                    local m = createMarker(loc.x, loc.y, loc.z - 1.0, "cylinder", 2.0, 255, 100, 0, 140)
                    setElementData(m, "mzansi:markerType", "shop_weapons")
                    setElementData(m, "mzansi:shopId", loc.id)
                    createBlip(loc.x, loc.y, loc.z, 6, 1, 255, 100, 0, 180, 0, 450)
                end
            end
        end
        if Mzansi.Shops.Clothing then
            for _, loc in ipairs(Mzansi.Shops.Clothing) do
                local m = createMarker(loc.x, loc.y, loc.z - 1.0, "cylinder", 2.0, 200, 170, 50, 140)
                setElementData(m, "mzansi:markerType", "shop_clothing")
                setElementData(m, "mzansi:shopId", loc.id)
                createBlip(loc.x, loc.y, loc.z, 51, 1, 200, 170, 50, 180, 0, 450)
            end
        end
    end

    -- ATM markers (gold cylinders that open banking)
    local ATM_LOCATIONS = {
        { x = 1460.0,  y = -1025.0, z = 23.5 },
        { x = 1585.5,  y = -1678.5, z = 13.5 },
        { x = 1176.8,  y = -1323.0, z = 13.5 },
        { x = -1448.5, y = -276.5,  z = 14.2 },
        { x = 2131.5,  y = 943.5,   z = 10.8 },
        { x = 1450.5,  y = 2775.5,  z = 11.0 },
        { x = -532.5,  y = -488.5,  z = 25.5 },
        { x = 1778.0,  y = -1860.0, z = 13.5 },
    }
    for _, a in ipairs(ATM_LOCATIONS) do
        local m = createMarker(a.x, a.y, a.z - 1.0, "cylinder", 1.5, 218, 165, 32, 120)
        setElementData(m, "mzansi:markerType", "atm")
    end

    -- Trucker Depot (Brown/Tan)
    local truckerMarker = createMarker(LOCATIONS.TRUCKER_DEPOT.x, LOCATIONS.TRUCKER_DEPOT.y, LOCATIONS.TRUCKER_DEPOT.z - 1.0, "cylinder", 3.5, 200, 150, 50, 160)
    setElementData(truckerMarker, "mzansi:markerType", "trucker_depot")

    -- Beach / Santa Maria (Aqua)
    local beachMarker = createMarker(LOCATIONS.BEACH.x, LOCATIONS.BEACH.y, LOCATIONS.BEACH.z - 1.0, "cylinder", 3.0, 0, 200, 255, 120)
    setElementData(beachMarker, "mzansi:markerType", "beach")

    -- Casino (Purple/Gold)
    local casinoMarker = createMarker(LOCATIONS.CASINO.x, LOCATIONS.CASINO.y, LOCATIONS.CASINO.z - 1.0, "cylinder", 3.0, 200, 100, 255, 160)
    setElementData(casinoMarker, "mzansi:markerType", "casino")

    -- Register marker hit handler
    addEventHandler("onMarkerHit", resourceRoot, Mzansi.World.onMarkerHit)

    -- 3. Spawn faction vehicles
    Mzansi.World.spawnWorldVehicles()

    outputDebugString("[Mzansi-World] ✓ interactive markers + shop/ATM markers | Faction vehicles live!")
end

-- ==============================================================
-- MARKER HIT HANDLER
-- ==============================================================
function Mzansi.World.onMarkerHit(hitElement, matchingDimension)
    if not matchingDimension then return end
    local markerType = getElementData(source, "mzansi:markerType")
    if not markerType then return end

    -- Resolve player from element or vehicle occupant
    local player = nil
    if getElementType(hitElement) == "player" then
        player = hitElement
    elseif getElementType(hitElement) == "vehicle" then
        player = getVehicleController(hitElement)
    end
    if not player then return end

    -- Repair bay accepts vehicles
    if markerType == "repair_bay" then
        local veh = getPedOccupiedVehicle(player)
        if veh then
            fixVehicle(veh)
            setVehicleDamageProof(veh, false)
            Mzansi.Util.sendNotification(player, "Vehicle fully repaired at JHB Auto Repair Bay! Bakkie is lekker!", "success")
        else
            Mzansi.Util.sendNotification(player, "Mechanic: Drive your vehicle onto the ramp to service it!", "info")
        end
        return
    end

    if isPedInVehicle(player) then
        if markerType == "trucker_depot" then
            Mzansi.Util.sendNotification(player, "Trucker Depot: Hop in a truck and type /route to start a haul!", "info")
        end
        return
    end

    if markerType == "rental" then
        Mzansi.World.offerRental(player)
    elseif markerType == "saps_duty" then
        Mzansi.World.togglePoliceDuty(player)
    elseif markerType == "ems_duty" then
        Mzansi.World.toggleEMSDuty(player)
    elseif markerType == "job_center" then
        triggerClientEvent(player, "mzansi:dashboard:openJobs", player)
        Mzansi.Util.sendNotification(player, "Welcome to City Hall! Opening Career Opportunities...", "info")
    elseif markerType == "bank" or markerType == "atm" then
        Mzansi.World.openBankUI(player)
    elseif markerType == "fishing" then
        Mzansi.Util.sendNotification(player, "Santa Maria Pier: Type /fish to start catching king fish! Buy bait at the pier shop.", "info")
    elseif markerType == "taxi_rank" then
        Mzansi.Characters.setJob(player, Mzansi.Enums.Job.TAXI)
        Mzansi.Util.sendNotification(player, "Taxi Rank: You are now registered as a Taxi Driver. Hop in a yellow taxi to start!", "success")
    elseif markerType == "dealership" then
        triggerEvent("mzansi:market:open", player, player)
        Mzansi.Util.sendNotification(player, "Mzansi Auto: Browse cars, boats, aircraft & investments. Type /market anytime.", "info")
    elseif markerType == "vehicle_shop" then
        local shopId = getElementData(source, "mzansi:shopId") or "vshop_ls_1"
        Mzansi.VehicleShop.open(player, shopId)
    elseif markerType == "ammunation" or markerType == "shop_weapons" then
        triggerEvent("mzansi:shop:openWeapons", player, getElementData(source, "mzansi:shopId"))
        Mzansi.Util.sendNotification(player, "Ammu-Nation: Browse weapons & ammo. Type /buyguns anytime.", "info")
    elseif markerType == "shop_clothing" then
        triggerEvent("mzansi:shop:openClothing", player, getElementData(source, "mzansi:shopId"))
        Mzansi.Util.sendNotification(player, "Clothing Store: Browse outfits. Type /clothes anytime.", "info")
    elseif markerType == "trucker_depot" then
        Mzansi.Characters.setJob(player, Mzansi.Enums.Job.TRUCKER)
        Mzansi.Util.sendNotification(player, "Trucker Depot: Registered as Trucker. Hop in a truck and type /route to haul cargo!", "success")
    elseif markerType == "beach" then
        Mzansi.Util.sendNotification(player, "Santa Maria Beach: Relax, swim, or rent a jetski! Type /jetski to rent one.", "info")
    elseif markerType == "casino" then
        Mzansi.Util.sendNotification(player, "Four Dragons Casino: Try your luck! Type /casino, /slots, or /poker to gamble.", "info")
    end
end

-- ==============================================================
-- FACTION VEHICLES
-- ==============================================================
function Mzansi.World.spawnWorldVehicles()
    -- SAPS Fleet (Police HQ)
    local sapsPlates = { "SAPS-01", "SAPS-02", "SAPS-03", "SAPS-04", "SAPS-K9" }
    local sapsPosX = { 1545.0, 1545.0, 1540.0, 1540.0, 1536.0 }
    local sapsPosY = { -1684.0, -1688.0, -1684.0, -1692.0, -1696.0 }
    for i = 1, 5 do
        local cc = createVehicle(596, sapsPosX[i], sapsPosY[i], 13.5, 0, 0, 270, sapsPlates[i])
        if cc then
            setVehicleColor(cc, 0, 0, 0, 0)
            setElementData(cc, "mzansi:fuel", 100)
            setElementData(cc, "mzansi:factionId", Mzansi.Enums.Faction.SAPS)
        end
    end
    -- SAPS SWAT Van
    local swatVan = createVehicle(601, 1548.0, -1700.0, 13.5, 0, 0, 270, "SWAT-01")
    if swatVan then
        setVehicleColor(swatVan, 0, 0, 0, 0)
        setElementData(swatVan, "mzansi:fuel", 100)
        setElementData(swatVan, "mzansi:factionId", Mzansi.Enums.Faction.SAPS)
    end
    -- SAPS Helicopter
    local copHeli = createVehicle(497, 1540.0, -1720.0, 20.0, 0, 0, 0, "SAPS-AIR")
    if copHeli then
        setVehicleColor(copHeli, 0, 0, 0, 0)
        setElementData(copHeli, "mzansi:fuel", 100)
        setElementData(copHeli, "mzansi:factionId", Mzansi.Enums.Faction.SAPS)
    end
    -- SAPS Bike
    local copBike = createVehicle(523, 1552.0, -1696.0, 13.5, 0, 0, 270, "SAPS-BK")
    if copBike then
        setVehicleColor(copBike, 0, 0, 0, 0)
        setElementData(copBike, "mzansi:fuel", 100)
        setElementData(copBike, "mzansi:factionId", Mzansi.Enums.Faction.SAPS)
    end

    -- EMS Fleet (All Saints Hospital - Emergency Ambulance Bays)
    local emsPlates  = { "EMS-01",  "EMS-02",  "EMS-03"  }
    local emsPosX    = { 1178.0,   1178.0,   1178.0   }
    local emsPosY    = { -1332.0,  -1338.0,  -1344.0  }
    for i = 1, 3 do
        local amb = createVehicle(416, emsPosX[i], emsPosY[i], 13.5, 0, 0, 90, emsPlates[i])
        if amb then
            setVehicleColor(amb, 255, 255, 255, 255)
            setElementData(amb, "mzansi:fuel", 100)
            setElementData(amb, "mzansi:factionId", Mzansi.Enums.Faction.EMS)
        end
    end
    -- EMS Doctor Car (Hospital Parking Lot)
    local docCar = createVehicle(445, 1188.0, -1344.0, 13.5, 0, 0, 90, "DOCTOR-1")
    if docCar then
        setVehicleColor(docCar, 255, 255, 255, 255)
        setElementData(docCar, "mzansi:fuel", 100)
        setElementData(docCar, "mzansi:factionId", Mzansi.Enums.Faction.EMS)
    end

    -- Airport Starter Rentals (Designated Drop-off Parking Bay)
    local rentalVehs = {
        { model = 462, x = 1665.0, y = -2240.0, plate = "RENT-01" }, -- Faggio
        { model = 462, x = 1665.0, y = -2244.0, plate = "RENT-02" }, -- Faggio
        { model = 468, x = 1665.0, y = -2248.0, plate = "RENT-03" }, -- Sanchez
        { model = 468, x = 1665.0, y = -2252.0, plate = "RENT-04" }, -- Sanchez
    }
    for _, r in ipairs(rentalVehs) do
        local v = createVehicle(r.model, r.x, r.y, 13.8, 0, 0, 90, r.plate)
        if v then
            setElementData(v, "mzansi:fuel", 100)
            setVehicleColor(v, 200, 170, 50, 10)
        end
    end
end

-- ==============================================================
-- RENTAL OFFER
-- ==============================================================
function Mzansi.World.offerRental(player)
    if not isElement(player) then return end

    if Mzansi.World._rentalVehicles[player] and isElement(Mzansi.World._rentalVehicles[player]) then
        destroyElement(Mzansi.World._rentalVehicles[player])
        Mzansi.World._rentalVehicles[player] = nil
    end

    local px, py, pz = getElementPosition(player)
    local rot = getPedRotation(player)
    local spawnX = px + math.sin(math.rad(-rot)) * 3
    local spawnY = py + math.cos(math.rad(-rot)) * 3

    local rentalVeh = createVehicle(462, spawnX, spawnY, pz + 0.5, 0, 0, rot, "MZANSI")
    if rentalVeh then
        setElementData(rentalVeh, "mzansi:fuel", 100)
        setElementData(rentalVeh, "mzansi:locked", false)
        setVehicleColor(rentalVeh, 200, 170, 50, 10, 22, 40)
        warpPedIntoVehicle(player, rentalVeh)
        Mzansi.World._rentalVehicles[player] = rentalVeh
        Mzansi.Util.sendNotification(player, "Rental Scooter spawned! Press 'W' to drive. Type /engine to toggle engine.", "success")
    end
end

-- ==============================================================
-- POLICE DUTY TOGGLE
-- ==============================================================
function Mzansi.World.togglePoliceDuty(player)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return end

    if char.faction == Mzansi.Enums.Faction.SAPS then
        char.faction = Mzansi.Enums.Faction.NONE
        char.job = Mzansi.Enums.Job.UNEMPLOYED
        setElementData(player, "mzansi:faction", Mzansi.Enums.Faction.NONE)
        setElementData(player, "mzansi:job", Mzansi.Enums.Job.UNEMPLOYED)
        takeAllWeapons(player)
        setElementModel(player, char.gender == 1 and 12 or 0)
        Mzansi.Util.sendNotification(player, "You clocked OFF duty as a SAPS Officer. Stay safe!", "info")
    else
        char.faction = Mzansi.Enums.Faction.SAPS
        char.job = Mzansi.Enums.Job.POLICE
        setElementData(player, "mzansi:faction", Mzansi.Enums.Faction.SAPS)
        setElementData(player, "mzansi:job", Mzansi.Enums.Job.POLICE)
        setElementModel(player, 280)
        setPedArmor(player, 100)
        setElementHealth(player, 100)
        giveWeapon(player, 3,  1,   true) -- Nightstick
        giveWeapon(player, 24, 150, true) -- Desert Eagle
        giveWeapon(player, 25, 60,  true) -- Shotgun
        giveWeapon(player, 29, 400, true) -- MP5
        giveWeapon(player, 31, 300, true) -- M4 Assault Rifle
        Mzansi.Util.sendNotification(player, "Clocked ON duty as SAPS Police Officer! M4, shotgun & pistol issued. Press F1 for commands.", "success")
    end
end

-- ==============================================================
-- EMS DUTY TOGGLE
-- ==============================================================
function Mzansi.World.toggleEMSDuty(player)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return end

    setElementHealth(player, 100)

    if char.faction == Mzansi.Enums.Faction.EMS then
        char.faction = Mzansi.Enums.Faction.NONE
        char.job = Mzansi.Enums.Job.UNEMPLOYED
        setElementData(player, "mzansi:faction", Mzansi.Enums.Faction.NONE)
        setElementData(player, "mzansi:job", Mzansi.Enums.Job.UNEMPLOYED)
        setElementModel(player, char.gender == 1 and 12 or 0)
        Mzansi.Util.sendNotification(player, "You clocked OFF duty as an EMS Paramedic.", "info")
    else
        char.faction = Mzansi.Enums.Faction.EMS
        char.job = Mzansi.Enums.Job.EMS
        setElementData(player, "mzansi:faction", Mzansi.Enums.Faction.EMS)
        setElementData(player, "mzansi:job", Mzansi.Enums.Job.EMS)
        setElementModel(player, 274)
        setPedArmor(player, 50)
        giveWeapon(player, 41, 20, true) -- Spray (defibrillator roleplay)
        Mzansi.Util.sendNotification(player, "Clocked ON duty as EMS! Use /heal [playerid] or /revive. Ambulance is at hospital.", "success")
    end
end

-- ==============================================================
-- BANK INFO / OPEN BANK UI
-- ==============================================================
function Mzansi.World.openBankUI(player)
    if not isElement(player) then return end
    if Mzansi.Banking and Mzansi.Banking._openUI then
        Mzansi.Banking._openUI(player)
    else
        triggerClientEvent(player, "mzansi:bank:openUI", player)
    end
end

function Mzansi.World.showBankInfo(player)
    local char = Mzansi.Characters.getCharacter(player)
    if not char then return end
    local cash = char.cash or 0
    local bank = char.bank or 0
    Mzansi.Util.sendNotification(player,
        "Standard Bank ATM | Wallet: R " .. Mzansi.Util.formatMoney(cash) .. " | Account: R " .. Mzansi.Util.formatMoney(bank) .. " | Type /bank to transfer funds.",
        "info"
    )
end

-- ==============================================================
-- DIRECT COMMANDS
-- ==============================================================
addCommandHandler("duty",    function(player) Mzansi.World.togglePoliceDuty(player) end)
addCommandHandler("cop",     function(player) Mzansi.World.togglePoliceDuty(player) end)
addCommandHandler("ems",     function(player) Mzansi.World.toggleEMSDuty(player)    end)
addCommandHandler("medic",   function(player) Mzansi.World.toggleEMSDuty(player)    end)
addCommandHandler("rent",    function(player) Mzansi.World.offerRental(player)       end)
addCommandHandler("rental",  function(player) Mzansi.World.offerRental(player)       end)
addCommandHandler("atm",     function(player) Mzansi.World.showBankInfo(player)      end)

-- NOTE: /heal and /revive are owned by mzansi_ems (client -> mzansi:ems:heal
-- event -> server). Duplicate command handlers here caused double execution
-- (double heal + double XP + double notifications).

-- Casino placeholder
local function casinoBet(player)
    local bet = math.random(100, 5000)
    if math.random() > 0.5 then
        Mzansi.Characters.addCash(player, bet)
        Mzansi.Util.sendNotification(player, "You WON R " .. Mzansi.Util.formatMoney(bet) .. " at the casino! Lucky you!", "success")
    else
        Mzansi.Characters.removeCash(player, bet)
        Mzansi.Util.sendNotification(player, "You LOST R " .. Mzansi.Util.formatMoney(bet) .. " at the casino. Try again!", "error")
    end
end
addCommandHandler("casino", function(player) casinoBet(player) end)
addCommandHandler("slots",  function(player) casinoBet(player) end)

-- Dashboard Remote Events
addEvent("mzansi:world:requestRental", true)
addEventHandler("mzansi:world:requestRental", root, function()
    local src = client or source
    Mzansi.World.offerRental(src)
end)

addEvent("mzansi:world:toggleSAPS", true)
addEventHandler("mzansi:world:toggleSAPS", root, function()
    local src = client or source
    Mzansi.World.togglePoliceDuty(src)
end)

addEvent("mzansi:world:toggleEMS", true)
addEventHandler("mzansi:world:toggleEMS", root, function()
    local src = client or source
    Mzansi.World.toggleEMSDuty(src)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    Mzansi.World.init()
    -- Airport blips for SF (Durban) and LV (Johannesburg)
    -- LS airport is already added in init(). Adding the other two provinces.
    createBlip(-1420.0, -280.0, 14.0, 16, 2, 0, 200, 255, 255, 0, 500) -- King Shaka Durban
    createBlip( 1580.0, 1450.0, 10.8, 16, 2, 0, 200, 255, 255, 0, 500) -- OR Tambo Johannesburg
    -- Additional Durban/Jozi civic blips
    createBlip(-1605.5,  715.5, 12.5, 30, 2, 255, 0, 0, 255, 0, 500)  -- Durban SAPS
    createBlip( 2285.0, 2430.0, 10.8, 30, 2, 255, 0, 0, 255, 0, 500)  -- JHB SAPS
    createBlip(-2655.0,  635.0, 14.5, 22, 2, 255, 255, 255, 255, 0, 500) -- Durban Hospital
    createBlip( 1605.0, 1820.0, 10.8, 22, 2, 255, 255, 255, 255, 0, 500) -- JHB Hospital
end)

-- Clean up rentals when player quits
addEventHandler("onPlayerQuit", root, function()
    if Mzansi.World._rentalVehicles[source] and isElement(Mzansi.World._rentalVehicles[source]) then
        destroyElement(Mzansi.World._rentalVehicles[source])
        Mzansi.World._rentalVehicles[source] = nil
    end
end)

-- ============================================================
-- PLAYER JOIN WELCOME & SPAWN ORIENTATION
-- ============================================================

-- Mzansi welcome screen blip notification for the joining player
addEventHandler("onPlayerJoin", root, function()
    local player = source
    -- Stagger 2 seconds to allow client to load
    setTimer(function()
        if not isElement(player) then return end
        outputChatBox(
            "▬▬▬▬▬▬▬ WELCOME TO MZANSI RP ▬▬▬▬▬▬▬",
            player, 80, 220, 130, true
        )
        outputChatBox(
            "  🗺 Press F2 for the RP Dashboard (GPS, Jobs, Factions)",
            player, 200, 220, 255, true
        )
        outputChatBox(
            "  🛠 Press F8 for the Player Menu (Province Teleport)",
            player, 200, 220, 255, true
        )
        outputChatBox(
            "  📱 Press B to open your Phone (Contacts, Jobs, Maps)",
            player, 200, 220, 255, true
        )
        outputChatBox(
            "  🚔 Type /saps to join SAPS  |  /ems to join EMS",
            player, 200, 220, 255, true
        )
        outputChatBox(
            "  ✈ Airports: CTIA (LS), King Shaka (Durban), OR Tambo (JHB)",
            player, 180, 210, 255, true
        )
        outputChatBox(
            "▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬",
            player, 80, 220, 130, true
        )
    end, 2000, 1)
end)

-- Show "Press F8 to travel" hint on every spawn
addEventHandler("onPlayerSpawn", root, function()
    local player = source
    setTimer(function()
        if not isElement(player) then return end
        outputChatBox(
            "[Mzansi RP] Press F8 to teleport between Cape Town, Durban & Johannesburg.",
            player, 100, 180, 255, true
        )
        outputChatBox(
            "[Mzansi RP] Press F2 to open the Dashboard — GPS, Jobs, and more.",
            player, 100, 180, 255, true
        )
    end, 1500, 1)
end)
