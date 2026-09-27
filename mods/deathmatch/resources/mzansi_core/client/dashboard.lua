Mzansi = Mzansi or {}
Mzansi.Dashboard = {}
Mzansi.Dashboard._visible = false
Mzansi.Dashboard._currentTab = "overview"
Mzansi.Dashboard._activeProvince = "wc" -- "wc" (Cape Town / Western Cape), "kzn" (Durban / KwaZulu-Natal), "gp" (Johannesburg / Gauteng)
Mzansi.Dashboard._activeGPS = nil
Mzansi.Dashboard._activeGPSMarker = nil
Mzansi.Dashboard._activeGPSBlip = nil

local TABS = {
    { id = "overview", name = "Overview" },
    { id = "factions", name = "SAPS & EMS" },
    { id = "jobs",     name = "Careers & Jobs" },
    { id = "assets",   name = "My Assets" },
    { id = "gangs",    name = "Gangs & Turfs" },
    { id = "crime",    name = "Crime & Missions" },
    { id = "gps",      name = "GPS Navigation" },
    { id = "commands", name = "Commands" },
}

local PROVINCES = {
    { id = "wc",  name = "Western Cape (Cape Town - LS)", short = "Western Cape" },
    { id = "kzn", name = "KwaZulu-Natal (Durban - SF)",   short = "KwaZulu-Natal" },
    { id = "gp",  name = "Gauteng (Johannesburg - LV)",   short = "Gauteng" },
}

local PROVINCE_GPS = {
    wc = {
        { name = "Cape Town Central SAPS",        x = 1547.5, y = -1675.5, z = 13.5, category = "Law Enforcement" },
        { name = "Cape Town Provincial Hospital",  x = 1176.8, y = -1323.0, z = 13.5, category = "Medical EMS" },
        { name = "Civic Centre & Job Center",     x = 1481.5, y = -1745.5, z = 13.5, category = "Civic Services" },
        { name = "Standard Bank Waterfront",      x = 1460.0, y = -1025.0, z = 23.5, category = "Finance & ATM" },
        { name = "Waterfront Auto Dealership",    x = 2131.5, y = -1150.5, z = 24.0, category = "Dealership" },
        { name = "Ganton Motors",                 x = 2244.5, y = -1665.5, z = 15.5, category = "Vehicle Shop" },
        { name = "Idlewood Autos",                x = 1950.0, y = -1450.0, z = 13.5, category = "Vehicle Shop" },
        { name = "Flint County Auto",             x = -216.5, y = 965.5,   z = 19.5, category = "Vehicle Shop" },
        { name = "Whetstone Vehicles",            x = -2160.5,y = -235.5,  z = 36.5, category = "Vehicle Shop" },
        { name = "Standard Bank Central Reserve", x = 1460.0, y = -1025.0, z = 23.5, category = "Central Bank" },
        { name = "Cape Town Ammu-Nation",         x = 1368.5, y = -1279.5, z = 13.5, category = "Arms & Security" },
        { name = "Camps Bay / Pier Fishery",      x = 385.0,  y = -2088.0, z = 7.8,  category = "Fisheries Depot" },
        { name = "Cape Town Int. Airport (CTIA)", x = 1675.0, y = -2250.0, z = 13.5, category = "Air Transport" },
        { name = "Cape Flats 28s Gang Turf",      x = 1950.0, y = -1450.0, z = 13.5, category = "Township Turf" },
        { name = "Cape Town Docks & Freight",     x = 2770.0, y = -2450.0, z = 13.5, category = "Maritime Port" },
    },
    kzn = {
        { name = "Durban Central SAPS",           x = -1605.5, y = 715.5,  z = 12.5, category = "Law Enforcement" },
        { name = "Durban General Hospital",       x = -2655.0, y = 635.0,  z = 14.5, category = "Medical EMS" },
        { name = "Durban Harbour Container Bay",  x = -1740.0, y = 30.0,   z = 3.5,  category = "Maritime Port" },
        { name = "Golden Mile Beachfront",        x = -2265.0, y = -200.0, z = 35.0, category = "Tourism & Leisure" },
        { name = "King Shaka Int. Airport",       x = -1420.0, y = -280.0, z = 14.0, category = "Air Transport" },
        { name = "Durban Import Auto Showroom",   x = -1980.0, y = 290.0,  z = 35.0, category = "Dealership" },
        { name = "San Fierro Auto Plaza",         x = -1675.5, y = 413.5,  z = 7.2,  category = "Vehicle Shop" },
        { name = "Doherty Motors",                x = -1448.5, y = -276.5, z = 14.2, category = "Vehicle Shop" },
        { name = "Tierra Robada Autos",           x = -2225.5, y = 2325.5, z = 7.5,  category = "Vehicle Shop" },
        { name = "Zulu Warriors Coast Bastion",   x = -2170.0, y = 710.0,  z = 69.0, category = "Gang Turf" },
        { name = "KZN Sugar Cane Farm Hub",       x = -366.5,  y = 1188.5, z = 20.0, category = "Agriculture" },
    },
    gp = {
        { name = "JHB Central SAPS (John Vorster)", x = 2285.0, y = 2430.0, z = 10.8, category = "Law Enforcement" },
        { name = "Chris Hani Baragwanath Hospital", x = 1605.0, y = 1820.0, z = 10.8, category = "Medical EMS" },
        { name = "JSE & Standard Bank Central Vault",x = 2100.0, y = 2260.0, z = 10.8, category = "Finance & Gold" },
        { name = "Gold Reef City Strip Casinos",   x = 2020.0, y = 1010.0, z = 10.8, category = "Entertainment" },
        { name = "Hunter Deep Gold Quarry Mine",   x = 815.0,  y = 856.0,  z = 12.5, category = "Mining Depot" },
        { name = "OR Tambo International Airport", x = 1580.0, y = 1450.0, z = 10.8, category = "Air Transport" },
        { name = "Sandton Luxury Auto Galleria",   x = 1980.0, y = 2060.0, z = 10.8, category = "Luxury Dealership" },
        { name = "Las Venturas Motors",            x = 2131.5, y = 943.5,  z = 10.8, category = "Vehicle Shop" },
        { name = "Redsands Auto",                  x = 1975.5, y = 2162.5, z = 11.7, category = "Vehicle Shop" },
        { name = "Montgomery Vehicles",            x = 1450.5, y = 2775.5, z = 11.0, category = "Vehicle Shop" },
        { name = "Bone County Motors",             x = 610.5,  y = 1760.5, z = 12.5, category = "Vehicle Shop" },
        { name = "Johannesburg Freight Terminal",  x = 1060.0, y = 1220.0, z = 10.8, category = "Heavy Logistics" },
    },
}

local JOBS_LIST = {
    { id = 4, name = "Trucker", pay = "R 4,200 / load", desc = "Long haul heavy cargo deliveries from the Docks.", x = -532.5, y = -488.5, z = 25.5 },
    { id = 7, name = "Taxi Driver", pay = "R 3,500 / hr", desc = "Pick up citizens and tourists across Cape Town & cities.", x = 1778.5, y = -1865.0, z = 13.5 },
    { id = 8, name = "Bus Driver", pay = "R 3,800 / route", desc = "Follow transit routes and transport passengers.", x = 1778.5, y = -1865.0, z = 13.5 },
    { id = 3, name = "Mechanic", pay = "R 5,500 / repair", desc = "Repair, modify, and refuel player vehicles.", x = 2131.5, y = -1150.5, z = 24.0 },
    { id = 5, name = "Fisherman", pay = "R 3,200 / catch", desc = "Catch and sell deep-sea fish at Santa Maria Pier.", x = 385.0, y = -2088.0, z = 7.8 },
    { id = 11, name = "Delivery Courier", pay = "R 3,000 / drop", desc = "Deliver packages and takeaway food across city.", x = 1481.5, y = -1745.5, z = 13.5 },
    { id = 9, name = "Miner", pay = "R 4,800 / haul", desc = "Excavate mineral ores at the Hunter Quarry (Gauteng).", x = 815.0, y = 856.0, z = 12.5 },
    { id = 6, name = "Farmer", pay = "R 3,600 / crop", desc = "Harvest agricultural crops at Flint County farms (KZN).", x = -366.5, y = 1188.5, z = 20.0 },
    { id = 13, name = "Computer Engineer", pay = "R 6,500 / ticket", desc = "Build software, fix bugs, and ship CE tickets for clients.", x = 1481.5, y = -1745.5, z = 13.5 },
    { id = 14, name = "Mechatronics Technician", pay = "R 6,800 / job", desc = "Wire PLCs, solve ladder logic, and maintain industrial arms.", x = 1505.8, y = -1664.2, z = 13.4 },
}

local function isMouseIn(x, y, w, h)
    local mx, my = getCursorPosition()
    if not mx or not my then return false end
    local sx, sy = guiGetScreenSize()
    mx, my = mx * sx, my * sy
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

function Mzansi.Dashboard.toggle()
    if isChatBoxInputActive() or isConsoleActive() then return end
    Mzansi.Dashboard._visible = not Mzansi.Dashboard._visible

    if Mzansi.Dashboard._visible then
        -- Close others FIRST (they may call showCursor(false)), then claim cursor
        triggerEvent("mzansi:phone:close", localPlayer)
        triggerEvent("mzansi:radio:close", localPlayer)
        triggerEvent("mzansi:freeroam:close", localPlayer)
        triggerEvent("mzansi:admin:close", localPlayer)
        triggerEvent("mzansi:flight:close", localPlayer)
        triggerEvent("mzansi:market:close", localPlayer)
        triggerEvent("mzansi:bank:close", localPlayer)
        triggerEvent("mzansi:shop:closeUI", localPlayer)
        showCursor(true)
        playSoundFrontEnd(41)
    else
        showCursor(false)
        playSoundFrontEnd(42)
    end
end

function Mzansi.Dashboard.openTab(tabId)
    Mzansi.Dashboard._visible = true
    Mzansi.Dashboard._currentTab = tabId
    -- Close others FIRST, then claim cursor
    triggerEvent("mzansi:phone:close", localPlayer)
    triggerEvent("mzansi:radio:close", localPlayer)
    triggerEvent("mzansi:freeroam:close", localPlayer)
    triggerEvent("mzansi:admin:close", localPlayer)
    triggerEvent("mzansi:flight:close", localPlayer)
    triggerEvent("mzansi:market:close", localPlayer)
    triggerEvent("mzansi:bank:close", localPlayer)
    triggerEvent("mzansi:shop:closeUI", localPlayer)
    showCursor(true)
    playSoundFrontEnd(41)
end

-- Mutual exclusion event
addEvent("mzansi:dashboard:close", true)
addEventHandler("mzansi:dashboard:close", root, function()
    if Mzansi.Dashboard._visible then
        Mzansi.Dashboard._visible = false
        showCursor(false)
    end
end)

-- Render F1 Roleplay Dashboard
addEventHandler("onClientRender", root, function()
    -- Render Active GPS HUD Indicator if set
    if Mzansi.Dashboard._activeGPS then
        local px, py, pz = getElementPosition(localPlayer)
        local dist = math.floor(getDistanceBetweenPoints3D(px, py, pz, Mzansi.Dashboard._activeGPS.x, Mzansi.Dashboard._activeGPS.y, Mzansi.Dashboard._activeGPS.z))
        local distStr = dist > 1000 and string.format("%.1f km", dist / 1000) or (dist .. "m")
        local sw, sh = guiGetScreenSize()
        dxDrawRectangle(sw / 2 - 170, 20, 340, 35, tocolor(10, 22, 40, 220), false)
        dxDrawRectangle(sw / 2 - 170, 53, 340, 2, tocolor(200, 170, 50, 255), false)
        dxDrawText("📍 GPS: " .. Mzansi.Dashboard._activeGPS.name .. " (" .. distStr .. ")", sw / 2 - 160, 20, sw / 2 + 160, 53, tocolor(255, 255, 255, 255), 0.95, "default-bold", "center", "center", false, false, false)

        if dist < 12 then
            Mzansi.Dashboard.clearGPS()
            outputChatBox("[Mzansi-GPS] Destination reached!", 50, 255, 50)
        end
    end

    if not Mzansi.Dashboard._visible then return end

    local sx, sy = guiGetScreenSize()
    local w, h = 860, 560
    local x = (sx - w) / 2
    local y = (sy - h) / 2

    -- Dim Backdrop
    dxDrawRectangle(0, 0, sx, sy, tocolor(5, 10, 18, 140), false)

    -- Window Frame
    dxDrawRectangle(x, y, w, h, tocolor(10, 18, 30, 250), false)
    dxDrawRectangle(x, y, w, 3, tocolor(200, 170, 50, 255), false)

    -- Header
    dxDrawRectangle(x, y, w, 50, tocolor(15, 26, 44, 255), false)
    dxDrawText("MZANSI ROLEPLAY • SOUTH AFRICA ROLEPLAY DASHBOARD", x + 25, y, x + w - 100, y + 50, tocolor(200, 170, 50, 255), 1.1, "default-bold", "left", "center")
    dxDrawText("[F2 or X to Close]", x + w - 140, y, x + w - 25, y + 50, tocolor(150, 170, 190, 200), 0.9, "default-bold", "right", "center")

    -- Tabs Bar
    local tabX = x + 20
    local tabY = y + 58
    local tabW = (w - 40) / #TABS
    for _, tab in ipairs(TABS) do
        local isActive = Mzansi.Dashboard._currentTab == tab.id
        local isHover = isMouseIn(tabX, tabY, tabW - 4, 32)
        local bgCol = isActive and tocolor(200, 170, 50, 255) or (isHover and tocolor(25, 45, 75, 255) or tocolor(18, 30, 50, 200))
        local txtCol = isActive and tocolor(10, 18, 30, 255) or tocolor(220, 230, 240, 255)

        dxDrawRectangle(tabX, tabY, tabW - 4, 32, bgCol, false)
        dxDrawText(tab.name, tabX, tabY, tabX + tabW - 4, tabY + 32, txtCol, 0.85, "default-bold", "center", "center")
        tabX = tabX + tabW
    end

    -- Tab Content Container
    local contX = x + 20
    local contY = y + 100
    local contW = w - 40
    local contH = h - 120
    dxDrawRectangle(contX, contY, contW, contH, tocolor(14, 22, 36, 230), false)
    dxDrawRectangle(contX, contY, contW, 1, tocolor(40, 60, 85, 150), false)

    -- Render Tab Details
    local tab = Mzansi.Dashboard._currentTab
    if tab == "overview" then
        Mzansi.Dashboard.renderOverview(contX, contY, contW, contH)
    elseif tab == "factions" then
        Mzansi.Dashboard.renderFactions(contX, contY, contW, contH)
    elseif tab == "jobs" then
        Mzansi.Dashboard.renderJobs(contX, contY, contW, contH)
    elseif tab == "assets" then
        Mzansi.Dashboard.renderAssets(contX, contY, contW, contH)
    elseif tab == "gangs" then
        Mzansi.Dashboard.renderGangs(contX, contY, contW, contH)
    elseif tab == "crime" then
        Mzansi.Dashboard.renderCrime(contX, contY, contW, contH)
    elseif tab == "gps" then
        Mzansi.Dashboard.renderGPS(contX, contY, contW, contH)
    elseif tab == "commands" then
        Mzansi.Dashboard.renderCommands(contX, contY, contW, contH)
    end
end)

-- TAB 1: Overview
function Mzansi.Dashboard.renderOverview(x, y, w, h)
    local char = getElementData(localPlayer, "mzansi:character")
    local fn = char and (char.firstName or char.first_name) or ""
    local ln = char and (char.lastName or char.last_name) or ""
    local name = (#fn > 0 and #ln > 0) and (fn .. " " .. ln) or getPlayerName(localPlayer)
    local cash = getElementData(localPlayer, "mzansi:cash") or 0
    local bank = getElementData(localPlayer, "mzansi:bank") or 0
    local jobName = char and Mzansi.Config.Jobs[char.job] and Mzansi.Config.Jobs[char.job].name or "Unemployed"
    local factionName = (char and char.faction == 1) and "SAPS Police" or ((char and char.faction == 2) and "EMS Paramedic" or "Civilian")

    -- Profile Header
    dxDrawText("Welcome to Mzansi, " .. name .. "!", x + 25, y + 20, x + w - 25, y + 45, tocolor(200, 170, 50, 255), 1.2, "default-bold", "left", "top")
    dxDrawText("South Africa RP: Western Cape (Cape Town), KwaZulu-Natal (Durban), and Gauteng (Johannesburg). Live police patrols, township crews, economy, and dynamic missions.", x + 25, y + 48, x + w - 25, y + 80, tocolor(170, 185, 200, 255), 0.88, "default", "left", "top", true, true)

    -- Status Cards
    local cardW = (w - 70) / 4
    local cards = {
        { title = "WALLET CASH", val = "R " .. cash, col = tocolor(50, 220, 100, 255) },
        { title = "BANK SAVINGS", val = "R " .. bank, col = tocolor(100, 180, 255, 255) },
        { title = "OCCUPATION", val = jobName, col = tocolor(255, 215, 0, 255) },
        { title = "FACTION", val = factionName, col = tocolor(255, 120, 120, 255) },
    }

    local cx = x + 25
    for _, card in ipairs(cards) do
        dxDrawRectangle(cx, y + 85, cardW, 65, tocolor(20, 32, 50, 240), false)
        dxDrawRectangle(cx, y + 85, cardW, 2, card.col, false)
        dxDrawText(card.title, cx + 10, y + 92, cx + cardW - 10, y + 108, tocolor(130, 150, 170, 255), 0.75, "default-bold", "left", "top")
        dxDrawText(card.val, cx + 10, y + 112, cx + cardW - 10, y + 140, card.col, 1.0, "default-bold", "left", "top")
        cx = cx + cardW + 7
    end

    -- Quick Start Guide
    dxDrawText("HOW TO GET STARTED IN MZANSI:", x + 25, y + 165, x + w - 25, y + 185, tocolor(200, 170, 50, 255), 0.95, "default-bold", "left", "top")
    local steps = {
        "1. Free Transport: Click 'Rent Scooter' below or visit the green marker outside Cape Town International Airport.",
        "2. Choose a Career: Open 'Careers & Jobs' to apply as Trucker, Taxi Driver, Mechanic, or Fisherman for instant income.",
        "3. Law Enforcement / EMS: Want to uphold the law? Open 'SAPS & EMS' and clock ON duty to receive police cruisers, taser & armory.",
        "4. Criminal Underworld: Prefer the streets? Check 'Gangs & Turfs' to explore South Side Kings, Zulu Warriors, or Cape Flats 28s.",
        "5. GPS & Provinces: Use 'GPS Navigation' to travel between Western Cape (CT), KwaZulu-Natal (DBN), and Gauteng (JHB).",
    }

    local sy = y + 195
    for _, step in ipairs(steps) do
        dxDrawText(step, x + 25, sy, x + w - 25, sy + 22, tocolor(210, 220, 230, 255), 0.85, "default", "left", "top")
        sy = sy + 25
    end

    -- Quick Action Buttons
    local rentHover = isMouseIn(x + 25, y + 360, 210, 42)
    dxDrawRectangle(x + 25, y + 360, 210, 42, rentHover and tocolor(60, 200, 90, 255) or tocolor(40, 160, 70, 255), false)
    dxDrawText("🛵 RENT SCOOTER", x + 25, y + 360, x + 235, y + 402, tocolor(255, 255, 255, 255), 0.85, "default-bold", "center", "center")

    local gpsHover = isMouseIn(x + 245, y + 360, 210, 42)
    dxDrawRectangle(x + 245, y + 360, 210, 42, gpsHover and tocolor(60, 130, 220, 255) or tocolor(40, 100, 180, 255), false)
    dxDrawText("🏛️ GPS: CIVIC CENTRE", x + 245, y + 360, x + 455, y + 402, tocolor(255, 255, 255, 255), 0.85, "default-bold", "center", "center")

    local callHover = isMouseIn(x + 465, y + 360, 250, 42)
    dxDrawRectangle(x + 465, y + 360, 250, 42, callHover and tocolor(255, 60, 60, 255) or tocolor(200, 40, 40, 255), false)
    dxDrawText("🚨 911 EMERGENCY MISSION", x + 465, y + 360, x + 715, y + 402, tocolor(255, 255, 255, 255), 0.85, "default-bold", "center", "center")
end

-- TAB 2: Factions (SAPS & EMS)
function Mzansi.Dashboard.renderFactions(x, y, w, h)
    dxDrawText("SOUTH AFRICAN LAW ENFORCEMENT & MEDICAL SERVICES", x + 25, y + 20, x + w - 25, y + 45, tocolor(200, 170, 50, 255), 1.1, "default-bold", "left", "top")

    -- SAPS Box
    local colW = (w - 60) / 2
    dxDrawRectangle(x + 20, y + 55, colW, 360, tocolor(18, 28, 45, 240), false)
    dxDrawRectangle(x + 20, y + 55, colW, 2, tocolor(30, 120, 255, 255), false)
    dxDrawText("SAPS POLICE SERVICE", x + 35, y + 68, x + 20 + colW, y + 90, tocolor(60, 150, 255, 255), 1.0, "default-bold", "left", "top")
    dxDrawText("Headquarters: Cape Town Central / Pershing Square\nRole: High-visibility patrol, handcuff suspects, issue traffic tickets, intercept armored truck heists, and suppress gang violence.", x + 35, y + 95, x + 10 + colW, y + 150, tocolor(170, 185, 200, 255), 0.85, "default", "left", "top", true, true)

    dxDrawText("POLICE COMMANDS:\n• /duty or /cop - Clock ON/OFF Duty & Armory\n• /cuff - Handcuff nearest suspect\n• /arrest <seconds> - Jail suspect at station\n• /ticket <amount> <reason> - Issue fine\n• /frisk - Search suspect inventory\n• /mdt - Mobile Data Terminal database", x + 35, y + 155, x + 10 + colW, y + 280, tocolor(200, 215, 230, 255), 0.85, "default", "left", "top")

    local sapsBtnHover = isMouseIn(x + 35, y + 330, colW - 30, 42)
    dxDrawRectangle(x + 35, y + 330, colW - 30, 42, sapsBtnHover and tocolor(40, 130, 255, 255) or tocolor(25, 95, 200, 255), false)
    dxDrawText("TOGGLE SAPS POLICE DUTY", x + 35, y + 330, x + 5 + colW, y + 372, tocolor(255, 255, 255, 255), 0.9, "default-bold", "center", "center")

    -- EMS Box
    local emsX = x + 30 + colW
    dxDrawRectangle(emsX, y + 55, colW, 360, tocolor(18, 28, 45, 240), false)
    dxDrawRectangle(emsX, y + 55, colW, 2, tocolor(255, 70, 70, 255), false)
    dxDrawText("EMS EMERGENCY MEDICAL", emsX + 15, y + 68, emsX + colW, y + 90, tocolor(255, 90, 90, 255), 1.0, "default-bold", "left", "top")
    dxDrawText("Headquarters: Cape Town Provincial / All Saints Hospital\nRole: Respond to 911 medical dispatches, revive downed citizens, stabilize trauma patients, and operate ambulance fleets.", emsX + 15, y + 95, emsX + colW - 15, y + 150, tocolor(170, 185, 200, 255), 0.85, "default", "left", "top", true, true)

    dxDrawText("EMS COMMANDS:\n• /ems or /medic - Clock ON/OFF Paramedic Duty\n• /heal - Treat and heal nearby citizen\n• /revive - Resuscitate critically injured player\n• /loadambulance - Transport patient to hospital", emsX + 15, y + 155, emsX + colW - 15, y + 280, tocolor(200, 215, 230, 255), 0.85, "default", "left", "top")

    local emsBtnHover = isMouseIn(emsX + 15, y + 330, colW - 30, 42)
    dxDrawRectangle(emsX + 15, y + 330, colW - 30, 42, emsBtnHover and tocolor(255, 70, 70, 255) or tocolor(200, 45, 45, 255), false)
    dxDrawText("TOGGLE EMS MEDIC DUTY", emsX + 15, y + 330, emsX + colW - 15, y + 372, tocolor(255, 255, 255, 255), 0.9, "default-bold", "center", "center")
end

-- TAB 3: Careers & Jobs
function Mzansi.Dashboard.renderJobs(x, y, w, h)
    dxDrawText("CAREER OPPORTUNITIES & EMPLOYMENT DIRECTORY", x + 25, y + 15, x + w - 25, y + 35, tocolor(200, 170, 50, 255), 1.1, "default-bold", "left", "top")
    dxDrawText("Apply for any job immediately or set a GPS waypoint to its headquarters:", x + 25, y + 38, x + w - 25, y + 55, tocolor(160, 175, 190, 255), 0.85, "default", "left", "top")

    local itemY = y + 65
    for i, job in ipairs(JOBS_LIST) do
        local isEven = i % 2 == 0
        dxDrawRectangle(x + 20, itemY, w - 40, 40, isEven and tocolor(20, 32, 50, 200) or tocolor(15, 24, 38, 200), false)

        dxDrawText(job.name, x + 35, itemY, x + 160, itemY + 40, tocolor(255, 255, 255, 255), 0.9, "default-bold", "left", "center")
        dxDrawText(job.pay, x + 170, itemY, x + 280, itemY + 40, tocolor(50, 220, 100, 255), 0.85, "default-bold", "left", "center")
        dxDrawText(job.desc, x + 290, itemY, x + w - 200, itemY + 40, tocolor(160, 175, 190, 255), 0.8, "default", "left", "center", true, false)

        -- Apply Button
        local appHover = isMouseIn(x + w - 190, itemY + 6, 75, 28)
        dxDrawRectangle(x + w - 190, itemY + 6, 75, 28, appHover and tocolor(218, 184, 64, 255) or tocolor(200, 170, 50, 255), false)
        dxDrawText("APPLY", x + w - 190, itemY + 6, x + w - 115, itemY + 34, tocolor(10, 18, 30, 255), 0.8, "default-bold", "center", "center")

        -- GPS Button
        local gpsHover = isMouseIn(x + w - 105, itemY + 6, 75, 28)
        dxDrawRectangle(x + w - 105, itemY + 6, 75, 28, gpsHover and tocolor(50, 130, 220, 255) or tocolor(35, 90, 160, 255), false)
        dxDrawText("GPS", x + w - 105, itemY + 6, x + w - 30, itemY + 34, tocolor(255, 255, 255, 255), 0.8, "default-bold", "center", "center")

        itemY = itemY + 44
    end
end

-- TAB 4: My Assets
function Mzansi.Dashboard.renderAssets(x, y, w, h)
    dxDrawText("PROPERTY, VEHICLE & INVESTMENT PORTFOLIO", x + 25, y + 15, x + w - 25, y + 35, tocolor(200, 170, 50, 255), 1.1, "default-bold", "left", "top")

    local cash = getElementData(localPlayer, "mzansi:cash") or 0
    local bank = getElementData(localPlayer, "mzansi:bank") or 0

    local cards = {
        { title = "WALLET", val = Mzansi.Util.formatMoney(cash), col = tocolor(50, 220, 100, 255) },
        { title = "BANK", val = Mzansi.Util.formatMoney(bank), col = tocolor(100, 180, 255, 255) },
        { title = "VEHICLE SLOTS", val = tostring(Mzansi.MarketUI and (Mzansi.MarketUI._portfolio and #Mzansi.MarketUI._portfolio.vehicles or 0) or 0) .. " / " .. tostring(Mzansi.Config.Server.maxVehiclesPerPlayer), col = tocolor(255, 215, 0, 255) },
        { title = "HOUSE SLOTS", val = tostring(Mzansi.MarketUI and (Mzansi.MarketUI._portfolio and #Mzansi.MarketUI._portfolio.properties or 0) or 0) .. " / " .. tostring(Mzansi.Config.Server.maxHousesPerPlayer), col = tocolor(200, 150, 255, 255) },
    }

    local cardW = (w - 70) / 4
    local cx = x + 25
    for _, card in ipairs(cards) do
        dxDrawRectangle(cx, y + 50, cardW, 65, tocolor(20, 32, 50, 240), false)
        dxDrawRectangle(cx, y + 50, cardW, 2, card.col, false)
        dxDrawText(card.title, cx + 10, y + 57, cx + cardW - 10, y + 73, tocolor(130, 150, 170, 255), 0.75, "default-bold", "left", "top")
        dxDrawText(card.val, cx + 10, y + 77, cx + cardW - 10, y + 105, card.col, 1.0, "default-bold", "left", "top")
        cx = cx + cardW + 7
    end

    dxDrawText("OWNED PROPERTIES", x + 25, y + 135, x + w - 25, y + 155, tocolor(200, 170, 50, 255), 0.95, "default-bold", "left", "top")
    local props = (Mzansi.MarketUI and Mzansi.MarketUI._portfolio and Mzansi.MarketUI._portfolio.properties) or {}
    if #props == 0 then
        dxDrawText("No properties owned. Visit a green house marker and press B, or open the Asset Market.", x + 25, y + 160, x + w - 25, y + 185, tocolor(150, 170, 190, 255), 0.85, "default", "left", "top")
    else
        local py = y + 160
        for i, p in ipairs(props) do
            if i > 6 then break end
            dxDrawText("- " .. tostring(p.name) .. "  (" .. Mzansi.Util.formatMoney(p.price or 0) .. ")", x + 35, py, x + w - 25, py + 20, tocolor(180, 220, 180, 255), 0.85, "default", "left", "top")
            py = py + 22
        end
    end

    dxDrawText("ASSET MARKET", x + 25, y + 300, x + w - 25, y + 320, tocolor(200, 170, 50, 255), 0.95, "default-bold", "left", "top")
    dxDrawText("Buy cars, boats, aircraft and yield-bearing investments. Dealership marker, /market, F5, or the button below.", x + 25, y + 325, x + w - 25, y + 355, tocolor(170, 185, 200, 255), 0.85, "default", "left", "top")

    local openHover = isMouseIn(x + 25, y + 370, 240, 42)
    dxDrawRectangle(x + 25, y + 370, 240, 42, openHover and tocolor(60, 160, 220, 255) or tocolor(40, 110, 180, 255), false)
    dxDrawText("OPEN ASSET MARKET (F5)", x + 25, y + 370, x + 265, y + 412, tocolor(255, 255, 255, 255), 0.85, "default-bold", "center", "center")

    local gpsHover = isMouseIn(x + 280, y + 370, 240, 42)
    dxDrawRectangle(x + 280, y + 370, 240, 42, gpsHover and tocolor(60, 200, 90, 255) or tocolor(40, 160, 70, 255), false)
    dxDrawText("GPS: DEALERSHIP", x + 280, y + 370, x + 520, y + 412, tocolor(255, 255, 255, 255), 0.85, "default-bold", "center", "center")
end

-- TAB 5: Gangs & Turfs
function Mzansi.Dashboard.renderGangs(x, y, w, h)
    dxDrawText("SOUTH AFRICAN STREET GANGS & TURF WARS", x + 25, y + 15, x + w - 25, y + 35, tocolor(200, 170, 50, 255), 1.1, "default-bold", "left", "top")

    local gangs = {
        { name = "Cape Flats 28s Numbers Gang", hood = "[WC / Cape Town] Idlewood Cape Flats", col = tocolor(240, 200, 50, 255), desc = "Feared prison-born numbers gang operating across Cape Flats & Western Cape.", x = 1950.0, y = -1450.0, z = 13.5 },
        { name = "South Side Kings (SSK)", hood = "[WC / Cape Town] Ganton Lowriders", col = tocolor(40, 120, 255, 255), desc = "Dominant urban crew controlling Ganton, chop shops, and local narcotics.", x = 2244.5, y = -1665.5, z = 15.5 },
        { name = "Crazy Dragons (CD)", hood = "[WC / Cape Town] Market & Chinatown", col = tocolor(255, 60, 60, 255), desc = "Underground triad syndicate running arms, narcotics smuggling, and counterfeit ops.", x = 1920.5, y = -1760.5, z = 13.5 },
        { name = "Zulu Warriors (ZW)", hood = "[KZN / Durban] Garcia Hostels & Harbour", col = tocolor(40, 200, 60, 255), desc = "Fierce KwaZulu brotherhood guarding Durban harbor wharfs, hostels, and coastal transit.", x = -2160.5, y = -235.5, z = 36.5 },
        { name = "Boere Mafia (BM)", hood = "[Gauteng / Jozi] Redsands East Heavy Turf", col = tocolor(200, 150, 0, 255), desc = "Afrikaner heavy-arms syndicate executing CIT cash heists and illegal mining rings.", x = 2270.5, y = 1430.5, z = 11.5 },
        { name = "Nyau Dust Cartel (NDC)", hood = "[Gauteng / Jozi] Old Venturas Strip", col = tocolor(180, 50, 220, 255), desc = "Gauteng fast-money cartel operating crystal meth superlabs and casino laundering.", x = 2480.5, y = 2110.5, z = 11.0 },
    }

    local colW2 = (w - 70) / 2
    local gy = y + 45
    for i, gang in ipairs(gangs) do
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        local gx = x + 25 + col * (colW2 + 20)
        local gyy = gy + row * 72

        dxDrawRectangle(gx, gyy, colW2, 64, tocolor(18, 28, 44, 240), false)
        dxDrawRectangle(gx, gyy, 4, 64, gang.col, false)

        dxDrawText(gang.name, gx + 14, gyy + 8, gx + colW2 - 70, gyy + 26, gang.col, 0.85, "default-bold", "left", "top")
        dxDrawText(gang.hood, gx + 14, gyy + 26, gx + colW2 - 10, gyy + 42, tocolor(200, 170, 50, 220), 0.7, "default", "left", "top")
        dxDrawText(gang.desc, gx + 14, gyy + 42, gx + colW2 - 10, gyy + 60, tocolor(160, 175, 190, 255), 0.7, "default", "left", "top")

        local btnHover = isMouseIn(gx + colW2 - 75, gyy + 14, 62, 30)
        dxDrawRectangle(gx + colW2 - 75, gyy + 14, 62, 30, btnHover and tocolor(50, 130, 220, 255) or tocolor(35, 90, 160, 255), false)
        dxDrawText("SET GPS", gx + colW2 - 75, gyy + 14, gx + colW2 - 13, gyy + 44, tocolor(255, 255, 255, 255), 0.75, "default-bold", "center", "center")
    end

    local cmdY = gy + 3 * 72 + 5
    dxDrawText("GANG COMMANDS:\n• /gang create <tag> <name> - Form a new gang (R100,000)\n• /gang invite <player> - Recruit a member  |  • /gang spray - Spray gang tag to claim territory\n• /gang war <gangId> - Initiate an armed turf war for territory income", x + 25, cmdY, x + w - 25, cmdY + 70, tocolor(180, 195, 210, 255), 0.8, "default", "left", "top")
end

-- TAB 5: Crime & Missions
function Mzansi.Dashboard.renderCrime(x, y, w, h)
    dxDrawText("CRIMINAL HEISTS, ROBBERIES & UNDERGROUND MISSIONS", x + 25, y + 15, x + w - 25, y + 35, tocolor(200, 170, 50, 255), 1.1, "default-bold", "left", "top")

    local crimes = {
        { name = "24/7 Supermarket Robbery", payout = "R 8,000 - R 15,000", req = "Handgun + Mask", loc = "Any 24/7 convenience store across Cape Town", x = 1352.0, y = -1758.0, z = 13.5 },
        { name = "Central Bank Vault Heist", payout = "R 100,000 - R 250,000", req = "Drill + 2+ Crew + Assault Rifles", loc = "Standard Bank Downtown Vault", x = 1460.0, y = -1025.0, z = 23.5 },
        { name = "Jewelry Store Smash & Grab", payout = "R 40,000 - R 80,000", req = "Crowbar or Firearm", loc = "Rodeo / Waterfront Luxury District", x = 450.0, y = -1500.0, z = 20.0 },
        { name = "Armored Cash Van Ambush", payout = "R 60,000 - R 120,000", req = "Explosives or Heavy Arms", loc = "Moving convoy across N1 / N2 highways", x = 1800.0, y = -1600.0, z = 13.5 },
        { name = "Illicit Drug Drop Run", payout = "R 25,000 / shipment", req = "Vehicle + Narcotics Inventory", loc = "Pick up at Cape Flats, drop off at Port", x = 2160.0, y = -1670.0, z = 15.0 },
    }

    local cy = y + 48
    for _, crime in ipairs(crimes) do
        dxDrawRectangle(x + 25, cy, w - 50, 54, tocolor(18, 28, 44, 240), false)
        dxDrawRectangle(x + 25, cy, 4, 54, tocolor(255, 60, 60, 255), false)

        dxDrawText(crime.name .. "  [Payout: " .. crime.payout .. "]", x + 40, cy + 6, x + w - 130, cy + 24, tocolor(255, 80, 80, 255), 0.9, "default-bold", "left", "top")
        dxDrawText("Requirements: " .. crime.req .. "  •  Location: " .. crime.loc, x + 40, cy + 26, x + w - 130, cy + 50, tocolor(160, 175, 190, 255), 0.8, "default", "left", "top")

        local btnHover = isMouseIn(x + w - 120, cy + 10, 85, 32)
        dxDrawRectangle(x + w - 120, cy + 10, 85, 32, btnHover and tocolor(255, 80, 80, 255) or tocolor(200, 45, 45, 255), false)
        dxDrawText("SET GPS", x + w - 120, cy + 10, x + w - 35, cy + 42, tocolor(255, 255, 255, 255), 0.8, "default-bold", "center", "center")

        cy = cy + 60
    end

    dxDrawText("CRIME COMMANDS:\n• /crime rob <id> - Initiate a store/bank robbery  |  • /mask - Put on / take off face mask\n• /drugs sell <player> <type> <amount> - Sell contraband  |  • /market - Access illegal arms market", x + 25, cy + 8, x + w - 25, cy + 55, tocolor(180, 195, 210, 255), 0.8, "default", "left", "top")
end

-- TAB 6: GPS Navigation (Multi-Province Explorer)
function Mzansi.Dashboard.renderGPS(x, y, w, h)
    dxDrawText("SOUTH AFRICAN INTER-PROVINCIAL SATELLITE NAVIGATION", x + 25, y + 12, x + w - 25, y + 32, tocolor(200, 170, 50, 255), 1.1, "default-bold", "left", "top")

    -- Province Selector Pills
    local pW = (w - 50) / #PROVINCES
    local pX = x + 25
    local pY = y + 38
    for _, prov in ipairs(PROVINCES) do
        local isSelected = (Mzansi.Dashboard._activeProvince == prov.id)
        local isHover = isMouseIn(pX, pY, pW - 8, 28)
        local bg = isSelected and tocolor(200, 170, 50, 255) or (isHover and tocolor(35, 55, 85, 255) or tocolor(20, 32, 50, 220))
        local txt = isSelected and tocolor(10, 18, 30, 255) or tocolor(220, 230, 240, 255)

        dxDrawRectangle(pX, pY, pW - 8, 28, bg, false)
        dxDrawText(prov.name, pX, pY, pX + pW - 8, pY + 28, txt, 0.85, "default-bold", "center", "center")
        pX = pX + pW
    end

    -- Destinations Grid for active province
    local activeList = PROVINCE_GPS[Mzansi.Dashboard._activeProvince] or PROVINCE_GPS.wc
    local gy = y + 74
    local colW = (w - 60) / 2
    for i, dest in ipairs(activeList) do
        if i <= 12 then -- Max 6 rows x 2 cols fits in contH 440 (ends ~y+370)
            local colX = (i % 2 == 1) and (x + 25) or (x + 35 + colW)
            local isHover = isMouseIn(colX, gy, colW - 10, 44)

            dxDrawRectangle(colX, gy, colW - 10, 44, isHover and tocolor(25, 45, 75, 255) or tocolor(18, 28, 44, 240), false)
            dxDrawText(dest.name, colX + 12, gy + 6, colX + colW - 85, gy + 24, tocolor(255, 255, 255, 255), 0.88, "default-bold", "left", "top")
            dxDrawText(dest.category, colX + 12, gy + 24, colX + colW - 85, gy + 40, tocolor(200, 170, 50, 200), 0.75, "default", "left", "top")

            local btnHover = isMouseIn(colX + colW - 75, gy + 8, 60, 28)
            dxDrawRectangle(colX + colW - 75, gy + 8, 60, 28, btnHover and tocolor(60, 140, 230, 255) or tocolor(40, 100, 180, 255), false)
            dxDrawText("MARK", colX + colW - 75, gy + 8, colX + colW - 15, gy + 36, tocolor(255, 255, 255, 255), 0.8, "default-bold", "center", "center")

            if i % 2 == 0 then gy = gy + 49 end
        end
    end

    -- Bottom Cancel / Info Bar
    if Mzansi.Dashboard._activeGPS then
        local clearHover = isMouseIn(x + 25, y + 380, w - 50, 35)
        dxDrawRectangle(x + 25, y + 380, w - 50, 35, clearHover and tocolor(255, 60, 60, 255) or tocolor(180, 40, 40, 255), false)
        dxDrawText("❌ CANCEL CURRENT GPS ROUTE (" .. Mzansi.Dashboard._activeGPS.name .. ")", x + 25, y + 380, x + w - 25, y + 415, tocolor(255, 255, 255, 255), 0.9, "default-bold", "center", "center")
    else
        dxDrawText("💡 Click any 'MARK' button above to trace a radar route across South African highways.", x + 25, y + 390, x + w - 25, y + 415, tocolor(150, 170, 190, 200), 0.85, "default", "center", "center")
    end
end

-- TAB 7: Commands
function Mzansi.Dashboard.renderCommands(x, y, w, h)
    dxDrawText("SERVER COMMAND DIRECTORY & SHORTCUTS", x + 25, y + 15, x + w - 25, y + 35, tocolor(200, 170, 50, 255), 1.1, "default-bold", "left", "top")

    local commandCategories = {
        {
            cat = "VEHICLE MANAGEMENT",
            cmds = {
                { cmd = "/engine", desc = "Start or stop vehicle engine" },
                { cmd = "/lock", desc = "Lock or unlock vehicle doors" },
                { cmd = "/refuel", desc = "Refuel the vehicle you're in (costs cash, anywhere)" },
                { cmd = "/rent", desc = "Spawn a rental scooter at Cape Town Airport" },
                { cmd = "/market or F5", desc = "Open Asset Market (cars, boats, planes, investments)" },
                { cmd = "/buyvehicle <kind> <id>", desc = "Buy vehicle directly (car|boat|plane)" },
                { cmd = "/investments", desc = "Open investment portfolio in Asset Market" },
            }
        },
        {
            cat = "POLICE & LAW ENFORCEMENT",
            cmds = {
                { cmd = "/duty or /cop", desc = "Clock ON/OFF SAPS police duty and armory" },
                { cmd = "/cuff", desc = "Handcuff or uncuff a suspect" },
                { cmd = "/arrest <sec>", desc = "Jail handcuffed suspect at police station" },
                { cmd = "/ticket <amt> <rsn>", desc = "Issue a traffic or criminal ticket fine" },
                { cmd = "/frisk", desc = "Search nearby player for contraband/weapons" },
            }
        },
        {
            cat = "CAREERS & GANGS",
            cmds = {
                { cmd = "/job apply <id>", desc = "Apply for a job (Trucker, Taxi, Mechanic)" },
                { cmd = "/gang create", desc = "Form a new street gang (R100,000)" },
                { cmd = "/gang invite", desc = "Invite a citizen to your gang" },
                { cmd = "/gang spray", desc = "Spray graffiti tag on territory walls" },
            }
        },
        {
            cat = "SYSTEM & UTILITIES",
            cmds = {
                { cmd = "F2 or X or /help",  desc = "Toggle this interactive Mzansi Roleplay Dashboard" },
                { cmd = "F4",                 desc = "Quick open Gangs & Turfs panel" },
                { cmd = "F9/NumLock or /phone", desc = "Open Mzansi Mobile (Calls, SMS, Bank, 911)" },
                { cmd = "F10/ScrollLock",     desc = "Open Bank UI" },
                { cmd = "/inv",               desc = "Open player pocket inventory" },
                { cmd = "/fixcam",            desc = "Self-healing instant camera reset command" },
            }
        },
    }

    local cy = y + 40
    for _, group in ipairs(commandCategories) do
        dxDrawText(group.cat, x + 25, cy, x + w - 25, cy + 16, tocolor(200, 170, 50, 255), 0.8, "default-bold", "left", "top")
        cy = cy + 18
        for _, c in ipairs(group.cmds) do
            dxDrawText(c.cmd, x + 35, cy, x + 220, cy + 16, tocolor(100, 200, 255, 255), 0.8, "default-bold", "left", "top")
            dxDrawText(c.desc, x + 230, cy, x + w - 25, cy + 16, tocolor(170, 185, 200, 255), 0.8, "default", "left", "top")
            cy = cy + 17
        end
        cy = cy + 6
    end
end

-- Handle Mouse Click on Dashboard
addEventHandler("onClientClick", root, function(button, state)
    if not Mzansi.Dashboard._visible then return end
    if button ~= "left" or state ~= "down" then return end

    local sx, sy = guiGetScreenSize()
    local w, h = 860, 560
    local x = (sx - w) / 2
    local y = (sy - h) / 2

    -- Tab Click Detection
    local tabX = x + 20
    local tabY = y + 58
    local tabW = (w - 40) / #TABS
    for _, tab in ipairs(TABS) do
        if isMouseIn(tabX, tabY, tabW - 4, 32) then
            Mzansi.Dashboard._currentTab = tab.id
            playSoundFrontEnd(40)
            return
        end
        tabX = tabX + tabW
    end

    -- Tab Specific Button Actions
    local tab = Mzansi.Dashboard._currentTab
    if tab == "overview" then
        if isMouseIn(x + 25, y + 360, 210, 42) then
            triggerServerEvent("mzansi:world:requestRental", localPlayer)
            Mzansi.Dashboard.toggle()
        elseif isMouseIn(x + 245, y + 360, 210, 42) then
            Mzansi.Dashboard.setGPS("Civic Centre & Job Center", 1481.5, -1745.5, 13.5)
            Mzansi.Dashboard.toggle()
        elseif isMouseIn(x + 465, y + 360, 250, 42) then
            triggerServerEvent("mzansi:activity:requestMission", localPlayer)
            Mzansi.Dashboard.toggle()
        end

    elseif tab == "factions" then
        local colW = (w - 60) / 2
        if isMouseIn(x + 35, y + 330, colW - 30, 42) then
            triggerServerEvent("mzansi:world:toggleSAPS", localPlayer)
        elseif isMouseIn(x + 30 + colW + 15, y + 330, colW - 30, 42) then
            triggerServerEvent("mzansi:world:toggleEMS", localPlayer)
        end

    elseif tab == "jobs" then
        local itemY = y + 65
        for _, job in ipairs(JOBS_LIST) do
            if isMouseIn(x + w - 190, itemY + 6, 75, 28) then
                triggerServerEvent("mzansi:jobs:apply", localPlayer, job.id)
                return
            elseif isMouseIn(x + w - 105, itemY + 6, 75, 28) then
                Mzansi.Dashboard.setGPS(job.name .. " Depot", job.x, job.y, job.z)
                Mzansi.Dashboard.toggle()
                return
            end
            itemY = itemY + 44
        end

    elseif tab == "assets" then
        if isMouseIn(x + 25, y + 370, 240, 42) then
            Mzansi.Dashboard.toggle()
            if Mzansi.MarketUI then
                Mzansi.MarketUI.open()
            else
                triggerServerEvent("mzansi:market:open", localPlayer)
            end
            return
        elseif isMouseIn(x + 280, y + 370, 240, 42) then
            Mzansi.Dashboard.setGPS("Mzansi Auto Dealership", 2131.5, -1150.5, 24.0)
            Mzansi.Dashboard.toggle()
            return
        end

    elseif tab == "gangs" then
        local gangs = {
            { name = "Cape Flats 28s Numbers Gang (Idlewood)", x = 1950.0, y = -1450.0, z = 13.5 },
            { name = "South Side Kings (Ganton)", x = 2244.5, y = -1665.5, z = 15.5 },
            { name = "Crazy Dragons (Market)", x = 1920.5, y = -1760.5, z = 13.5 },
            { name = "Zulu Warriors (Durban Garcia Hostels)", x = -2160.5, y = -235.5, z = 36.5 },
            { name = "Boere Mafia (Jozi Redsands East)", x = 2270.5, y = 1430.5, z = 11.5 },
            { name = "Nyau Dust Cartel (Jozi Old Venturas)", x = 2480.5, y = 2110.5, z = 11.0 },
        }
        local colW2 = (w - 70) / 2
        local gy = y + 45
        for i, gang in ipairs(gangs) do
            local col = (i - 1) % 2
            local row = math.floor((i - 1) / 2)
            local gx = x + 25 + col * (colW2 + 20)
            local gyy = gy + row * 72
            if isMouseIn(gx + colW2 - 75, gyy + 14, 62, 30) then
                Mzansi.Dashboard.setGPS(gang.name, gang.x, gang.y, gang.z)
                Mzansi.Dashboard.toggle()
                return
            end
        end

    elseif tab == "crime" then
        local crimes = {
            { name = "24/7 Supermarket Robbery", x = 1352.0, y = -1758.0, z = 13.5 },
            { name = "Standard Bank Central Vault Heist", x = 1460.0, y = -1025.0, z = 23.5 },
            { name = "Jewelry Store Smash & Grab", x = 450.0, y = -1500.0, z = 20.0 },
            { name = "Armored Cash Van Ambush", x = 1800.0, y = -1600.0, z = 13.5 },
            { name = "Illicit Drug Drop Run", x = 2160.0, y = -1670.0, z = 15.0 },
        }
        local cy = y + 48
        for _, crime in ipairs(crimes) do
            if isMouseIn(x + w - 120, cy + 10, 85, 32) then
                Mzansi.Dashboard.setGPS(crime.name, crime.x, crime.y, crime.z)
                Mzansi.Dashboard.toggle()
                return
            end
            cy = cy + 60
        end

    elseif tab == "gps" then
        -- Province selection clicks
        local pW = (w - 50) / #PROVINCES
        local pX = x + 25
        local pY = y + 38
        for _, prov in ipairs(PROVINCES) do
            if isMouseIn(pX, pY, pW - 8, 28) then
                Mzansi.Dashboard._activeProvince = prov.id
                playSoundFrontEnd(40)
                return
            end
            pX = pX + pW
        end

        -- Destination clicks for active province
        local activeList = PROVINCE_GPS[Mzansi.Dashboard._activeProvince] or PROVINCE_GPS.wc
        local gy = y + 74
        local colW = (w - 60) / 2
        for i, dest in ipairs(activeList) do
            if i <= 12 then
                local colX = (i % 2 == 1) and (x + 25) or (x + 35 + colW)
                if isMouseIn(colX + colW - 75, gy + 8, 60, 28) then
                    Mzansi.Dashboard.setGPS(dest.name, dest.x, dest.y, dest.z)
                    Mzansi.Dashboard.toggle()
                    return
                end
                if i % 2 == 0 then gy = gy + 49 end
            end
        end

        -- Cancel active GPS route
        if Mzansi.Dashboard._activeGPS and isMouseIn(x + 25, y + 380, w - 50, 35) then
            Mzansi.Dashboard.clearGPS()
            outputChatBox("[Mzansi-GPS] Active route cancelled.", 255, 100, 100)
            playSoundFrontEnd(42)
        end
    end
end)

-- GPS Helper Functions
function Mzansi.Dashboard.setGPS(name, gx, gy, gz)
    Mzansi.Dashboard.clearGPS()

    Mzansi.Dashboard._activeGPS = { name = name, x = gx, y = gy, z = gz }
    Mzansi.Dashboard._activeGPSMarker = createMarker(gx, gy, gz, "checkpoint", 4.0, 255, 200, 0, 180)
    Mzansi.Dashboard._activeGPSBlip = createBlip(gx, gy, gz, 41, 3, 255, 200, 0, 255)

    local px, py, pz = getElementPosition(localPlayer)
    local distKm = string.format("%.1f", getDistanceBetweenPoints3D(px, py, pz, gx, gy, gz) / 1000)

    outputChatBox("[Mzansi-GPS] Route set to: " .. name .. " (" .. distKm .. " km)! Follow the radar marker.", 50, 255, 50)
    playSoundFrontEnd(40)
end

function Mzansi.Dashboard.clearGPS()
    if Mzansi.Dashboard._activeGPSMarker and isElement(Mzansi.Dashboard._activeGPSMarker) then
        destroyElement(Mzansi.Dashboard._activeGPSMarker)
    end
    if Mzansi.Dashboard._activeGPSBlip and isElement(Mzansi.Dashboard._activeGPSBlip) then
        destroyElement(Mzansi.Dashboard._activeGPSBlip)
    end
    Mzansi.Dashboard._activeGPS = nil
    Mzansi.Dashboard._activeGPSMarker = nil
    Mzansi.Dashboard._activeGPSBlip = nil
end

-- ===================================================================
-- KEYBINDS — Conflict-free layout (FULL MAP)
--   F1  = FREE — default GTA SA scoreboard / help
--   F2  = Mzansi Dashboard (primary)
--   F3  = Flight Board (flight_ui.lua)
--   F4  = Quick-open Gangs & Turfs tab
--   F5  = FREE
--   F6  = Radio (mzansi_radio)
--   F7  = Admin Panel (mzansi_admin)
--   F8  = Freeroam / Creator Menu
--   F9/NumLock = Phone, F10/ScrollLock = Bank
--   E   = Activity interact (activity_client.lua)
--   X   = Close dashboard (when open)
--   MMB = Radio quick-cycle
-- ===================================================================
-- F1 is reserved for default Freeroam GUI (freeroam.zip "Press F1 to show/hide controls")
-- Dashboard: F2 primary; F1 REMOVED to avoid conflict with default freeroam
bindKey("f2", "down", function()
    if Mzansi.Util and Mzansi.Util.bindBlocked and Mzansi.Util.bindBlocked() then return end
    Mzansi.Dashboard.toggle()
end)

bindKey("x", "down", function()
    if Mzansi.Dashboard._visible then
        Mzansi.Dashboard.toggle()
    end
end)

bindKey("f4", "down", function()
    if Mzansi.Util and Mzansi.Util.bindBlocked and Mzansi.Util.bindBlocked() then return end
    Mzansi.Dashboard.openTab("gangs")
end)

addCommandHandler("help", function()
    Mzansi.Dashboard.toggle()
end)

addCommandHandler("rp", function()
    Mzansi.Dashboard.toggle()
end)

addCommandHandler("guide", function()
    Mzansi.Dashboard.toggle()
end)

addCommandHandler("dashboard", function()
    Mzansi.Dashboard.toggle()
end)

addCommandHandler("keys", function()
    if Mzansi.Modal and Mzansi.Modal.keybindHelp then
        Mzansi.Modal.keybindHelp()
    else
        outputChatBox("#00C8FF[KEYS] #FFFFFFF1=FR F2=Dashboard F3=Flight F4=Gangs F6=Radio F7=Admin F8=Creator F9/NumLock=Phone F10/ScrollLock=Bank E=Interact SPACE=Skip cutscene", 255, 255, 255, true)
    end
end)

addCommandHandler("gps", function(cmd, target)
    Mzansi.Dashboard.openTab("gps")
end)

addEvent("mzansi:dashboard:openJobs", true)
addEventHandler("mzansi:dashboard:openJobs", root, function()
    Mzansi.Dashboard.openTab("jobs")
end)
