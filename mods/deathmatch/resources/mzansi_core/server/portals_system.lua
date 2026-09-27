--[[
    Mzansi Roleplay - SANRAL Highway Tollgate & Territorial Multi-Map Portals
    
    Architectural Scope:
    1. SANRAL National Road Plazas (N1, N2, N3) with boom barriers, e-tags, and toll fees.
    2. ACSA Domestic Air Transit (Cape Town CTIA, King Shaka KSIA, O.R. Tambo ORTIA).
    3. ACSA INTERNATIONAL Air Transit (Vice City International, Liberty City International).
    4. External Multi-Map Expansions & Dimension Portals:
       - Dimension 10: Vice City Maritime & Air Expansion
       - Dimension 20: Liberty City Freight Expansion
       - Dimension 30: Offshore Island Territory / Robben Island Outpost
       - Dimension 40: SPACE EXPLORATION (Orbital Station, Moon Base, Mars Colony)
       - Dimension 50: UNDERWORLD / DEEP SEA (Submarine Base, Trench Cities, Atlantis)
    5. Angel: SANRAL Toll Plazas & Multi-Map Territory Governor.
]]

Mzansi = Mzansi or {}
Mzansi.Portals = {}

-- Active Toll Plaza State
local _tollPlazas = {}
local _domesticAirports = {}
local _mapExpansions = {}

-- Angel Governor Loop Timer
local _governorAngelTimer = nil

--------------------------------------------------------------------------------
-- 0. CUTSCENE SESSION GOVERNOR (skippable flight/portal cinematics)
--------------------------------------------------------------------------------

local _cutsceneSessions = {} -- player -> session table

local function clearCutsceneSession(player)
    local sess = _cutsceneSessions[player]
    if not sess then return end
    if sess.timer and isTimer(sess.timer) then
        killTimer(sess.timer)
    end
    _cutsceneSessions[player] = nil
end

local function armCutsceneTimeout(player, phase, ms, onTimeout)
    local sess = _cutsceneSessions[player]
    if not sess then return end
    if sess.timer and isTimer(sess.timer) then
        killTimer(sess.timer)
    end
    sess.phase = phase
    sess.timer = setTimer(function()
        if not isElement(player) then
            clearCutsceneSession(player)
            return
        end
        -- Safety: never strand a frozen player if client never advances
        if onTimeout then onTimeout(player, sess) end
    end, ms, 1)
end

local function sendCutscene(player, kind, phase, token, data)
    if not isElement(player) then return end
    data = data or {}
    data.token = token
    triggerClientEvent(player, "mzansi:cutscene:scene", resourceRoot, {
        kind = kind,
        phase = phase,
        token = token,
        data = data,
    })
end

addEvent("mzansi:cutscene:advance", true)
addEventHandler("mzansi:cutscene:advance", root, function(token, stage)
    local player = client or source
    if not isElement(player) then return end
    if type(token) ~= "string" or type(stage) ~= "string" then return end

    local sess = _cutsceneSessions[player]
    if not sess or sess.token ~= token then return end

    if sess.onAdvance then
        sess.onAdvance(player, sess, stage)
    end
end)

addEventHandler("onPlayerQuit", root, function()
    clearCutsceneSession(source)
end)


--------------------------------------------------------------------------------
-- 1. SANRAL NATIONAL TOLLGATE NETWORK
--------------------------------------------------------------------------------

local TOLLGATE_CONFIG = {
    {
        id = "n1_karoo",
        name = "SANRAL N1 Great Karoo Plaza",
        corridor = "Western Cape (Cape Town) ⇄ Gauteng (Johannesburg)",
        x = 1258.0, y = 342.0, z = 19.5, rotZ = 337.0,
        feeLight = 50,
        feeHeavy = 120,
        barrierOffset = { x = 0, y = 0, z = 0 },
        boomModel = 968 -- barrier_turn
    },
    {
        id = "n2_tsitsikamma",
        name = "SANRAL N2 Tsitsikamma Plaza",
        corridor = "Western Cape (Cape Town) ⇄ KwaZulu-Natal (Durban)",
        x = 52.0, y = -1535.0, z = 5.0, rotZ = 85.0,
        feeLight = 50,
        feeHeavy = 120,
        barrierOffset = { x = 0, y = 0, z = 0 },
        boomModel = 968
    },
    {
        id = "n3_tugela",
        name = "SANRAL N3 Tugela Plaza",
        corridor = "Gauteng (Johannesburg) ⇄ KwaZulu-Natal (Durban)",
        x = -310.0, y = 1535.0, z = 75.5, rotZ = 0.0,
        feeLight = 60,
        feeHeavy = 150,
        barrierOffset = { x = 0, y = 0, z = 0 },
        boomModel = 968
    }
}

function Mzansi.Portals.initTollgates()
    outputDebugString("[Mzansi-Portals] Initializing SANRAL National Tollgate Network...", 3)
    for _, cfg in ipairs(TOLLGATE_CONFIG) do
        -- Visual 3D marker for toll booth stop
        local col = createColSphere(cfg.x, cfg.y, cfg.z, 6.0)
        local marker = createMarker(cfg.x, cfg.y, cfg.z - 1.0, "cylinder", 4.0, 200, 170, 50, 150)
        
        -- Physical boom barrier object
        local boom = createObject(cfg.boomModel, cfg.x, cfg.y, cfg.z + 0.6, 0, 0, cfg.rotZ)
        setObjectScale(boom, 1.1)

        local plaza = {
            config = cfg,
            col = col,
            marker = marker,
            boom = boom,
            isOpen = false,
            openTicks = 0,
            baseRot = { 0, 0, cfg.rotZ }
        }

        _tollPlazas[col] = plaza

        -- Event listener when vehicle enters toll zone
        addEventHandler("onColShapeHit", col, function(element, matchingDimension)
            if not matchingDimension then return end
            if getElementType(element) == "vehicle" then
                local driver = getVehicleOccupant(element, 0)
                if driver then
                    Mzansi.Portals.processTollPayment(driver, element, plaza)
                end
            elseif getElementType(element) == "player" then
                local veh = getPedOccupiedVehicle(element)
                if not veh then
                    Mzansi.Util.sendNotification(element, "[" .. cfg.name .. "] Pedestrian walkway. Vehicles must pay toll.", "info")
                end
            end
        end)
    end
end

function Mzansi.Portals.processTollPayment(driver, vehicle, plaza)
    if plaza.isOpen then return end

    local cfg = plaza.config
    local vehType = getVehicleType(vehicle)
    local isHeavy = (vehType == "Automobile" and (getElementModel(vehicle) == 408 or getElementModel(vehicle) == 515 or getElementModel(vehicle) == 514 or getElementModel(vehicle) == 403)) or vehType == "Monster Truck"
    local fee = isHeavy and cfg.feeHeavy or cfg.feeLight

    -- Check Ngamla VIP & Creator Status for automated E-Tag waiver
    local isVip = getElementData(driver, "mzansi:vip")
    local isCreator = getElementData(driver, "mzansi:creator")
    if isCreator or (isVip and tonumber(isVip) and tonumber(isVip) > 0) then
        plaza.isOpen = true
        plaza.openTicks = getTickCount()
        setElementRotation(plaza.boom, 0, -90, plaza.config.rotZ)
        playSoundFrontEnd(driver, 41)
        outputChatBox("[SANRAL] Welcome Ngamla Citizen " .. getPlayerName(driver) .. "! VIP E-Tag active. Toll waived.", driver, 255, 215, 0)
        outputChatBox("[SANRAL] " .. cfg.corridor .. " - Safe travels boss!", driver, 200, 170, 50)
        Mzansi.Util.sendNotification(driver, "SANRAL VIP Pass: Toll R" .. fee .. " Waived", "success")
        setTimer(function()
            if isElement(plaza.boom) then
                setElementRotation(plaza.boom, 0, 0, plaza.config.rotZ)
                plaza.isOpen = false
            end
        end, 6500, 1)
        return
    end

    -- Check payment from Cash or Bank (E-Tag system)
    local paid = false
    local paymentMethod = "Cash"

    if Mzansi.Characters and Mzansi.Characters.removeCash(driver, fee) then
        paid = true
        paymentMethod = "Cash Lane"
    elseif Mzansi.Characters and Mzansi.Characters.removeBank(driver, fee) then
        paid = true
        paymentMethod = "SANRAL E-Tag"
    end

    if paid then
        -- Lift boom barrier
        plaza.isOpen = true
        plaza.openTicks = getTickCount()
        
        -- Smoothly animate barrier upward (-90 pitch/roll)
        setElementRotation(plaza.boom, 0, -90, plaza.config.rotZ)
        
        playSoundFrontEnd(driver, 41)
        outputChatBox("[SANRAL] " .. cfg.name .. " (" .. paymentMethod .. "): R" .. fee .. " paid.", driver, 100, 230, 140)
        outputChatBox("[SANRAL] " .. cfg.corridor .. " - Have a safe journey!", driver, 200, 170, 50)
        Mzansi.Util.sendNotification(driver, "Toll Paid: R" .. fee .. " (" .. paymentMethod .. ")", "success")

        -- Schedule barrier closure after 6 seconds
        setTimer(function()
            if isElement(plaza.boom) then
                setElementRotation(plaza.boom, 0, 0, plaza.config.rotZ)
                plaza.isOpen = false
            end
        end, 6500, 1)
    else
        playSoundFrontEnd(driver, 42)
        outputChatBox("[SANRAL] INSUFFICIENT FUNDS! Toll fee is R" .. fee .. ". Please load cash or top up bank.", driver, 240, 60, 60)
        Mzansi.Util.sendNotification(driver, "Toll Unpaid: Need R" .. fee, "error")
    end
end

--------------------------------------------------------------------------------
-- 2. ACSA DOMESTIC AIR TRANSIT SYSTEM (Airports Company South Africa)
--------------------------------------------------------------------------------

local AIRPORT_CONFIG = {
    {
        id = "ctia",
        name = "Cape Town International Airport (CTIA)",
        city = "Western Cape",
        x = 1686.0, y = -2238.0, z = 13.5,
        arrival = { x = 1680.0, y = -2245.0, z = 13.5, rot = 180 },
        cost = 450
    },
    {
        id = "ksia",
        name = "King Shaka International Airport (KSIA)",
        city = "KwaZulu-Natal (Durban)",
        -- Shifted 9m north of the native GTA SA yellow EnEx doorway at (-1420, -287) to prevent marker conflict
        x = -1424.0, y = -278.0, z = 14.1,
        arrival = { x = -1425.0, y = -295.0, z = 14.1, rot = 135 },
        cost = 450
    },
    {
        id = "ortia",
        name = "O.R. Tambo International Airport (ORTIA)",
        city = "Gauteng (Johannesburg)",
        x = 1600.0, y = 1622.0, z = 10.8,
        arrival = { x = 1605.0, y = 1630.0, z = 10.8, rot = 90 },
        cost = 450
    }
}

-- ============================================================
-- 2B. ACSA INTERNATIONAL AIR TRANSIT SYSTEM
-- ============================================================

local INTERNATIONAL_AIRPORT_CONFIG = {
    {
        id = "vice_city_intl",
        name = "Vice City International Airport (VCIA)",
        city = "Vice City, Florida (Vice City Metropolitan Area)",
        country = "United States",
        x = -4000.0, y = -3845.0, z = 15.0,  -- VCIA terminal (dim 10 ocean district)
        arrival = { x = -4010.0, y = -3855.0, z = 15.0, rot = 90 },
        cost = 3500,  -- International flight cost in Rand
        isInternational = true,
        dimension = 10,
    },
    {
        id = "liberty_city_intl",
        name = "Francis International Airport (LCIA)",
        city = "Liberty City, New York (Liberty City Metropolitan Area)",
        country = "United States",
        x = 3990.0, y = -4160.0, z = 15.0,  -- LCIA terminal (dim 20 ocean district)
        arrival = { x = 4000.0, y = -4170.0, z = 15.0, rot = 180 },
        cost = 4200,
        isInternational = true,
        dimension = 20,
    },
    {
        id = "space_port_orbital",
        name = "Cape Canaveral Spaceport / Orbital Gateway",
        city = "Orbital Station Alpha (Low Earth Orbit)",
        country = "International Space Consortium",
        x = 0.0, y = 0.0, z = 500.0,  -- Space dimension
        arrival = { x = 10.0, y = 10.0, z = 505.0, rot = 0 },
        cost = 50000,  -- Space tourism cost
        isInternational = true,
        isSpace = true,
        dimension = 40,
    },
    {
        id = "deepsea_portal",
        name = "Mariana Trench Deep-Sea Research Portal",
        city = "Abyssal Research Station Thetis (Hadal Zone)",
        country = "International Oceanographic Commission",
        x = 200.0, y = -3050.0, z = -11000.0,  -- Deep sea dimension
        arrival = { x = 210.0, y = -3040.0, z = -10995.0, rot = 180 },
        cost = 15000,  -- Deep sea expedition cost
        isInternational = true,
        isUnderwater = true,
        dimension = 50,
    }
}

function Mzansi.Portals.initAirports()
    outputDebugString("[Mzansi-Portals] Initializing ACSA Domestic Air Transit...", 3)
    for _, apt in ipairs(AIRPORT_CONFIG) do
        local marker = createMarker(apt.x, apt.y, apt.z - 1.0, "cylinder", 2.0, 50, 140, 240, 180)
        local blip = createBlip(apt.x, apt.y, apt.z, 5, 2, 255, 255, 255, 255, 0, 400.0)

        _domesticAirports[marker] = apt

        addEventHandler("onMarkerHit", marker, function(element, matchingDimension)
            if not matchingDimension or getElementType(element) ~= "player" then return end
            if isPedInVehicle(element) then
                Mzansi.Util.sendNotification(element, "Park your vehicle before entering the departure terminal.", "warning")
                return
            end

            outputChatBox("════════════════════════════════════════════════════", element, 50, 140, 240)
            outputChatBox("✈️ " .. apt.name .. " - Domestic Departures", element, 255, 255, 255)
            outputChatBox("Connecting flights (Ticket Price: R" .. apt.cost .. "):", element, 200, 200, 200)
            for _, dest in ipairs(AIRPORT_CONFIG) do
                if dest.id ~= apt.id then
                    outputChatBox("  ➤ Type /fly " .. dest.id .. " to fly to " .. dest.name .. " (" .. dest.city .. ")", element, 200, 170, 50)
                end
            end
            -- Show international connections
            outputChatBox("", element, 255, 255, 255)
            outputChatBox("🌍 INTERNATIONAL & SPECIAL DESTINATIONS:", element, 255, 215, 0)
            for _, dest in ipairs(INTERNATIONAL_AIRPORT_CONFIG) do
                local label = dest.isSpace and "🚀" or (dest.isUnderwater and "🌊" or "✈️")
                outputChatBox("  " .. label .. " Type /fly " .. dest.id .. " to " .. dest.name .. " (" .. dest.city .. ") - R" .. dest.cost, element, 200, 170, 50)
            end
            outputChatBox("#FFD700  🎫 Press F3 or type /flight for the full flight board", element, 255, 215, 0, true)
            outputChatBox("════════════════════════════════════════════════════", element, 50, 140, 240)
            -- Auto-open flight UI at terminal
            triggerClientEvent(element, "mzansi:flight:open", resourceRoot, Mzansi.FlightList())
        end)
    end

    -- Initialize international airports in their respective dimensions
    Mzansi.Portals.initInternationalAirports()
end

function Mzansi.Portals.initInternationalAirports()
    outputDebugString("[Mzansi-Portals] Initializing ACSA International & Special Transit...", 3)
    for _, apt in ipairs(INTERNATIONAL_AIRPORT_CONFIG) do
        -- Create marker in the correct dimension
        local marker = createMarker(apt.x, apt.y, apt.z - 1.0, "cylinder", 3.0, 255, 215, 0, 200)
        setElementDimension(marker, apt.dimension)
        setElementInterior(marker, 0)
        
        local blip = createBlip(apt.x, apt.y, apt.z, 5, 2, 255, 215, 0, 255, 0, 500.0)
        setElementDimension(blip, apt.dimension)

        _domesticAirports[marker] = apt

        addEventHandler("onMarkerHit", marker, function(element, matchingDimension)
            if not matchingDimension or getElementType(element) ~= "player" then return end
            if isPedInVehicle(element) then
                Mzansi.Util.sendNotification(element, "Park your vehicle before entering the terminal.", "warning")
                return
            end

            outputChatBox("════════════════════════════════════════════════════", element, 255, 215, 0)
            local label = apt.isSpace and "🚀" or (apt.isUnderwater and "🌊" or "✈️")
            outputChatBox(label .. " " .. apt.name .. " - " .. (apt.isSpace and "Space Operations" or (apt.isUnderwater and "Deep Sea Operations" or "International Departures")), element, 255, 255, 255)
            outputChatBox("Location: " .. apt.city .. ", " .. apt.country, element, 200, 200, 200)
            
            -- Show return flights to South Africa
            outputChatBox("Return flights to South Africa (R" .. apt.cost .. "):", element, 200, 200, 200)
            for _, dest in ipairs(AIRPORT_CONFIG) do
                outputChatBox("  ➤ Type /fly " .. dest.id .. " to fly to " .. dest.name .. " (" .. dest.city .. ")", element, 200, 170, 50)
            end
            outputChatBox("#FFD700  🎫 Press F3 or type /flight for the full flight board", element, 255, 215, 0, true)
            outputChatBox("════════════════════════════════════════════════════", element, 255, 215, 0)
            triggerClientEvent(element, "mzansi:flight:open", resourceRoot, Mzansi.FlightList())
        end)
    end
end

function Mzansi.FlightList()
    local list = {}
    local function push(apt, tag, icon, free)
        list[#list + 1] = {
            id = apt.id,
            name = apt.name,
            city = apt.city,
            country = apt.country or "South Africa",
            cost = apt.cost or 0,
            free = free or false,
            tag = tag,
            icon = icon,
            gate = apt.isSpace and "Orbital Gate" or (apt.isUnderwater and "Submersible Bay" or "ACSA Departures"),
        }
    end
    for _, apt in ipairs(AIRPORT_CONFIG) do push(apt, "Domestic", "✈", false) end
    for _, apt in ipairs(INTERNATIONAL_AIRPORT_CONFIG) do
        local tag = apt.isSpace and "Space" or (apt.isUnderwater and "Deep Sea" or "International")
        local icon = apt.isSpace and "🚀" or (apt.isUnderwater and "🌊" or "🌍")
        push(apt, tag, icon, false)
    end
    return list
end

local function findAirportById(destId)
    destId = string.lower(tostring(destId or ""))
    for _, apt in ipairs(AIRPORT_CONFIG) do
        if apt.id == destId then return apt end
    end
    for _, apt in ipairs(INTERNATIONAL_AIRPORT_CONFIG) do
        if apt.id == destId then return apt end
    end
    return nil
end

local function findCurrentAirport(player)
    local px, py, pz = getElementPosition(player)
    local playerDim = getElementDimension(player)
    if playerDim == 0 then
        for _, apt in ipairs(AIRPORT_CONFIG) do
            if getDistanceBetweenPoints3D(px, py, pz, apt.x, apt.y, apt.z) <= 30.0 then
                return apt
            end
        end
    end
    for _, apt in ipairs(INTERNATIONAL_AIRPORT_CONFIG) do
        if playerDim == apt.dimension then
            if getDistanceBetweenPoints3D(px, py, pz, apt.x, apt.y, apt.z) <= 30.0 then
                return apt
            end
        end
    end
    return nil
end

local function calculateTicket(currentApt, targetApt)
    local isInternational = targetApt.isInternational or currentApt.isInternational
    local isSpace = targetApt.isSpace or currentApt.isSpace
    local isUnderwater = targetApt.isUnderwater or currentApt.isUnderwater
    if isSpace then
        return 50000, isSpace, isUnderwater, isInternational
    elseif isUnderwater then
        return 15000, isSpace, isUnderwater, isInternational
    elseif isInternational then
        return targetApt.cost or currentApt.cost or 4000, isSpace, isUnderwater, isInternational
    end
    return currentApt.cost or 450, isSpace, isUnderwater, isInternational
end

function Mzansi.Portals.processFlight(player, destId)
    if not isElement(player) then return false end
    if isPedInVehicle(player) then
        Mzansi.Util.sendNotification(player, "You cannot fly while inside a vehicle.", "error")
        return false
    end

    local targetApt = findAirportById(destId)
    if not targetApt then
        outputChatBox("Unknown destination! Open the flight board with /flight.", player, 240, 60, 60)
        return false
    end

    local currentApt = findCurrentAirport(player)
    if not currentApt then
        Mzansi.Util.sendNotification(player, "You must be at an ACSA Airport/Spaceport/Deep-Sea Terminal to board.", "warning")
        return false
    end

    if currentApt.id == targetApt.id then
        Mzansi.Util.sendNotification(player, "You are already at " .. targetApt.name .. "!", "info")
        return false
    end

    if _cutsceneSessions[player] then
        Mzansi.Util.sendNotification(player, "Transit already in progress.", "warning")
        return false
    end

    local ticketCost, isSpace, isUnderwater, isInternational = calculateTicket(currentApt, targetApt)

    local paid = false
    local isVip = getElementData(player, "mzansi:vip")
    local isCreator = getElementData(player, "mzansi:creator")
    if isCreator or (isVip and tonumber(isVip) and tonumber(isVip) >= 3) then
        paid = true
        local prefix = isSpace and "[SPACE FLIGHT]" or (isUnderwater and "[DEEP SEA EXPEDITION]" or "[ACSA International]")
        outputChatBox(prefix .. " Welcome aboard, Ngamla Citizen " .. getPlayerName(player) .. "! Ticket complimentary.", player, 255, 215, 0)
    elseif Mzansi.Characters and Mzansi.Characters.removeCash(player, ticketCost) then
        paid = true
    elseif Mzansi.Characters and Mzansi.Characters.removeBank(player, ticketCost) then
        paid = true
    end

    if not paid then
        Mzansi.Util.sendNotification(player, "Boarding Denied: R" .. ticketCost .. " required for ticket.", "error")
        return false
    end

    local token = string.format("flt-%d-%d", math.random(100000, 999999), getTickCount())
    local sceneData = {
        from = currentApt,
        to = targetApt,
        arrival = targetApt.arrival,
        isSpace = isSpace,
        isUnderwater = isUnderwater,
        isInternational = isInternational,
    }

    setElementFrozen(player, true)
    fadeCamera(player, false, 0.6)
    playSoundFrontEnd(player, 40)
    triggerClientEvent(player, "mzansi:flight:close", resourceRoot)

    local departMsg = isSpace and "🚀 Launch sequence initiated" or (isUnderwater and "🌊 Submersible deployment initiated" or "✈️ Flight departing")
    outputChatBox("[ACSA] " .. departMsg .. " from " .. currentApt.name .. " to " .. targetApt.name .. "...", player, 100, 200, 255)
    outputChatBox("#FFD700[CUTSCENE] #FFFFFFPress SPACE or type /skip to skip the cinematic.", player, 255, 215, 0, true)

    local function finalizeArrival(p)
        clearCutsceneSession(p)
        if not isElement(p) then return end

        setElementPosition(p, targetApt.arrival.x, targetApt.arrival.y, targetApt.arrival.z)
        setElementRotation(p, 0, 0, targetApt.arrival.rot)
        setElementDimension(p, targetApt.dimension or 0)
        setElementInterior(p, 0)
        setElementFrozen(p, false)
        fadeCamera(p, true, 1.5)
        setCameraTarget(p)
        playSoundFrontEnd(p, 41)

        local arriveMsg = isSpace and "🚀 Welcome to orbit! You are now in space." or (isUnderwater and "🌊 Welcome to the abyss! Deep sea station online." or "✈️ Welcome to " .. targetApt.name)
        outputChatBox("[ACSA] " .. arriveMsg .. " (" .. targetApt.city .. ")", p, 100, 235, 140)
        Mzansi.Util.sendNotification(p, "Arrived at " .. targetApt.city, "success")

        if isSpace then
            setPedGravity(p, 0.001)
            setGameSpeed(1.0)
            outputChatBox("[SPACE] Gravity simulation: MICRO-G. Use /spacewalk for EVA.", p, 100, 255, 255)
        elseif isUnderwater then
            setPedGravity(p, 0.008)
            setElementData(p, "mzansi:underwater", true)
            outputChatBox("[DEEP SEA] Pressure hull integrity: 100%. Submarine bay accessible.", p, 100, 200, 255)
        else
            setPedGravity(p, 0.008)
            setElementData(p, "mzansi:underwater", false)
        end
    end

    _cutsceneSessions[player] = {
        token = token,
        kind = "flight",
        phase = "depart",
        targetApt = targetApt,
        onAdvance = function(p, sess, stage)
            if stage == "depart_done" and sess.phase == "depart" then
                -- Mid-journey: position at destination while screen is dark
                setElementPosition(p, targetApt.arrival.x, targetApt.arrival.y, targetApt.arrival.z)
                setElementRotation(p, 0, 0, targetApt.arrival.rot)
                setElementDimension(p, targetApt.dimension or 0)
                setElementInterior(p, 0)

                sess.phase = "arrive"
                sendCutscene(p, "flight", "arrive", sess.token, sceneData)
                armCutsceneTimeout(p, "arrive", 20000, function(pl)
                    finalizeArrival(pl)
                end)
            elseif stage == "arrive_done" and sess.phase == "arrive" then
                finalizeArrival(p)
            end
        end,
    }

    sendCutscene(player, "flight", "depart", token, sceneData)
    armCutsceneTimeout(player, "depart", 25000, function(p)
        -- Client stuck: force teleport + short arrive cutscene
        local s = _cutsceneSessions[p]
        if not s then return end
        setElementPosition(p, targetApt.arrival.x, targetApt.arrival.y, targetApt.arrival.z)
        setElementRotation(p, 0, 0, targetApt.arrival.rot)
        setElementDimension(p, targetApt.dimension or 0)
        setElementInterior(p, 0)
        s.phase = "arrive"
        sendCutscene(p, "flight", "arrive", s.token, sceneData)
        armCutsceneTimeout(p, "arrive", 12000, function(pl)
            finalizeArrival(pl)
        end)
    end)
    return true
end


addEvent("mzansi:flight:requestList", true)
addEventHandler("mzansi:flight:requestList", root, function()
    local player = client or source
    if not isElement(player) then return end
    triggerClientEvent(player, "mzansi:flight:setList", resourceRoot, Mzansi.FlightList())
end)

addEvent("mzansi:flight:book", true)
addEventHandler("mzansi:flight:book", root, function(destId)
    local player = client or source
    if not isElement(player) then return end
    Mzansi.Portals.processFlight(player, destId)
end)

addEvent("mzansi:flight:open", true)
addEventHandler("mzansi:flight:open", root, function()
    local player = client or source
    if not isElement(player) then return end
    triggerClientEvent(player, "mzansi:flight:open", resourceRoot, Mzansi.FlightList())
end)

-- Command to fly between airports (domestic & international) — thin wrapper over processFlight
addCommandHandler("fly", function(player, cmd, destId)
    if not isElement(player) then return end
    if isPedInVehicle(player) then
        Mzansi.Util.sendNotification(player, "You cannot fly while inside a vehicle.", "error")
        return
    end

    if not destId or string.len(destId) == 0 then
        outputChatBox("Usage: /fly <destination>  — or open /flight board (F3)", player, 200, 170, 50)
        outputChatBox("Domestic: ctia, ksia, ortia", player, 200, 170, 50)
        outputChatBox("International: vice_city_intl, liberty_city_intl", player, 255, 215, 0)
        outputChatBox("Special: space_port_orbital, deepsea_portal", player, 255, 100, 100)
        return
    end

    Mzansi.Portals.processFlight(player, destId)
end)

--------------------------------------------------------------------------------
-- 3. EXTERNAL TERRITORY EXPANSIONS & MULTI-MAP PORTALS
--------------------------------------------------------------------------------

local EXPANSION_PORTALS = {
    -- Vice City Maritime & Island Expansion
    {
        id = "vice_city_harbor",
        name = "Port of Cape Town Maritime Portal (Vice City Link)",
        destination = "Vice City Ocean District (Dimension 10)",
        entry = { x = 2765.0, y = -2455.0, z = 13.5, dim = 0, int = 0 },
        exit = { x = -4000.0, y = -3975.0, z = 10.0, dim = 10, int = 0, rot = 90 },
        markerColor = { 240, 100, 200, 180 },
        vehicleAllowed = true
    },
    {
        id = "vice_city_return",
        name = "Vice City Harbor Return Portal",
        destination = "Port of Cape Town (Dimension 0)",
        entry = { x = -3995.0, y = -4075.0, z = 10.0, dim = 10, int = 0 },
        exit = { x = 2755.0, y = -2450.0, z = 13.5, dim = 0, int = 0, rot = 270 },
        markerColor = { 200, 170, 50, 180 },
        vehicleAllowed = true
    },

    -- Liberty City Freight & Urban Expansion
    {
        id = "liberty_city_docks",
        name = "Port of Durban International Freight Portal (Liberty City Link)",
        destination = "Liberty City Industrial District (Dimension 20)",
        entry = { x = -1580.0, y = 65.0, z = 3.5, dim = 0, int = 0 },
        exit = { x = 3995.0, y = -3990.0, z = 10.0, dim = 20, int = 0, rot = 180 },
        markerColor = { 100, 180, 240, 180 },
        vehicleAllowed = true
    },
    {
        id = "liberty_city_return",
        name = "Liberty City Harbor Return Portal",
        destination = "Port of Durban (Dimension 0)",
        entry = { x = 3995.0, y = -3790.0, z = 10.0, dim = 20, int = 0 },
        exit = { x = -1565.0, y = 75.0, z = 3.5, dim = 0, int = 0, rot = 0 },
        markerColor = { 200, 170, 50, 180 },
        vehicleAllowed = true
    },


    -- Island Cities & Robben Island / Offshore Outpost Expansion
    {
        id = "island_territory_ferry",
        name = "Waterfront Pier & Offshore Island Ferry Portal",
        destination = "Robben Island & Offshore Archipelago (Dimension 30)",
        entry = { x = 835.0, y = -2060.0, z = 12.8, dim = 0, int = 0 },
        exit = { x = 200.0, y = -3000.0, z = 5.0, dim = 30, int = 0, rot = 180 },
        markerColor = { 60, 220, 140, 180 },
        vehicleAllowed = true
    },
    {
        id = "island_territory_return",
        name = "Offshore Island Return Ferry Portal",
        destination = "Waterfront Pier Mainland (Dimension 0)",
        entry = { x = 205.0, y = -3000.0, z = 5.0, dim = 30, int = 0 },
        exit = { x = 825.0, y = -2050.0, z = 12.8, dim = 0, int = 0, rot = 0 },
        markerColor = { 200, 170, 50, 180 },
        vehicleAllowed = true
    },

    -- ============================================================
    -- SPACE EXPLORATION SYSTEM (Dimension 40)
    -- ============================================================
    {
        id = "space_elevator_cape",
        name = "Cape Town Space Elevator - Orbital Gateway",
        destination = "Orbital Station Alpha (Dimension 40 - Low Earth Orbit)",
        entry = { x = 1682.5, y = -2267.0, z = 500.0, dim = 0, int = 0 },
        exit = { x = 0.0, y = 0.0, z = 505.0, dim = 40, int = 0, rot = 0 },
        markerColor = { 100, 200, 255, 200 },
        vehicleAllowed = true,
        requiresSpaceSuit = true
    },
    {
        id = "space_elevator_return",
        name = "Orbital Station Alpha - Descent Pod",
        destination = "Cape Town Space Elevator (Dimension 0)",
        entry = { x = 10.0, y = 10.0, z = 500.0, dim = 40, int = 0 },
        exit = { x = 1682.5, y = -2267.0, z = 13.5, dim = 0, int = 0, rot = 0 },
        markerColor = { 200, 170, 50, 180 },
        vehicleAllowed = true
    },
    {
        id = "moon_base_portal",
        name = "Orbital Transfer - Moon Base Artemis",
        destination = "Moon Base Artemis (Dimension 40 - Lunar Surface)",
        entry = { x = 500.0, y = 500.0, z = 510.0, dim = 40, int = 0 },
        exit = { x = 1000.0, y = 1000.0, z = 520.0, dim = 40, int = 1, rot = 90 },
        markerColor = { 200, 200, 220, 200 },
        vehicleAllowed = false  -- Foot only on moon surface
    },
    {
        id = "moon_base_return",
        name = "Moon Base Artemis - Return to Orbital",
        destination = "Orbital Station Alpha (Dimension 40)",
        entry = { x = 1010.0, y = 1010.0, z = 520.0, dim = 40, int = 1 },
        exit = { x = 510.0, y = 510.0, z = 510.0, dim = 40, int = 0, rot = 270 },
        markerColor = { 200, 170, 50, 180 },
        vehicleAllowed = false
    },
    {
        id = "mars_colony_portal",
        name = "Deep Space Gateway - Mars Colony Ares Prime",
        destination = "Mars Colony Ares Prime (Dimension 40 - Martian Surface)",
        entry = { x = -500.0, y = -500.0, z = 515.0, dim = 40, int = 0 },
        exit = { x = -2000.0, y = -2000.0, z = 525.0, dim = 40, int = 2, rot = 180 },
        markerColor = { 255, 100, 50, 200 },
        vehicleAllowed = false
    },
    {
        id = "mars_colony_return",
        name = "Mars Colony Ares Prime - Return to Gateway",
        destination = "Orbital Station Alpha (Dimension 40)",
        entry = { x = -1990.0, y = -1990.0, z = 525.0, dim = 40, int = 2 },
        exit = { x = -490.0, y = -490.0, z = 515.0, dim = 40, int = 0, rot = 0 },
        markerColor = { 200, 170, 50, 180 },
        vehicleAllowed = false
    },

    -- ============================================================
    -- UNDERWORLD / DEEP SEA SYSTEM (Dimension 50)
    -- ============================================================
    {
        id = "submarine_bay_durban",
        name = "Port of Durban Submarine Bay - Deep Sea Access",
        destination = "Abyssal Research Station Thetis (Dimension 50 - Hadal Zone)",
        entry = { x = -1580.0, y = 65.0, z = -50.0, dim = 0, int = 0 },
        exit = { x = 200.0, y = -3050.0, z = -11000.0, dim = 50, int = 0, rot = 180 },
        markerColor = { 0, 150, 255, 200 },
        vehicleAllowed = true,
        requiresSubmarine = true
    },
    {
        id = "submarine_bay_return",
        name = "Abyssal Station Thetis - Emergency Ascent Pod",
        destination = "Port of Durban Surface (Dimension 0)",
        entry = { x = 210.0, y = -3040.0, z = -10995.0, dim = 50, int = 0 },
        exit = { x = -1580.0, y = 65.0, z = 3.5, dim = 0, int = 0, rot = 0 },
        markerColor = { 200, 170, 50, 180 },
        vehicleAllowed = true
    },
    {
        id = "trench_city_portal",
        name = "Mariana Trench - Trench City Neptunia",
        destination = "Trench City Neptunia (Dimension 50 - Deep Sea Metropolis)",
        entry = { x = 500.0, y = -3500.0, z = -11000.0, dim = 50, int = 0 },
        exit = { x = 5000.0, y = 5000.0, z = -10950.0, dim = 50, int = 3, rot = 90 },
        markerColor = { 100, 255, 200, 200 },
        vehicleAllowed = true
    },
    {
        id = "trench_city_return",
        name = "Trench City Neptunia - Return to Station",
        destination = "Abyssal Research Station Thetis (Dimension 50)",
        entry = { x = 5010.0, y = 5010.0, z = -10950.0, dim = 50, int = 3 },
        exit = { x = 510.0, y = -3490.0, z = -11000.0, dim = 50, int = 0, rot = 270 },
        markerColor = { 200, 170, 50, 180 },
        vehicleAllowed = true
    },
    {
        id = "atlantis_portal",
        name = "Lost City of Atlantis - Ancient Portal",
        destination = "Atlantis Prime (Dimension 50 - Mythical Underwater City)",
        entry = { x = -2000.0, y = -4000.0, z = -11000.0, dim = 50, int = 0 },
        exit = { x = 10000.0, y = 10000.0, z = -10800.0, dim = 50, int = 4, rot = 0 },
        markerColor = { 255, 215, 0, 200 },
        vehicleAllowed = false
    },
    {
        id = "atlantis_return",
        name = "Atlantis Prime - Return Portal",
        destination = "Mariana Trench Sector (Dimension 50)",
        entry = { x = 10010.0, y = 10010.0, z = -10800.0, dim = 50, int = 4 },
        exit = { x = -1990.0, y = -3990.0, z = -11000.0, dim = 50, int = 0, rot = 180 },
        markerColor = { 200, 170, 50, 180 },
        vehicleAllowed = false
    }
}

function Mzansi.Portals.initExpansions()
    outputDebugString("[Mzansi-Portals] Initializing External Multi-Map Expansion Portals...", 3)
    for _, p in ipairs(EXPANSION_PORTALS) do
        local marker = createMarker(p.entry.x, p.entry.y, p.entry.z - 0.5, "cylinder", 4.5, p.markerColor[1], p.markerColor[2], p.markerColor[3], p.markerColor[4])
        setElementDimension(marker, p.entry.dim)
        setElementInterior(marker, p.entry.int)

        _mapExpansions[marker] = p

        addEventHandler("onMarkerHit", marker, function(element, matchingDimension)
            if not matchingDimension then return end
            Mzansi.Portals.teleportThroughPortal(element, p)
        end)
    end
end

function Mzansi.Portals.teleportThroughPortal(element, portalConfig)
    local targetDim = portalConfig.exit.dim
    local targetInt = portalConfig.exit.int
    local dest = portalConfig.exit

    -- Vehicle requirement gate (must evaluate BEFORE vehicle→element conversion)
    if portalConfig.requiresSubmarine then
        local veh = (getElementType(element) == "vehicle") and element
            or (getElementType(element) == "player" and getPedOccupiedVehicle(element))
        local model = veh and getElementModel(veh)
        if not veh or (model ~= 484 and model ~= 452) then
            local msg = "Submarine required for this transit. Board a submarine (484/452)."
            if getElementType(element) == "player" then
                Mzansi.Util.sendNotification(element, msg, "error")
            end
            return
        end
    end

    -- Space suit gate: no suit system exists yet (GAP flagged in Enorch report).
    -- Flag retained for future enforcement; NOT enforced now or Dimension 40 becomes unreachable.
    -- portalConfig.requiresSpaceSuit intentionally not checked here.

    local driverPlayer = nil
    if getElementType(element) == "player" then
        local veh = getPedOccupiedVehicle(element)
        if veh then
            -- Only driver initiates vehicle teleportation
            if getVehicleController(veh) ~= element then return end
            driverPlayer = element
            element = veh
        else
            driverPlayer = element
        end
    end

    local occupants = {}
    if getElementType(element) == "vehicle" then
        if not portalConfig.vehicleAllowed then return end
        occupants = getVehicleOccupants(element) or {}
    end

    local function finishTeleport(deferUnfreeze)
        if getElementType(element) == "vehicle" then
            if not isElement(element) then return end
            local vx, vy, vz = getElementVelocity(element)
            setElementPosition(element, dest.x, dest.y, dest.z)
            setElementRotation(element, 0, 0, dest.rot or 0)
            setElementDimension(element, targetDim)
            setElementInterior(element, targetInt)
            setElementVelocity(element, vx, vy, vz)
            for _, occ in pairs(occupants) do
                if isElement(occ) then
                    setElementDimension(occ, targetDim)
                    setElementInterior(occ, targetInt)
                end
            end
            if deferUnfreeze then return end
            for _, occ in pairs(occupants) do
                if isElement(occ) then
                    setElementFrozen(occ, false)
                    fadeCamera(occ, true, 0.8)
                    setCameraTarget(occ)
                    outputChatBox("════════════════════════════════════════════════════", occ, 200, 170, 50)
                    outputChatBox("🌐 Transited to: " .. portalConfig.destination, occ, 255, 255, 255)
                    outputChatBox("════════════════════════════════════════════════════", occ, 200, 170, 50)
                    Mzansi.Util.sendNotification(occ, "Territory: " .. portalConfig.destination, "info")
                end
            end
        elseif isElement(element) then
            setElementPosition(element, dest.x, dest.y, dest.z)
            setElementRotation(element, 0, 0, dest.rot or 0)
            setElementDimension(element, targetDim)
            setElementInterior(element, targetInt)
            if deferUnfreeze then return end
            setElementFrozen(element, false)
            fadeCamera(element, true, 0.8)
            setCameraTarget(element)
            outputChatBox("════════════════════════════════════════════════════", element, 200, 170, 50)
            outputChatBox("🌐 Transited to: " .. portalConfig.destination, element, 255, 255, 255)
            outputChatBox("════════════════════════════════════════════════════", element, 200, 170, 50)
            Mzansi.Util.sendNotification(element, "Territory: " .. portalConfig.destination, "info")
        end
    end

    -- All players involved get the cutscene; vehicles wait for driver advance
    local sessionPlayers = {}
    if getElementType(element) == "vehicle" then
        for _, occ in pairs(occupants) do
            if isElement(occ) and getElementType(occ) == "player" then
                sessionPlayers[#sessionPlayers + 1] = occ
            end
        end
    elseif getElementType(element) == "player" then
        sessionPlayers[1] = element
    end

    if #sessionPlayers == 0 then
        -- Non-player vehicle (AI etc): keep classic short fade
        setTimer(finishTeleport, 600, 1)
        return
    end

    -- Freeze everyone and run depart cutscene on each player (token shared via driver/first)
    local token = string.format("prt-%d-%d", math.random(100000, 999999), getTickCount())
    local ex, ey, ez = getElementPosition(element)
    local sceneData = {
        destination = portalConfig.destination,
        label = portalConfig.name,
        pos = { x = ex, y = ey, z = ez, rot = dest.rot or 0 },
    }

    local arriveData = {
        destination = portalConfig.destination,
        label = portalConfig.name,
        pos = { x = dest.x, y = dest.y, z = dest.z, rot = dest.rot or 0 },
    }

    local function freezeAll()
        for _, pl in ipairs(sessionPlayers) do
            setElementFrozen(pl, true)
            fadeCamera(pl, false, 0.5)
        end
        if getElementType(element) == "vehicle" then
            setElementFrozen(element, true)
        end
    end

    local function unfreezeAll()
        if getElementType(element) == "vehicle" and isElement(element) then
            setElementFrozen(element, false)
        end
        for _, pl in ipairs(sessionPlayers) do
            if isElement(pl) then
                setElementFrozen(pl, false)
                fadeCamera(pl, true, 0.8)
                setCameraTarget(pl)
            end
        end
    end

    local function runArriveCutscene(tokenIn)
        for _, pl in ipairs(sessionPlayers) do
            if isElement(pl) then
                sendCutscene(pl, "portal", "arrive", tokenIn, arriveData)
            end
        end
        -- Each player advances arrive_done; finish when ALL done (or timeout)
        local remaining = {}
        for _, pl in ipairs(sessionPlayers) do remaining[pl] = true end
        local function markDone(p)
            remaining[p] = nil
            local any = false
            for _ in pairs(remaining) do
                any = true
                break
            end
            if not any then
                for _, pl in ipairs(sessionPlayers) do
                    clearCutsceneSession(pl)
                end
                finishTeleport()
                unfreezeAll()
            end
        end
        for _, pl in ipairs(sessionPlayers) do
            _cutsceneSessions[pl] = {
                token = tokenIn,
                kind = "portal",
                phase = "arrive",
                onAdvance = function(p, sess, stage)
                    if stage == "arrive_done" and sess.phase == "arrive" then
                        markDone(p)
                    end
                end,
            }
            armCutsceneTimeout(pl, "arrive", 15000, function(tp)
                markDone(tp)
            end)
        end
    end

    freezeAll()

    -- Primary session player drives depart → teleport
    local primary = sessionPlayers[1]
    _cutsceneSessions[primary] = {
        token = token,
        kind = "portal",
        phase = "depart",
        onAdvance = function(p, sess, stage)
            if stage == "depart_done" and sess.phase == "depart" then
                clearCutsceneSession(p)
                finishTeleport(true)
                runArriveCutscene(sess.token)
            end
        end,
    }

    for _, pl in ipairs(sessionPlayers) do
        sendCutscene(pl, "portal", "depart", token, sceneData)
    end

    armCutsceneTimeout(primary, "depart", 15000, function(p)
        local s = _cutsceneSessions[p]
        if not s then return end
        clearCutsceneSession(p)
        finishTeleport(true)
        runArriveCutscene(s.token)
    end)
end


--------------------------------------------------------------------------------
-- 4. ANGEL: SANRAL & MULTI-MAP TERRITORY GOVERNOR
--------------------------------------------------------------------------------

local function angelGovernorLoop()
    -- Autonomous service loop monitoring plaza boom states and resetting unclosed gates
    local now = getTickCount()
    for col, plaza in pairs(_tollPlazas) do
        if plaza.isOpen and (now - plaza.openTicks > 10000) then
            if isElement(plaza.boom) then
                setElementRotation(plaza.boom, 0, 0, plaza.config.rotZ)
            end
            plaza.isOpen = false
        end
    end
end

addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Portals] Angel: SANRAL & Territorial Boundary Governor activating...", 3)
    Mzansi.Portals.initTollgates()
    Mzansi.Portals.initAirports()
    Mzansi.Portals.initExpansions()

    -- Run Angel loop every 5 seconds
    _governorAngelTimer = setTimer(angelGovernorLoop, 5000, 0)
    outputDebugString("[Mzansi-Portals] SANRAL Tollgates & Multi-Map Territory Engine Fully Operational.", 3)
end)

addEventHandler("onResourceStop", resourceRoot, function()
    if isTimer(_governorAngelTimer) then
        killTimer(_governorAngelTimer)
        _governorAngelTimer = nil
    end
end)
