-- ============================================================
-- MZANSI FREEROAM CREATOR MENU — CLIENT SIDE
-- mzansi_freeroam/client/freeroam_menu.lua
-- Opened by F8 / /ngamla. Requires admin_level >= 1.
-- Pure dxDraw, no CEF, no GUIs.
-- ============================================================

local FR = {}
FR._visible      = false
FR._adminLevel   = 0
FR._currentTab   = "vehicles"
FR._notification = { text = "", color = { 255, 255, 255 }, expiry = 0 }
FR._input        = {}   -- active text fields (keyed by field name)
FR._focused      = nil  -- currently focused text field name

-- Vehicle search
FR._vehicleSearch = ""
FR._vehicleScroll = 0

-- ============================================================
-- VEHICLE DATA (GTA:SA complete list 400-611)
-- ============================================================

local GTA_VEHICLES = {
    { id = 400, name = "Landstalker" },    { id = 401, name = "Bravura" },
    { id = 402, name = "Buffalo" },         { id = 403, name = "Linerunner" },
    { id = 404, name = "Perenniel" },       { id = 405, name = "Sentinel" },
    { id = 406, name = "Dumper" },          { id = 407, name = "Firetruck" },
    { id = 408, name = "Trashmaster" },     { id = 409, name = "Stretch" },
    { id = 410, name = "Manana" },          { id = 411, name = "Infernus" },
    { id = 412, name = "Voodoo" },          { id = 413, name = "Pony" },
    { id = 414, name = "Mule" },            { id = 415, name = "Cheetah" },
    { id = 416, name = "Ambulance" },       { id = 417, name = "Leviathan" },
    { id = 418, name = "Moonbeam" },        { id = 419, name = "Esperanto" },
    { id = 420, name = "Taxi" },            { id = 421, name = "Washington" },
    { id = 422, name = "Bobcat" },          { id = 423, name = "Mr Whoopee" },
    { id = 424, name = "BF Injection" },    { id = 425, name = "Hunter" },
    { id = 426, name = "Premier" },         { id = 427, name = "Enforcer" },
    { id = 428, name = "Securicar" },       { id = 429, name = "Banshee" },
    { id = 430, name = "Predator" },        { id = 431, name = "Bus" },
    { id = 432, name = "Rhino" },           { id = 433, name = "Barracks OL" },
    { id = 434, name = "Hotknife" },        { id = 435, name = "Trailer 1" },
    { id = 436, name = "Previon" },         { id = 437, name = "Coach" },
    { id = 438, name = "Cabbie" },          { id = 439, name = "Stallion" },
    { id = 440, name = "Rumpo" },           { id = 441, name = "RC Bandit" },
    { id = 442, name = "Romero" },          { id = 443, name = "Packer" },
    { id = 444, name = "Monster" },         { id = 445, name = "Admiral" },
    { id = 446, name = "Squalo" },          { id = 447, name = "Seasparrow" },
    { id = 448, name = "Pizzaboy" },        { id = 449, name = "Tram" },
    { id = 450, name = "Trailer 2" },       { id = 451, name = "Turismo" },
    { id = 452, name = "Speeder" },         { id = 453, name = "Reefer" },
    { id = 454, name = "Tropic" },          { id = 455, name = "Flatbed" },
    { id = 456, name = "Yankee" },          { id = 457, name = "Caddy" },
    { id = 458, name = "Solair" },          { id = 459, name = "Topfun Van" },
    { id = 460, name = "Skimmer" },         { id = 461, name = "PCJ-600" },
    { id = 462, name = "Faggio" },          { id = 463, name = "Freeway" },
    { id = 464, name = "RC Baron" },        { id = 465, name = "RC Raider" },
    { id = 466, name = "Glendale" },        { id = 467, name = "Oceanic" },
    { id = 468, name = "Sanchez" },         { id = 469, name = "Sparrow" },
    { id = 470, name = "Patriot" },         { id = 471, name = "Quad" },
    { id = 472, name = "Coastguard" },      { id = 473, name = "Dinghy" },
    { id = 474, name = "Hermes" },          { id = 475, name = "Sabre" },
    { id = 476, name = "Rustler" },         { id = 477, name = "ZR-350" },
    { id = 478, name = "Walton" },          { id = 479, name = "Regina" },
    { id = 480, name = "Comet" },           { id = 481, name = "BMX" },
    { id = 482, name = "Burrito" },         { id = 483, name = "Camper" },
    { id = 484, name = "Marquis" },         { id = 485, name = "Baggage" },
    { id = 486, name = "Dozer" },           { id = 487, name = "Maverick" },
    { id = 488, name = "News Heli" },       { id = 489, name = "Rancher" },
    { id = 490, name = "FBI Rancher" },     { id = 491, name = "Virgo" },
    { id = 492, name = "Greenwood" },       { id = 493, name = "Jetmax" },
    { id = 494, name = "Hotring A" },       { id = 495, name = "Sandking" },
    { id = 496, name = "Blista Compact" },  { id = 497, name = "Police Maverick" },
    { id = 498, name = "Boxville" },        { id = 499, name = "Benson" },
    { id = 500, name = "Mesa" },            { id = 501, name = "RC Goblin" },
    { id = 502, name = "Hotring B" },       { id = 503, name = "Hotring C" },
    { id = 504, name = "Bloodring B" },     { id = 505, name = "Rancher" },
    { id = 506, name = "Super GT" },        { id = 507, name = "Elegant" },
    { id = 508, name = "Journey" },         { id = 509, name = "Bike" },
    { id = 510, name = "Mountain Bike" },   { id = 511, name = "Beagle" },
    { id = 512, name = "Cropdust" },        { id = 513, name = "Stuntplane" },
    { id = 514, name = "Tanker" },          { id = 515, name = "Roadtrain" },
    { id = 516, name = "Nebula" },          { id = 517, name = "Majestic" },
    { id = 518, name = "Buccaneer" },       { id = 519, name = "Shamal" },
    { id = 520, name = "Hydra" },           { id = 521, name = "FCR-900" },
    { id = 522, name = "NRG-500" },         { id = 523, name = "HPV1000" },
    { id = 524, name = "Cement Truck" },    { id = 525, name = "Towtruck" },
    { id = 526, name = "Fortune" },         { id = 527, name = "Cadrona" },
    { id = 528, name = "FBI Truck" },       { id = 529, name = "Willard" },
    { id = 530, name = "Forklift" },        { id = 531, name = "Tractor" },
    { id = 532, name = "Combine" },         { id = 533, name = "Feltzer" },
    { id = 534, name = "Remington" },       { id = 535, name = "Slamvan" },
    { id = 536, name = "Blade" },           { id = 537, name = "Freight" },
    { id = 538, name = "Streak" },          { id = 539, name = "Vortex" },
    { id = 540, name = "Vincent" },         { id = 541, name = "Bullet" },
    { id = 542, name = "Clover" },          { id = 543, name = "Sadler" },
    { id = 544, name = "Firetruck LA" },    { id = 545, name = "Hustler" },
    { id = 546, name = "Intruder" },        { id = 547, name = "Primo" },
    { id = 548, name = "Cargobob" },        { id = 549, name = "Tampa" },
    { id = 550, name = "Sunrise" },         { id = 551, name = "Merit" },
    { id = 552, name = "Utility Van" },     { id = 553, name = "Nevada" },
    { id = 554, name = "Yosemite" },        { id = 555, name = "Windsor" },
    { id = 556, name = "Monster A" },       { id = 557, name = "Monster B" },
    { id = 558, name = "Uranus" },          { id = 559, name = "Jester" },
    { id = 560, name = "Sultan" },          { id = 561, name = "Stratum" },
    { id = 562, name = "Elegy" },           { id = 563, name = "Raindance" },
    { id = 564, name = "RC Tiger" },        { id = 565, name = "Flash" },
    { id = 566, name = "Tahoma" },          { id = 567, name = "Savanna" },
    { id = 568, name = "Bandito" },         { id = 569, name = "Freight Flat" },
    { id = 570, name = "Streak Carriage" }, { id = 571, name = "Kart" },
    { id = 572, name = "Mower" },           { id = 573, name = "Duneride" },
    { id = 574, name = "Sweeper" },         { id = 575, name = "Broadway" },
    { id = 576, name = "Tornado" },         { id = 577, name = "AT-400" },
    { id = 578, name = "DFT-30" },          { id = 579, name = "Huntley" },
    { id = 580, name = "Stafford" },        { id = 581, name = "BF-400" },
    { id = 582, name = "Newsvan" },         { id = 583, name = "Tug" },
    { id = 584, name = "Petroc Trailer" },  { id = 585, name = "Emperor" },
    { id = 586, name = "Wayfarer" },        { id = 587, name = "Euros" },
    { id = 588, name = "Hotdog" },          { id = 589, name = "Club" },
    { id = 590, name = "Freight Box" },     { id = 591, name = "Artict3" },
    { id = 592, name = "Andromada" },       { id = 593, name = "Dodo" },
    { id = 594, name = "RC Cam" },          { id = 595, name = "Launch" },
    { id = 596, name = "Police LS" },       { id = 597, name = "Police SF" },
    { id = 598, name = "Police LV" },       { id = 599, name = "Police Ranger" },
    { id = 600, name = "Picador" },         { id = 601, name = "S.W.A.T." },
    { id = 602, name = "Alpha" },           { id = 603, name = "Phoenix" },
    { id = 604, name = "Glendale Shit" },   { id = 605, name = "Sadler Shit" },
    { id = 606, name = "Baggage Trailer" }, { id = 607, name = "Tug Stairs" },
    { id = 608, name = "Boxfreight" },      { id = 609, name = "Farm Trailer" },
    { id = 610, name = "Street Sign" },     { id = 611, name = "Tumbleweed" },
}

local GTA_WEAPONS = {
    { id = 1,  name = "Brass Knuckles" }, { id = 2,  name = "Golf Club" },
    { id = 3,  name = "Nightstick" },     { id = 4,  name = "Knife" },
    { id = 5,  name = "Baseball Bat" },   { id = 6,  name = "Shovel" },
    { id = 7,  name = "Pool Cue" },       { id = 8,  name = "Katana" },
    { id = 9,  name = "Chainsaw" },       { id = 22, name = "9mm Pistol" },
    { id = 23, name = "Silenced 9mm" },   { id = 24, name = "Desert Eagle" },
    { id = 25, name = "Shotgun" },        { id = 26, name = "Sawn-Off Shotgun" },
    { id = 27, name = "Combat Shotgun" }, { id = 28, name = "Micro SMG (Uzi)" },
    { id = 29, name = "MP5" },            { id = 30, name = "AK-47" },
    { id = 31, name = "M4 Carbine" },     { id = 32, name = "Tec-9" },
    { id = 33, name = "Country Rifle" },  { id = 34, name = "Sniper Rifle" },
    { id = 35, name = "RPG" },            { id = 36, name = "Heat-Seeking RPG" },
    { id = 37, name = "Flamethrower" },   { id = 38, name = "Minigun" },
    { id = 39, name = "Satchel Charge" }, { id = 40, name = "Detonator" },
    { id = 41, name = "Spraycan" },       { id = 42, name = "Fire Extinguisher" },
    { id = 43, name = "Camera" },         { id = 44, name = "Night Vision" },
    { id = 45, name = "Thermal Vision" }, { id = 46, name = "Parachute" },
}

local WEATHER_PRESETS = {
    { id = 0,  name = "Extra Sunny LS" },  { id = 1,  name = "Sunny LS" },
    { id = 2,  name = "Cloudy LS" },       { id = 3,  name = "Foggy SF" },
    { id = 4,  name = "Overcast" },        { id = 5,  name = "Rainy" },
    { id = 6,  name = "Thunderstorm" },    { id = 7,  name = "Sunny Smoggy LS" },
    { id = 8,  name = "Overcast Windy" },  { id = 9,  name = "Sunny Country" },
    { id = 10, name = "Sunny Country 2" }, { id = 11, name = "Sunny" },
    { id = 12, name = "Extra Sunny SM" },  { id = 13, name = "Overcast LV" },
    { id = 14, name = "Overcast Dry" },    { id = 15, name = "Heatwave" },
    { id = 16, name = "Dry Sky" },         { id = 17, name = "Sunny Evening" },
    { id = 18, name = "Cloudy Evening" },  { id = 19, name = "Cloudy Night" },
    { id = 20, name = "Clear Night" },     { id = 21, name = "Rainy Night" },
}

local TABS = {
    { id = "vehicles", label = "🚗 Vehicles" },
    { id = "weapons",  label = "🔫 Weapons" },
    { id = "teleport", label = "📍 Teleport" },
    { id = "money",    label = "💰 Money & Stats" },
    { id = "world",    label = "🌍 World" },
    { id = "objects",  label = "📦 Objects" },
}

local W, H        = 900, 580
local HEADER_H    = 50
local TAB_H       = 36
local CONTENT_OFF = HEADER_H + TAB_H + 8

-- ============================================================
-- HELPERS
-- ============================================================

local function mx_in(px, py, pw, ph)
    local cx, cy = getCursorPosition()
    if not cx or not cy then return false end
    local sw, sh = guiGetScreenSize()
    cx, cy = cx * sw, cy * sh
    return cx >= px and cx <= px + pw and cy >= py and cy <= py + ph
end

local function notify(text, isError)
    FR._notification.text   = text
    FR._notification.color  = isError and { 255, 80, 80 } or { 60, 220, 100 }
    FR._notification.expiry = getTickCount() + 4000
end

-- Scrolling vehicle list state
local _veScroll     = 0
local _veSearch     = ""
local _weScroll     = 0
local _wSearch      = ""
local _wxScroll     = 0
local _objModelInput = ""
local _timeHour     = 12
local _timeMinute   = 0
local _weatherId    = 0
local _ammoInput    = "500"

-- Input fields table: { fieldName = currentValue }
local _fields = {
    tpX       = "",
    tpY       = "",
    tpZ       = "",
    moneyAmt  = "1000",
    objModel  = "",
    ammo      = "500",
    veSearch  = "",
    wSearch   = "",
}
local _focused = nil   -- which field is focused

-- ============================================================
-- OPEN / CLOSE
-- ============================================================

function FR.open()
    if isChatBoxInputActive() or isConsoleActive() then return end
    triggerServerEvent("mzansi:freeroam:requestOpen", localPlayer)
end

function FR.close()
    FR._visible = false
    _focused    = nil
    showCursor(false)
end

function FR.toggle()
    if FR._visible then FR.close() else FR.open() end
end

-- Mutual exclusion close event (called by dashboard/phone/radio open)
addEvent("mzansi:freeroam:close", false)
addEventHandler("mzansi:freeroam:close", localPlayer, function()
    if FR._visible then FR.close() end
end)

-- ============================================================
-- SERVER RESPONSE EVENTS
-- ============================================================

addEvent("mzansi:freeroam:granted", true)
addEventHandler("mzansi:freeroam:granted", root, function(lvl)
    FR._visible    = true
    FR._adminLevel = tonumber(lvl) or 1
    FR._currentTab = "vehicles"
    _veScroll      = 0
    _fields.veSearch = ""
    -- Close others FIRST (they may call showCursor(false)), then claim cursor
    triggerEvent("mzansi:phone:close", localPlayer)
    triggerEvent("mzansi:dashboard:close", localPlayer)
    triggerEvent("mzansi:radio:close", localPlayer)
    triggerEvent("mzansi:admin:close", localPlayer)
    triggerEvent("mzansi:flight:close", localPlayer)
    triggerEvent("mzansi:market:close", localPlayer)
    triggerEvent("mzansi:bank:close", localPlayer)
    triggerEvent("mzansi:shop:closeUI", localPlayer)
    showCursor(true)
    playSoundFrontEnd(41)
end)

addEvent("mzansi:freeroam:denied", true)
addEventHandler("mzansi:freeroam:denied", root, function()
    outputChatBox("[Freeroam] Access denied. Admin level 1+ required.", 255, 80, 80)
end)

addEvent("mzansi:freeroam:success", true)
addEventHandler("mzansi:freeroam:success", root, function(msg)
    notify(msg, false)
    playSoundFrontEnd(40)
end)

addEvent("mzansi:freeroam:error", true)
addEventHandler("mzansi:freeroam:error", root, function(msg)
    notify(msg, true)
    playSoundFrontEnd(42)
end)

-- ============================================================
-- RENDER
-- ============================================================

addEventHandler("onClientRender", root, function()
    -- Global notification banner
    if FR._notification.text ~= "" and getTickCount() < FR._notification.expiry then
        local sw, sh = guiGetScreenSize()
        local col = FR._notification.color
        local bw, bh = 540, 36
        local bx, by = (sw - bw) / 2, sh - 80
        dxDrawRectangle(bx, by, bw, bh, tocolor(10, 15, 25, 220), false)
        dxDrawRectangle(bx, by, bw, 2, tocolor(col[1], col[2], col[3], 255), false)
        dxDrawText(FR._notification.text, bx, by, bx + bw, by + bh,
            tocolor(col[1], col[2], col[3], 255), 0.9, "default-bold", "center", "center")
    elseif getTickCount() >= FR._notification.expiry then
        FR._notification.text = ""
    end

    if not FR._visible then return end

    local sw, sh = guiGetScreenSize()
    local px = (sw - W) / 2
    local py = (sh - H) / 2

    -- Backdrop
    dxDrawRectangle(0, 0, sw, sh, tocolor(4, 8, 15, 165), false)

    -- Panel
    dxDrawRectangle(px, py, W, H, tocolor(10, 16, 26, 252), false)
    dxDrawRectangle(px, py, W, 3, tocolor(80, 220, 130, 255), false)  -- green freeroam accent

    -- Header
    dxDrawRectangle(px, py, W, HEADER_H, tocolor(14, 22, 36, 255), false)
    local headerTitle, headerColor
    if FR._adminLevel >= 1 then
        headerTitle  = "🛠 NGAMLA CREATOR MENU  [Admin Level " .. FR._adminLevel .. "]"
        headerColor  = tocolor(80, 220, 130, 255)
    else
        headerTitle  = "🗺 MZANSI PLAYER MENU  [Province Teleport]"
        headerColor  = tocolor(100, 180, 255, 255)
    end
    dxDrawText(headerTitle, px + 20, py, px + W - 100, py + HEADER_H,
        headerColor, 1.1, "default-bold", "left", "center")
    dxDrawText("F8 to Close",
        px + W - 110, py, px + W - 10, py + HEADER_H,
        tocolor(150, 165, 180, 200), 0.85, "default-bold", "right", "center")

    -- Tabs (Tier-0 only sees teleport; Tier-1+ sees all)
    local tabX = px + 6
    local tabY  = py + HEADER_H + 4
    local tabW  = (W - 12) / #TABS
    for _, tab in ipairs(TABS) do
        local isLocked = (FR._adminLevel < 1) and (tab.id ~= "teleport")
        local isActive = FR._currentTab == tab.id
        local isHov    = (not isLocked) and mx_in(tabX, tabY, tabW - 4, TAB_H - 4)
        local bg  = isLocked  and tocolor(10, 16, 26, 120) or
                    (isActive and tocolor(60, 200, 110, 255) or
                    (isHov   and tocolor(30, 55, 80, 255)   or tocolor(18, 28, 44, 200)))
        local txt = isLocked  and tocolor(60, 70, 90, 180) or
                    (isActive and tocolor(10, 20, 14, 255)  or tocolor(210, 220, 235, 255))
        dxDrawRectangle(tabX, tabY, tabW - 4, TAB_H - 4, bg, false)
        local label = isLocked and (tab.label .. " 🔒") or tab.label
        dxDrawText(label, tabX, tabY, tabX + tabW - 4, tabY + TAB_H - 4,
            txt, 0.78, "default-bold", "center", "center")
        tabX = tabX + tabW
    end

    -- Content
    local cx = px + 12
    local cy = py + CONTENT_OFF
    local cw = W - 24
    local ch = H - CONTENT_OFF - 12

    local t = FR._currentTab
    -- Tier-0 guard: only teleport tab allowed
    if FR._adminLevel < 1 and t ~= "teleport" then
        FR._currentTab = "teleport"
        t = "teleport"
    end

    if     t == "vehicles" then FR.renderVehicles(cx, cy, cw, ch)
    elseif t == "weapons"  then FR.renderWeapons(cx, cy, cw, ch)
    elseif t == "teleport" then FR.renderTeleport(cx, cy, cw, ch)
    elseif t == "money"    then FR.renderMoney(cx, cy, cw, ch)
    elseif t == "world"    then FR.renderWorld(cx, cy, cw, ch)
    elseif t == "objects"  then FR.renderObjects(cx, cy, cw, ch)
    end
end)

-- ============================================================
-- VEHICLES TAB
-- ============================================================

local VE_ROW_H   = 28
local VE_COLS    = 3
local VE_VISIBLE = 14   -- rows per column = 14 x 3 = 42 visible at a time

function FR.renderVehicles(cx, cy, cw, ch)
    -- Search bar
    dxDrawRectangle(cx, cy, cw - 120, 30, tocolor(18, 28, 46, 255), false)
    local sLabel = _focused == "veSearch" and (_fields.veSearch .. "|") or
                   (_fields.veSearch == "" and "🔍 Search vehicles..." or _fields.veSearch)
    local sCol   = _fields.veSearch == "" and tocolor(100, 115, 135, 200) or tocolor(255, 255, 255, 255)
    dxDrawText(sLabel, cx + 8, cy, cx + cw - 128, cy + 30,
        sCol, 0.88, "default", "left", "center")

    -- Repair button
    local repHov = mx_in(cx + cw - 115, cy, 110, 30)
    dxDrawRectangle(cx + cw - 115, cy, 110, 30,
        repHov and tocolor(80, 220, 130, 255) or tocolor(50, 150, 80, 255), false)
    dxDrawText("🔧 Repair Car", cx + cw - 115, cy, cx + cw, cy + 30,
        tocolor(255, 255, 255, 255), 0.82, "default-bold", "center", "center")

    -- Filter
    local search = _fields.veSearch:lower()
    local filtered = {}
    for _, v in ipairs(GTA_VEHICLES) do
        if search == "" or v.name:lower():find(search, 1, true) or tostring(v.id):find(search, 1, true) then
            filtered[#filtered + 1] = v
        end
    end

    local totalRows = math.ceil(#filtered / VE_COLS)
    local colW      = cw / VE_COLS

    local ry = cy + 38
    local rendered = 0
    for row = 1, VE_VISIBLE do
        local actualRow = row + _veScroll
        for col = 1, VE_COLS do
            local idx = (actualRow - 1) * VE_COLS + col
            if idx > #filtered then break end
            local v   = filtered[idx]
            local vx  = cx + (col - 1) * colW
            local isHov = mx_in(vx, ry, colW - 4, VE_ROW_H)
            dxDrawRectangle(vx, ry, colW - 4, VE_ROW_H,
                isHov and tocolor(60, 200, 110, 220) or tocolor(16, 26, 42, 220), false)
            dxDrawText(v.name .. "  [" .. v.id .. "]",
                vx + 8, ry, vx + colW - 4, ry + VE_ROW_H,
                isHov and tocolor(10, 20, 14, 255) or tocolor(215, 225, 240, 255),
                0.78, "default", "left", "center")
        end
        ry = ry + VE_ROW_H
        rendered = rendered + 1
    end

    -- Scroll hint
    if _veScroll > 0 then
        dxDrawText("▲ Scroll Up", cx, ry + 2, cx + 100, ry + 18,
            tocolor(150, 165, 180, 200), 0.75, "default-bold", "left", "top")
    end
    local maxScroll = math.max(0, totalRows - VE_VISIBLE)
    if _veScroll < maxScroll then
        dxDrawText("▼ Scroll Down", cx + 110, ry + 2, cx + 250, ry + 18,
            tocolor(150, 165, 180, 200), 0.75, "default-bold", "left", "top")
    end
    dxDrawText("Showing " .. math.min(VE_VISIBLE * VE_COLS, #filtered) .. " / " .. #filtered,
        cx + cw - 180, ry + 2, cx + cw, ry + 18,
        tocolor(130, 145, 160, 200), 0.75, "default", "right", "top")
end

-- ============================================================
-- WEAPONS TAB
-- ============================================================

local WE_ROW_H = 30
local WE_VIS   = 15

function FR.renderWeapons(cx, cy, cw, ch)
    dxDrawText("Click a weapon to give it to yourself. Change ammo below.",
        cx, cy, cx + cw, cy + 22, tocolor(150, 165, 180, 200), 0.82, "default", "left", "top")

    -- Ammo input
    dxDrawText("Ammo:", cx, cy + 26, cx + 60, cy + 52,
        tocolor(200, 215, 230, 255), 0.88, "default-bold", "left", "center")
    dxDrawRectangle(cx + 65, cy + 26, 120, 26, tocolor(18, 28, 46, 255), false)
    local ammoDisplay = _focused == "ammo" and (_fields.ammo .. "|") or _fields.ammo
    dxDrawText(ammoDisplay, cx + 71, cy + 26, cx + 185, cy + 52,
        tocolor(255, 255, 255, 255), 0.88, "default", "left", "center")

    local wy = cy + 60
    for i = 1, math.min(WE_VIS, #GTA_WEAPONS - _weScroll) do
        local idx = i + _weScroll
        local w   = GTA_WEAPONS[idx]
        if not w then break end

        local isHov = mx_in(cx, wy, cw, WE_ROW_H)
        local bg = isHov and tocolor(60, 200, 110, 220) or
                   (i % 2 == 0 and tocolor(18, 28, 44, 220) or tocolor(14, 22, 36, 220))
        dxDrawRectangle(cx, wy, cw, WE_ROW_H, bg, false)
        dxDrawText(w.name, cx + 10, wy, cx + 200, wy + WE_ROW_H,
            isHov and tocolor(10, 20, 14, 255) or tocolor(220, 230, 245, 255),
            0.85, "default-bold", "left", "center")
        dxDrawText("ID: " .. w.id, cx + 210, wy, cx + 280, wy + WE_ROW_H,
            tocolor(140, 160, 185, 200), 0.8, "default", "left", "center")
        wy = wy + WE_ROW_H
    end

    local scrollY = wy + 4
    if _weScroll > 0 then
        dxDrawText("▲", cx, scrollY, cx + 20, scrollY + 16,
            tocolor(150, 165, 180, 200), 0.8, "default-bold", "center", "top")
    end
    if _weScroll + WE_VIS < #GTA_WEAPONS then
        dxDrawText("▼", cx + 24, scrollY, cx + 44, scrollY + 16,
            tocolor(150, 165, 180, 200), 0.8, "default-bold", "center", "top")
    end
end

-- ============================================================
-- TELEPORT TAB
-- ============================================================

-- Province spawn buttons for Tier-0 and Tier-1 players
local PROVINCE_BUTTONS = {
    { id = "wc",  label = "🌊 Cape Town (Western Cape)",  sub = "Los Santos / LS",         color = { 60, 160, 255 } },
    { id = "kzn", label = "🏖 Durban (KwaZulu-Natal)",    sub = "San Fierro / SF",          color = { 255, 160, 60 } },
    { id = "gp",  label = "🏙 Johannesburg (Gauteng)",    sub = "Las Venturas / LV",        color = { 255, 220, 60 } },
}

function FR.renderTeleport(cx, cy, cw, ch)
    -- Province Teleport Section (visible to ALL players)
    dxDrawText("🗺 Province Quick-Travel", cx, cy + 6, cx + cw, cy + 28,
        tocolor(100, 180, 255, 255), 1.05, "default-bold", "left", "top")
    dxDrawText("Instantly teleport to any South African province.",
        cx, cy + 30, cx + cw, cy + 48, tocolor(140, 160, 185, 200), 0.82, "default", "left", "top")

    local pbY = cy + 54
    local pbW = cw
    local pbH = 44
    for _, prov in ipairs(PROVINCE_BUTTONS) do
        local isHov = mx_in(cx, pbY, pbW, pbH)
        local c     = prov.color
        local alpha = isHov and 255 or 200
        dxDrawRectangle(cx, pbY, pbW, pbH,
            isHov and tocolor(c[1], c[2], c[3], 60) or tocolor(14, 22, 36, 200), false)
        dxDrawRectangle(cx, pbY, 4, pbH, tocolor(c[1], c[2], c[3], alpha), false)
        dxDrawText(prov.label, cx + 14, pbY, cx + pbW, pbY + pbH * 0.6,
            tocolor(c[1], c[2], c[3], 255), 0.95, "default-bold", "left", "center")
        dxDrawText(prov.sub, cx + 14, pbY + pbH * 0.55, cx + pbW, pbY + pbH,
            tocolor(140, 160, 185, 200), 0.78, "default", "left", "center")
        pbY = pbY + pbH + 6
    end

    -- Admin-only: Coordinate Teleport
    if FR._adminLevel >= 1 then
        local secY = pbY + 12
        dxDrawRectangle(cx, secY, cw, 1, tocolor(50, 70, 100, 180), false)
        dxDrawText("📍 Coordinate Teleport (Admin)", cx, secY + 8, cx + cw, secY + 28,
            tocolor(80, 220, 130, 255), 0.95, "default-bold", "left", "top")

        local fields = {
            { key = "tpX", label = "X:", hint = "e.g. 1481.5" },
            { key = "tpY", label = "Y:", hint = "e.g. -1745.5" },
            { key = "tpZ", label = "Z:", hint = "e.g. 13.5" },
        }
        local fy = secY + 36
        for _, f in ipairs(fields) do
            dxDrawText(f.label, cx, fy, cx + 30, fy + 28,
                tocolor(200, 215, 230, 255), 0.95, "default-bold", "left", "center")
            dxDrawRectangle(cx + 32, fy, 240, 28, tocolor(18, 28, 46, 255), false)
            dxDrawRectangle(cx + 32, fy, 240, 2,
                _focused == f.key and tocolor(80, 220, 130, 255) or tocolor(40, 60, 85, 150), false)
            local val = _focused == f.key and (_fields[f.key] .. "|") or
                        (_fields[f.key] == "" and f.hint or _fields[f.key])
            local col = _fields[f.key] == "" and tocolor(90, 100, 120, 200) or tocolor(255, 255, 255, 255)
            dxDrawText(val, cx + 38, fy, cx + 270, fy + 28,
                col, 0.88, "default", "left", "center")
            fy = fy + 34
        end

        local px2, py2, pz2 = getElementPosition(localPlayer)
        dxDrawText(string.format("Pos: %.1f, %.1f, %.1f", px2, py2, pz2),
            cx, fy + 4, cx + 400, fy + 22, tocolor(130, 145, 165, 200), 0.80, "default", "left", "top")

        local cpHov = mx_in(cx, fy + 26, 180, 28)
        dxDrawRectangle(cx, fy + 26, 180, 28,
            cpHov and tocolor(60, 200, 110, 255) or tocolor(40, 140, 70, 255), false)
        dxDrawText("📋 Copy Position", cx, fy + 26, cx + 180, fy + 54,
            tocolor(255, 255, 255, 255), 0.82, "default-bold", "center", "center")

        local tpHov = mx_in(cx + 190, fy + 26, 160, 28)
        dxDrawRectangle(cx + 190, fy + 26, 160, 28,
            tpHov and tocolor(80, 220, 130, 255) or tocolor(50, 160, 80, 255), false)
        dxDrawText("📍 TELEPORT", cx + 190, fy + 26, cx + 350, fy + 54,
            tocolor(255, 255, 255, 255), 0.88, "default-bold", "center", "center")
    end
end

-- ============================================================
-- MONEY & STATS TAB
-- ============================================================

function FR.renderMoney(cx, cy, cw, ch)
    dxDrawText("Give Yourself Cash", cx, cy + 10, cx + cw, cy + 32,
        tocolor(80, 220, 130, 255), 1.05, "default-bold", "left", "top")

    -- Amount field
    dxDrawText("Amount (R):", cx, cy + 50, cx + 120, cy + 82,
        tocolor(200, 215, 230, 255), 0.95, "default-bold", "left", "center")
    dxDrawRectangle(cx + 130, cy + 50, 240, 32, tocolor(18, 28, 46, 255), false)
    dxDrawRectangle(cx + 130, cy + 50, 240, 2,
        _focused == "moneyAmt" and tocolor(80, 220, 130, 255) or tocolor(40, 60, 85, 150), false)
    local mVal = _focused == "moneyAmt" and (_fields.moneyAmt .. "|") or _fields.moneyAmt
    dxDrawText(mVal, cx + 138, cy + 50, cx + 370, cy + 82,
        tocolor(255, 255, 255, 255), 0.92, "default", "left", "center")

    -- Quick amount buttons
    local quickAmts = { 1000, 10000, 100000, 1000000 }
    local qx = cx
    for _, amt in ipairs(quickAmts) do
        local qHov = mx_in(qx, cy + 92, 100, 28)
        dxDrawRectangle(qx, cy + 92, 100, 28,
            qHov and tocolor(60, 200, 110, 255) or tocolor(35, 130, 60, 255), false)
        local label = amt >= 1000000 and "R" .. (amt / 1000000) .. "M" or
                      amt >= 1000 and "R" .. (amt / 1000) .. "K" or "R" .. amt
        dxDrawText(label, qx, cy + 92, qx + 100, cy + 120,
            tocolor(255, 255, 255, 255), 0.85, "default-bold", "center", "center")
        qx = qx + 108
    end

    -- Give button
    local gHov = mx_in(cx, cy + 130, 200, 36)
    dxDrawRectangle(cx, cy + 130, 200, 36,
        gHov and tocolor(80, 220, 130, 255) or tocolor(50, 160, 80, 255), false)
    dxDrawText("💰 GIVE CASH", cx, cy + 130, cx + 200, cy + 166,
        tocolor(255, 255, 255, 255), 0.95, "default-bold", "center", "center")

    -- Heal self button
    local hHov = mx_in(cx + 210, cy + 130, 160, 36)
    dxDrawRectangle(cx + 210, cy + 130, 160, 36,
        hHov and tocolor(80, 200, 255, 255) or tocolor(40, 130, 200, 255), false)
    dxDrawText("❤ FULL HEAL", cx + 210, cy + 130, cx + 370, cy + 166,
        tocolor(255, 255, 255, 255), 0.95, "default-bold", "center", "center")

    -- Stats display
    local cash = getElementData(localPlayer, "mzansi:cash") or 0
    local bank = getElementData(localPlayer, "mzansi:bank") or 0
    local hp   = math.floor(getElementHealth(localPlayer))
    local arm  = math.floor(getPedArmor(localPlayer))

    dxDrawText("Your Wallet: R" .. cash, cx, cy + 185, cx + 300, cy + 205,
        tocolor(60, 220, 100, 255), 0.9, "default-bold", "left", "top")
    dxDrawText("Bank: R" .. bank, cx, cy + 207, cx + 300, cy + 227,
        tocolor(100, 180, 255, 255), 0.9, "default-bold", "left", "top")
    dxDrawText("Health: " .. hp .. " / 100", cx, cy + 229, cx + 300, cy + 249,
        tocolor(255, 100, 100, 255), 0.9, "default-bold", "left", "top")
    dxDrawText("Armor: " .. arm .. " / 100", cx, cy + 251, cx + 300, cy + 271,
        tocolor(200, 200, 80, 255), 0.9, "default-bold", "left", "top")
end

-- ============================================================
-- WORLD TAB (Time & Weather)
-- ============================================================

function FR.renderWorld(cx, cy, cw, ch)
    dxDrawText("Server Time & Weather Control", cx, cy + 10, cx + cw, cy + 32,
        tocolor(80, 220, 130, 255), 1.05, "default-bold", "left", "top")

    -- Time
    dxDrawText("Hour: " .. _timeHour .. ":00", cx, cy + 52, cx + 200, cy + 74,
        tocolor(200, 215, 230, 255), 0.95, "default-bold", "left", "top")

    local slotW = (cw - 10) / 24
    for h = 0, 23 do
        local hx = cx + h * slotW
        local isSelected = (h == _timeHour)
        local isHov      = mx_in(hx, cy + 76, slotW - 2, 32)
        local bg = isSelected and tocolor(80, 220, 130, 255) or
                   (isHov and tocolor(40, 90, 60, 255) or tocolor(20, 34, 52, 240))
        dxDrawRectangle(hx, cy + 76, slotW - 2, 32, bg, false)
        dxDrawText(tostring(h), hx, cy + 76, hx + slotW - 2, cy + 108,
            isSelected and tocolor(10, 20, 14, 255) or tocolor(190, 200, 220, 255),
            0.72, "default-bold", "center", "center")
    end

    -- Set time button
    local stHov = mx_in(cx, cy + 116, 160, 30)
    dxDrawRectangle(cx, cy + 116, 160, 30,
        stHov and tocolor(80, 220, 130, 255) or tocolor(50, 150, 80, 255), false)
    dxDrawText("🕐 SET TIME", cx, cy + 116, cx + 160, cy + 146,
        tocolor(255, 255, 255, 255), 0.88, "default-bold", "center", "center")

    -- Weather
    dxDrawText("Weather Preset:", cx, cy + 160, cx + 200, cy + 182,
        tocolor(200, 215, 230, 255), 0.95, "default-bold", "left", "top")

    local wColW = (cw - 8) / 3
    local wy    = cy + 186
    local wi    = 0
    for _, preset in ipairs(WEATHER_PRESETS) do
        local col = wi % 3
        local row = math.floor(wi / 3)
        local wx  = cx + col * wColW
        local wby = wy + row * 30

        local isSel = (_weatherId == preset.id)
        local isHov = mx_in(wx, wby, wColW - 4, 28)
        local bg = isSel and tocolor(80, 220, 130, 255) or
                   (isHov and tocolor(40, 90, 60, 255) or tocolor(18, 28, 46, 230))
        dxDrawRectangle(wx, wby, wColW - 4, 28, bg, false)
        dxDrawText(preset.id .. ". " .. preset.name, wx + 6, wby, wx + wColW - 4, wby + 28,
            isSel and tocolor(10, 20, 14, 255) or tocolor(210, 220, 235, 255),
            0.78, "default", "left", "center")
        wi = wi + 1
    end

    local setWHov = mx_in(cx, wy + 7 * 30 + 4, 180, 30)
    dxDrawRectangle(cx, wy + 7 * 30 + 4, 180, 30,
        setWHov and tocolor(80, 220, 130, 255) or tocolor(50, 150, 80, 255), false)
    dxDrawText("🌤 SET WEATHER", cx, wy + 7 * 30 + 4, cx + 180, wy + 7 * 30 + 34,
        tocolor(255, 255, 255, 255), 0.88, "default-bold", "center", "center")
end

-- ============================================================
-- OBJECTS TAB
-- ============================================================

function FR.renderObjects(cx, cy, cw, ch)
    dxDrawText("Spawn World Objects by Model ID", cx, cy + 10, cx + cw, cy + 32,
        tocolor(80, 220, 130, 255), 1.05, "default-bold", "left", "top")

    dxDrawText("Model ID (321–19999):", cx, cy + 50, cx + 220, cy + 78,
        tocolor(200, 215, 230, 255), 0.92, "default-bold", "left", "center")
    dxDrawRectangle(cx + 228, cy + 50, 200, 30, tocolor(18, 28, 46, 255), false)
    dxDrawRectangle(cx + 228, cy + 50, 200, 2,
        _focused == "objModel" and tocolor(80, 220, 130, 255) or tocolor(40, 60, 85, 150), false)
    local omVal = _focused == "objModel" and (_fields.objModel .. "|") or
                  (_fields.objModel == "" and "e.g. 1337" or _fields.objModel)
    local omCol = _fields.objModel == "" and tocolor(90, 100, 120, 200) or tocolor(255, 255, 255, 255)
    dxDrawText(omVal, cx + 236, cy + 50, cx + 428, cy + 80, omCol, 0.9, "default", "left", "center")

    local spHov = mx_in(cx + 436, cy + 50, 160, 30)
    dxDrawRectangle(cx + 436, cy + 50, 160, 30,
        spHov and tocolor(80, 220, 130, 255) or tocolor(50, 150, 80, 255), false)
    dxDrawText("📦 SPAWN OBJECT", cx + 436, cy + 50, cx + 596, cy + 80,
        tocolor(255, 255, 255, 255), 0.85, "default-bold", "center", "center")

    -- Common object quick-spawn
    dxDrawText("Quick Spawn:", cx, cy + 100, cx + 160, cy + 122,
        tocolor(200, 215, 230, 255), 0.88, "default-bold", "left", "top")

    local quickObjects = {
        { id = 1337, name = "Box Crate" },     { id = 2060, name = "Barrel" },
        { id = 3279, name = "Bench" },          { id = 2082, name = "Cone" },
        { id = 955,  name = "Dumpster" },       { id = 980,  name = "Trash Can" },
        { id = 1655, name = "Light Pole" },     { id = 2830, name = "Vending Machine" },
    }

    local qx = cx
    local qy = cy + 126
    for i, obj in ipairs(quickObjects) do
        if i % 4 == 1 and i > 1 then
            qx = cx
            qy = qy + 36
        end
        local qHov = mx_in(qx, qy, 195, 30)
        dxDrawRectangle(qx, qy, 195, 30,
            qHov and tocolor(60, 200, 110, 255) or tocolor(18, 30, 48, 240), false)
        dxDrawText(obj.name .. " [" .. obj.id .. "]", qx + 6, qy, qx + 195, qy + 30,
            qHov and tocolor(10, 20, 14, 255) or tocolor(210, 220, 235, 255),
            0.78, "default", "left", "center")
        qx = qx + 200
    end
end

-- ============================================================
-- CLICK HANDLER
-- ============================================================

addEventHandler("onClientClick", root, function(button, state)
    if button ~= "left" or state ~= "down" then return end
    if not FR._visible then return end

    local sw, sh = guiGetScreenSize()
    local px = (sw - W) / 2
    local py = (sh - H) / 2

    -- Tabs
    local tabX = px + 6
    local tabY  = py + HEADER_H + 4
    local tabW  = (W - 12) / #TABS
    for _, tab in ipairs(TABS) do
        local isLocked = (FR._adminLevel < 1) and (tab.id ~= "teleport")
        if (not isLocked) and mx_in(tabX, tabY, tabW - 4, TAB_H - 4) then
            FR._currentTab = tab.id
            _focused       = nil
            playSoundFrontEnd(40)
            return
        end
        tabX = tabX + tabW
    end

    local cx = px + 12
    local cy = py + CONTENT_OFF

    -- ---- VEHICLES ----
    if FR._currentTab == "vehicles" then
        -- Search field focus
        if mx_in(cx, cy, (W - 24) - 120, 30) then
            _focused = "veSearch"
            return
        end
        -- Repair button
        if mx_in(cx + (W - 24) - 115, cy, 110, 30) then
            triggerServerEvent("mzansi:freeroam:repairVehicle", localPlayer)
            return
        end

        local search = _fields.veSearch:lower()
        local filtered = {}
        for _, v in ipairs(GTA_VEHICLES) do
            if search == "" or v.name:lower():find(search, 1, true) or tostring(v.id):find(search, 1, true) then
                filtered[#filtered + 1] = v
            end
        end

        local cw = W - 24
        local colW = cw / VE_COLS
        local ry = cy + 38
        for row = 1, VE_VISIBLE do
            local actualRow = row + _veScroll
            for col = 1, VE_COLS do
                local idx = (actualRow - 1) * VE_COLS + col
                if idx > #filtered then break end
                local v  = filtered[idx]
                local vx = cx + (col - 1) * colW
                if mx_in(vx, ry, colW - 4, VE_ROW_H) then
                    local vid, vname = v.id, v.name
                    FR.close()
                    if Mzansi.Modal and Mzansi.Modal.confirmSpawn then
                        Mzansi.Modal.confirmSpawn(vid, vname, function()
                            triggerServerEvent("mzansi:freeroam:spawnVehicle", localPlayer, vid)
                        end)
                    else
                        triggerServerEvent("mzansi:freeroam:spawnVehicle", localPlayer, vid)
                    end
                    return
                end
            end
            ry = ry + VE_ROW_H
        end

    -- ---- WEAPONS ----
    elseif FR._currentTab == "weapons" then
        -- Ammo field focus
        if mx_in(cx + 65, cy + 26, 120, 26) then
            _focused = "ammo"
            return
        end

        local wy = cy + 60
        for i = 1, math.min(WE_VIS, #GTA_WEAPONS - _weScroll) do
            local idx = i + _weScroll
            local w   = GTA_WEAPONS[idx]
            if not w then break end

            if mx_in(cx, wy, W - 24, WE_ROW_H) then
                local ammo = tonumber(_fields.ammo) or 500
                triggerServerEvent("mzansi:freeroam:giveWeapon", localPlayer, w.id, ammo)
                return
            end
            wy = wy + WE_ROW_H
        end

    -- ---- TELEPORT ----
    elseif FR._currentTab == "teleport" then
        local cw = W - 24

        -- Province teleport buttons (all logged-in players)
        local pbY = cy + 54
        local pbH = 44
        for _, prov in ipairs(PROVINCE_BUTTONS) do
            if mx_in(cx, pbY, cw, pbH) then
                triggerServerEvent("mzansi:freeroam:teleportProvince", localPlayer, prov.id)
                FR.close()
                return
            end
            pbY = pbY + pbH + 6
        end

        -- Admin-only: coordinate teleport
        if FR._adminLevel >= 1 then
            local secY = pbY + 12
            local fy   = secY + 36
            for _, fk in ipairs({ "tpX", "tpY", "tpZ" }) do
                if mx_in(cx + 32, fy, 240, 28) then
                    _focused = fk
                    return
                end
                fy = fy + 34
            end

            -- Copy position
            if mx_in(cx, fy + 26, 180, 28) then
                local ex, ey, ez = getElementPosition(localPlayer)
                _fields.tpX = string.format("%.2f", ex)
                _fields.tpY = string.format("%.2f", ey)
                _fields.tpZ = string.format("%.2f", ez)
                _focused = nil
                return
            end

            -- Teleport
            if mx_in(cx + 190, fy + 26, 160, 28) then
                local tx = tonumber(_fields.tpX)
                local ty = tonumber(_fields.tpY)
                local tz = tonumber(_fields.tpZ)
                if tx and ty and tz then
                    triggerServerEvent("mzansi:freeroam:teleport", localPlayer, tx, ty, tz)
                    FR.close()
                else
                    notify("Enter valid X, Y, Z coordinates.", true)
                end
                return
            end
        end

    -- ---- MONEY ----
    elseif FR._currentTab == "money" then
        local cw = W - 24

        -- Money field focus
        if mx_in(cx + 130, cy + 50, 240, 32) then
            _focused = "moneyAmt"
            return
        end

        -- Quick amounts
        local qx = cx
        for _, amt in ipairs({ 1000, 10000, 100000, 1000000 }) do
            if mx_in(qx, cy + 92, 100, 28) then
                _fields.moneyAmt = tostring(amt)
                return
            end
            qx = qx + 108
        end

        -- Give cash
        if mx_in(cx, cy + 130, 200, 36) then
            local amt = tonumber(_fields.moneyAmt)
            if amt then
                triggerServerEvent("mzansi:freeroam:giveMoney", localPlayer, amt)
            else
                notify("Enter a valid amount.", true)
            end
            return
        end

        -- Heal self (server-authoritative)
        if mx_in(cx + 210, cy + 130, 160, 36) then
            triggerServerEvent("mzansi:freeroam:heal", localPlayer)
            return
        end

    -- ---- WORLD ----
    elseif FR._currentTab == "world" then
        local cw = W - 24

        -- Hour slots
        local slotW = (cw - 10) / 24
        for h = 0, 23 do
            local hx = cx + h * slotW
            if mx_in(hx, cy + 76, slotW - 2, 32) then
                _timeHour = h
                return
            end
        end

        -- Set time button
        if mx_in(cx, cy + 116, 160, 30) then
            triggerServerEvent("mzansi:freeroam:setTime", localPlayer, _timeHour, 0)
            return
        end

        -- Weather presets
        local wColW = (cw - 8) / 3
        local wy    = cy + 186
        for wi, preset in ipairs(WEATHER_PRESETS) do
            local col = (wi - 1) % 3
            local row = math.floor((wi - 1) / 3)
            local wx  = cx + col * wColW
            local wby = wy + row * 30
            if mx_in(wx, wby, wColW - 4, 28) then
                _weatherId = preset.id
                return
            end
        end

        -- Set weather button
        if mx_in(cx, wy + 7 * 30 + 4, 180, 30) then
            triggerServerEvent("mzansi:freeroam:setWeather", localPlayer, _weatherId)
            return
        end

    -- ---- OBJECTS ----
    elseif FR._currentTab == "objects" then
        local cw = W - 24

        -- Model field focus
        if mx_in(cx + 228, cy + 50, 200, 30) then
            _focused = "objModel"
            return
        end

        -- Spawn button
        if mx_in(cx + 436, cy + 50, 160, 30) then
            local modelId = tonumber(_fields.objModel)
            if modelId then
                triggerServerEvent("mzansi:freeroam:spawnObject", localPlayer, modelId)
            else
                notify("Enter a valid model ID.", true)
            end
            return
        end

        -- Quick objects
        local quickObjects = {
            { id = 1337 }, { id = 2060 }, { id = 3279 }, { id = 2082 },
            { id = 955  }, { id = 980  }, { id = 1655 }, { id = 2830 },
        }
        local qx = cx
        local qy = cy + 126
        for i, obj in ipairs(quickObjects) do
            if i % 4 == 1 and i > 1 then qx = cx; qy = qy + 36 end
            if mx_in(qx, qy, 195, 30) then
                triggerServerEvent("mzansi:freeroam:spawnObject", localPlayer, obj.id)
                return
            end
            qx = qx + 200
        end
    end

    -- Click outside panel = close (not on any interactive element)
    if not mx_in(px, py, W, H) then
        FR.close()
    end
end)

-- ============================================================
-- KEYBOARD — text input
-- ============================================================

addEventHandler("onClientKey", root, function(key, pressed)
    if not pressed then return end
    if not FR._visible then return end
    if not _focused then return end

    if key == "backspace" then
        if #_fields[_focused] > 0 then
            _fields[_focused] = _fields[_focused]:sub(1, -2)
        end
        cancelEvent()
    elseif key == "escape" then
        _focused = nil
        cancelEvent()
    elseif key == "return" or key == "enter" then
        _focused = nil
        cancelEvent()
    end
end)

addEventHandler("onClientCharacter", root, function(char)
    if not FR._visible then return end
    if not _focused then return end
    if #_fields[_focused] < 128 then
        _fields[_focused] = _fields[_focused] .. char
    end
    cancelEvent()
end)

-- Scroll wheel
addEventHandler("onClientKey", root, function(key, pressed)
    if not pressed or not FR._visible then return end

    if FR._currentTab == "vehicles" then
        local search   = _fields.veSearch:lower()
        local count    = 0
        for _, v in ipairs(GTA_VEHICLES) do
            if search == "" or v.name:lower():find(search, 1, true) or tostring(v.id):find(search, 1, true) then
                count = count + 1
            end
        end
        local maxScroll = math.max(0, math.ceil(count / VE_COLS) - VE_VISIBLE)
        if key == "mouse_wheel_up" and _veScroll > 0 then
            _veScroll = _veScroll - 1
        elseif key == "mouse_wheel_down" and _veScroll < maxScroll then
            _veScroll = _veScroll + 1
        end
    elseif FR._currentTab == "weapons" then
        if key == "mouse_wheel_up" and _weScroll > 0 then
            _weScroll = _weScroll - 1
        elseif key == "mouse_wheel_down" and _weScroll + WE_VIS < #GTA_WEAPONS then
            _weScroll = _weScroll + 1
        end
    end
end)

-- ============================================================
-- KEYBINDS
-- ============================================================

bindKey("f8", "down", function()
    if Mzansi.Util and Mzansi.Util.bindBlocked and Mzansi.Util.bindBlocked() then return end
    FR.toggle()
end)

addCommandHandler("ngamla", function()
    FR.toggle()
end)

addCommandHandler("freeroam", function()
    FR.toggle()
end)

addCommandHandler("creator", function()
    FR.toggle()
end)
