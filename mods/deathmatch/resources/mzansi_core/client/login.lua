Mzansi = Mzansi or {}
Mzansi.Login = {}
Mzansi.Login._active = false
Mzansi.Login._screen = "login" -- "login", "register", "charcreate", "recovery"
Mzansi.Login._error = ""
Mzansi.Login._errorTime = 0
Mzansi.Login._charGender = 0

Mzansi.Login._fields = {
    username = "",
    password = "",
    regUsername = "",
    regEmail = "",
    regPassword = "",
    regConfirm = "",
    recUsername = "",
    recEmail = "",
    recPassword = "",
    recConfirm = "",
    charFirst = "",
    charLast = "",
    charAge = "25",
}
Mzansi.Login._focused = nil
Mzansi.Login._masked = {
    password = true,
    regPassword = true,
    regConfirm = true,
    recPassword = true,
    recConfirm = true,
}

addEvent("mzansi:accounts:showLogin", true)
addEvent("mzansi:accounts:showRegistration", true)
addEvent("mzansi:accounts:showCharCreate", true)
addEvent("mzansi:accounts:showRecovery", true)
addEvent("mzansi:accounts:loginResult", true)
addEvent("mzansi:accounts:registerResult", true)
addEvent("mzansi:accounts:recoveryResult", true)
addEvent("mzansi:characters:createResult", true)
addEvent("mzansi:characters:loaded", true)
addEvent("mzansi:characters:spawnComplete", true)

Mzansi.Login._cinematicActive = false

function Mzansi.Login.showLoginUI()
    Mzansi.Login._active = true
    Mzansi.Login._cinematicActive = true
    Mzansi.Login._screen = "login"
    Mzansi.Login._error = ""
    Mzansi.Login._focused = nil
    Mzansi.Login._fields.username = ""
    Mzansi.Login._fields.password = ""

    showCursor(true)
    showChat(false)
    setElementFrozen(localPlayer, true)
    fadeCamera(true, 1.5)
    setCameraInterior(0)
end

function Mzansi.Login.showRegisterUI()
    Mzansi.Login._screen = "register"
    Mzansi.Login._error = ""
    Mzansi.Login._focused = nil
    Mzansi.Login._fields.regUsername = ""
    Mzansi.Login._fields.regEmail = ""
    Mzansi.Login._fields.regPassword = ""
    Mzansi.Login._fields.regConfirm = ""
end

function Mzansi.Login.showRecoveryUI()
    Mzansi.Login._screen = "recovery"
    Mzansi.Login._error = ""
    Mzansi.Login._focused = nil
    Mzansi.Login._fields.recUsername = ""
    Mzansi.Login._fields.recEmail = ""
    Mzansi.Login._fields.recPassword = ""
    Mzansi.Login._fields.recConfirm = ""
end

function Mzansi.Login.showCharCreateUI()
    Mzansi.Login._screen = "charcreate"
    Mzansi.Login._error = ""
    Mzansi.Login._focused = nil
    Mzansi.Login._charGender = 0
    Mzansi.Login._fields.charFirst = ""
    Mzansi.Login._fields.charLast = ""
    Mzansi.Login._fields.charAge = "25"
end

function Mzansi.Login.hideLoginUI()
    Mzansi.Login._cinematicActive = false
    Mzansi.Login._active = false
    Mzansi.Login._screen = "login"
    Mzansi.Login._focused = nil
    showCursor(false)
    showChat(true)
    setElementFrozen(localPlayer, false)
    setCameraTarget(localPlayer)
    fadeCamera(true, 1.0)
end

function Mzansi.Login.handleClick(x, y, w, h)
    local mx, my = getCursorPosition()
    if not mx or not my then return false end
    local sx, sy = guiGetScreenSize()
    mx, my = mx * sx, my * sy
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

-- Cinematic camera flight over Cape Town during login
addEventHandler("onClientPreRender", root, function()
    if not Mzansi.Login._cinematicActive then return end

    local tick = getTickCount()
    local angle = (tick * 0.005) % 360
    local rad = math.rad(angle)
    local radius = 350

    local cx = 1481.5 + math.cos(rad) * radius
    local cy = -1745.5 + math.sin(rad) * radius
    local cz = 180 + math.sin(math.rad(tick * 0.01)) * 25

    setCameraMatrix(cx, cy, cz, 1481.5, -1745.5, 45)
end)

-- Main Login Renderer
addEventHandler("onClientRender", root, function()
    if not Mzansi.Login._active then return end

    local sx, sy = guiGetScreenSize()

    -- Subtle Background Overlay
    dxDrawRectangle(0, 0, sx, sy, tocolor(5, 10, 20, 160), false)

    if Mzansi.Login._screen == "login" then
        Mzansi.Login.renderLogin(sx, sy)
    elseif Mzansi.Login._screen == "register" then
        Mzansi.Login.renderRegister(sx, sy)
    elseif Mzansi.Login._screen == "recovery" then
        Mzansi.Login.renderRecovery(sx, sy)
    elseif Mzansi.Login._screen == "charcreate" then
        Mzansi.Login.renderCharCreate(sx, sy)
    end
end)

function Mzansi.Login.renderLogin(sx, sy)
    local bw, bh = 400, 380
    local bx = (sx - bw) / 2
    local by = (sy - bh) / 2

    dxDrawRectangle(bx, by, bw, bh, tocolor(10, 22, 40, 245), false)
    dxDrawRectangle(bx, by, bw, 2, tocolor(200, 170, 50, 255), false)

    dxDrawText("MZANSI", bx, by + 18, bx + bw, by + 48, tocolor(200, 170, 50, 255), 1.5, "bankgothic", "center", "top")
    dxDrawText("South African Roleplay", bx, by + 48, bx + bw, by + 63, tocolor(136, 153, 170, 255), 0.7, "default", "center", "top")

    -- USERNAME
    dxDrawText("USERNAME", bx + 30, by + 85, bx + bw - 30, by + 100, tocolor(136, 153, 170, 255), 0.8, "default-bold", "left", "top")
    local userFocused = Mzansi.Login._focused == "username"
    local userBorder = userFocused and tocolor(200, 170, 50, 255) or tocolor(60, 80, 100, 100)
    dxDrawRectangle(bx + 30, by + 105, bw - 60, 35, tocolor(20, 35, 55, 255), false)
    dxDrawRectangle(bx + 30, by + 105, bw - 60, 1, userBorder, false)
    dxDrawRectangle(bx + 30, by + 139, bw - 60, 1, userBorder, false)
    dxDrawRectangle(bx + 30, by + 105, 1, 35, userBorder, false)
    dxDrawRectangle(bx + bw - 31, by + 105, 1, 35, userBorder, false)

    -- PASSWORD
    dxDrawText("PASSWORD", bx + 30, by + 155, bx + bw - 30, by + 170, tocolor(136, 153, 170, 255), 0.8, "default-bold", "left", "top")
    local passFocused = Mzansi.Login._focused == "password"
    local passBorder = passFocused and tocolor(200, 170, 50, 255) or tocolor(60, 80, 100, 100)
    dxDrawRectangle(bx + 30, by + 175, bw - 60, 35, tocolor(20, 35, 55, 255), false)
    dxDrawRectangle(bx + 30, by + 175, bw - 60, 1, passBorder, false)
    dxDrawRectangle(bx + 30, by + 209, bw - 60, 1, passBorder, false)
    dxDrawRectangle(bx + 30, by + 175, 1, 35, passBorder, false)
    dxDrawRectangle(bx + bw - 31, by + 175, 1, 35, passBorder, false)

    local userText = Mzansi.Login._fields.username
    local passText = Mzansi.Login._fields.password
    local passDisplay = string.rep("*", #passText)

    if userText == "" and not userFocused then
        dxDrawText("Enter username", bx + 40, by + 110, bx + bw - 40, by + 135, tocolor(85, 102, 119, 255), 0.9, "default", "left", "center")
    else
        local display = userText
        if userFocused and (getTickCount() % 1000 < 500) then display = display .. "|" end
        dxDrawText(display, bx + 40, by + 110, bx + bw - 40, by + 135, tocolor(255, 255, 255, 255), 0.9, "default", "left", "center")
    end

    if passDisplay == "" and not passFocused then
        dxDrawText("Enter password", bx + 40, by + 180, bx + bw - 40, by + 205, tocolor(85, 102, 119, 255), 0.9, "default", "left", "center")
    else
        local display = passDisplay
        if passFocused and (getTickCount() % 1000 < 500) then display = display .. "|" end
        dxDrawText(display, bx + 40, by + 180, bx + bw - 40, by + 205, tocolor(255, 255, 255, 255), 0.9, "default", "left", "center")
    end

    -- SIGN IN BUTTON
    local loginHover = Mzansi.Login.handleClick(bx + 30, by + 225, bw - 60, 38)
    local loginColor = loginHover and tocolor(218, 184, 64, 255) or tocolor(200, 170, 50, 255)
    dxDrawRectangle(bx + 30, by + 225, bw - 60, 38, loginColor, false)
    dxDrawText("SIGN IN", bx + 30, by + 225, bx + bw - 30, by + 263, tocolor(10, 22, 40, 255), 1.0, "default-bold", "center", "center")

    -- CREATE ACCOUNT BUTTON
    local regHover = Mzansi.Login.handleClick(bx + 30, by + 273, bw - 60, 32)
    dxDrawRectangle(bx + 30, by + 273, bw - 60, 32, tocolor(30, 45, 65, 255), false)
    if regHover then dxDrawRectangle(bx + 30, by + 273, bw - 60, 1, tocolor(200, 170, 50, 255), false) end
    dxDrawText("CREATE ACCOUNT", bx + 30, by + 273, bx + bw - 30, by + 305, tocolor(136, 153, 170, 255), 0.9, "default-bold", "center", "center")

    -- FORGOT PASSWORD LINK
    local recHover = Mzansi.Login.handleClick(bx + 30, by + 315, bw - 60, 25)
    dxDrawText("Forgot Password? Recover Account", bx + 30, by + 315, bx + bw - 30, by + 340, recHover and tocolor(200, 170, 50, 255) or tocolor(120, 160, 210, 220), 0.85, "default-bold", "center", "center")

    if Mzansi.Login._error ~= "" and getTickCount() - Mzansi.Login._errorTime < 6000 then
        dxDrawText(Mzansi.Login._error, bx + 30, by + bh - 24, bx + bw - 30, by + bh - 4, tocolor(255, 68, 68, 255), 0.8, "default", "center", "top")
    end
end

function Mzansi.Login.renderRegister(sx, sy)
    local bw, bh = 420, 430
    local bx = (sx - bw) / 2
    local by = (sy - bh) / 2

    dxDrawRectangle(bx, by, bw, bh, tocolor(10, 22, 40, 245), false)
    dxDrawRectangle(bx, by, bw, 2, tocolor(200, 170, 50, 255), false)

    dxDrawText("CREATE ACCOUNT", bx, by + 18, bx + bw, by + 48, tocolor(200, 170, 50, 255), 1.2, "bankgothic", "center", "top")
    dxDrawText("Join Mzansi RP • South Africa", bx, by + 48, bx + bw, by + 63, tocolor(136, 153, 170, 255), 0.7, "default", "center", "top")

    local fields = {
        { key = "regUsername", label = "USERNAME", y = 80, masked = false },
        { key = "regEmail", label = "EMAIL (e.g. name@domain.com)", y = 130, masked = false },
        { key = "regPassword", label = "PASSWORD", y = 180, masked = true },
        { key = "regConfirm", label = "CONFIRM PASSWORD", y = 230, masked = true },
    }

    for _, field in ipairs(fields) do
        dxDrawText(field.label, bx + 30, by + field.y, bx + bw - 30, by + field.y + 15, tocolor(136, 153, 170, 255), 0.8, "default-bold", "left", "top")
        local focused = Mzansi.Login._focused == field.key
        local border = focused and tocolor(200, 170, 50, 255) or tocolor(60, 80, 100, 100)
        dxDrawRectangle(bx + 30, by + field.y + 18, bw - 60, 32, tocolor(20, 35, 55, 255), false)
        dxDrawRectangle(bx + 30, by + field.y + 18, bw - 60, 1, border, false)
        dxDrawRectangle(bx + 30, by + field.y + 49, bw - 60, 1, border, false)
        dxDrawRectangle(bx + 30, by + field.y + 18, 1, 32, border, false)
        dxDrawRectangle(bx + bw - 31, by + field.y + 18, 1, 32, border, false)

        local text = Mzansi.Login._fields[field.key]
        local display = field.masked and string.rep("*", #text) or text
        if display == "" and not focused then
            dxDrawText("Enter " .. string.lower(field.label), bx + 40, by + field.y + 20, bx + bw - 40, by + field.y + 48, tocolor(85, 102, 119, 255), 0.88, "default", "left", "center")
        else
            local d = display
            if focused and (getTickCount() % 1000 < 500) then d = d .. "|" end
            dxDrawText(d, bx + 40, by + field.y + 20, bx + bw - 40, by + field.y + 48, tocolor(255, 255, 255, 255), 0.88, "default", "left", "center")
        end
    end

    local createHover = Mzansi.Login.handleClick(bx + 30, by + 290, bw - 60, 38)
    local createColor = createHover and tocolor(218, 184, 64, 255) or tocolor(200, 170, 50, 255)
    dxDrawRectangle(bx + 30, by + 290, bw - 60, 38, createColor, false)
    dxDrawText("CREATE ACCOUNT", bx + 30, by + 290, bx + bw - 30, by + 328, tocolor(10, 22, 40, 255), 1.0, "default-bold", "center", "center")

    local backHover = Mzansi.Login.handleClick(bx + 30, by + 338, bw - 60, 32)
    dxDrawRectangle(bx + 30, by + 338, bw - 60, 32, tocolor(30, 45, 65, 255), false)
    if backHover then dxDrawRectangle(bx + 30, by + 338, bw - 60, 1, tocolor(200, 170, 50, 255), false) end
    dxDrawText("BACK TO LOGIN", bx + 30, by + 338, bx + bw - 30, by + 370, tocolor(136, 153, 170, 255), 0.9, "default-bold", "center", "center")

    if Mzansi.Login._error ~= "" and getTickCount() - Mzansi.Login._errorTime < 6000 then
        dxDrawText(Mzansi.Login._error, bx + 30, by + bh - 24, bx + bw - 30, by + bh - 4, tocolor(255, 68, 68, 255), 0.8, "default", "center", "top")
    end
end

-- ACCOUNT RECOVERY / FORGOT PASSWORD SCREEN
function Mzansi.Login.renderRecovery(sx, sy)
    local bw, bh = 420, 430
    local bx = (sx - bw) / 2
    local by = (sy - bh) / 2

    dxDrawRectangle(bx, by, bw, bh, tocolor(10, 22, 40, 245), false)
    dxDrawRectangle(bx, by, bw, 2, tocolor(200, 170, 50, 255), false)

    dxDrawText("ACCOUNT RECOVERY", bx, by + 18, bx + bw, by + 48, tocolor(200, 170, 50, 255), 1.2, "bankgothic", "center", "top")
    dxDrawText("Reset password using your registered email", bx, by + 48, bx + bw, by + 63, tocolor(136, 153, 170, 255), 0.7, "default", "center", "top")

    local fields = {
        { key = "recUsername", label = "USERNAME", y = 80, masked = false },
        { key = "recEmail", label = "REGISTERED EMAIL ADDRESS", y = 130, masked = false },
        { key = "recPassword", label = "NEW PASSWORD", y = 180, masked = true },
        { key = "recConfirm", label = "CONFIRM NEW PASSWORD", y = 230, masked = true },
    }

    for _, field in ipairs(fields) do
        dxDrawText(field.label, bx + 30, by + field.y, bx + bw - 30, by + field.y + 15, tocolor(136, 153, 170, 255), 0.8, "default-bold", "left", "top")
        local focused = Mzansi.Login._focused == field.key
        local border = focused and tocolor(200, 170, 50, 255) or tocolor(60, 80, 100, 100)
        dxDrawRectangle(bx + 30, by + field.y + 18, bw - 60, 32, tocolor(20, 35, 55, 255), false)
        dxDrawRectangle(bx + 30, by + field.y + 18, bw - 60, 1, border, false)
        dxDrawRectangle(bx + 30, by + field.y + 49, bw - 60, 1, border, false)
        dxDrawRectangle(bx + 30, by + field.y + 18, 1, 32, border, false)
        dxDrawRectangle(bx + bw - 31, by + field.y + 18, 1, 32, border, false)

        local text = Mzansi.Login._fields[field.key]
        local display = field.masked and string.rep("*", #text) or text
        if display == "" and not focused then
            dxDrawText("Enter " .. string.lower(field.label), bx + 40, by + field.y + 20, bx + bw - 40, by + field.y + 48, tocolor(85, 102, 119, 255), 0.88, "default", "left", "center")
        else
            local d = display
            if focused and (getTickCount() % 1000 < 500) then d = d .. "|" end
            dxDrawText(d, bx + 40, by + field.y + 20, bx + bw - 40, by + field.y + 48, tocolor(255, 255, 255, 255), 0.88, "default", "left", "center")
        end
    end

    -- RESET BUTTON
    local resetHover = Mzansi.Login.handleClick(bx + 30, by + 290, bw - 60, 38)
    local resetColor = resetHover and tocolor(218, 184, 64, 255) or tocolor(200, 170, 50, 255)
    dxDrawRectangle(bx + 30, by + 290, bw - 60, 38, resetColor, false)
    dxDrawText("RESET PASSWORD", bx + 30, by + 290, bx + bw - 30, by + 328, tocolor(10, 22, 40, 255), 1.0, "default-bold", "center", "center")

    -- BACK BUTTON
    local backHover = Mzansi.Login.handleClick(bx + 30, by + 338, bw - 60, 32)
    dxDrawRectangle(bx + 30, by + 338, bw - 60, 32, tocolor(30, 45, 65, 255), false)
    if backHover then dxDrawRectangle(bx + 30, by + 338, bw - 60, 1, tocolor(200, 170, 50, 255), false) end
    dxDrawText("BACK TO LOGIN", bx + 30, by + 338, bx + bw - 30, by + 370, tocolor(136, 153, 170, 255), 0.9, "default-bold", "center", "center")

    if Mzansi.Login._error ~= "" and getTickCount() - Mzansi.Login._errorTime < 6000 then
        dxDrawText(Mzansi.Login._error, bx + 30, by + bh - 24, bx + bw - 30, by + bh - 4, tocolor(255, 68, 68, 255), 0.8, "default", "center", "top")
    end
end

function Mzansi.Login.renderCharCreate(sx, sy)
    local bw, bh = 420, 420
    local bx = (sx - bw) / 2
    local by = (sy - bh) / 2

    dxDrawRectangle(bx, by, bw, bh, tocolor(10, 22, 40, 245), false)
    dxDrawRectangle(bx, by, bw, 2, tocolor(200, 170, 50, 255), false)

    dxDrawText("CREATE CHARACTER", bx, by + 20, bx + bw, by + 50, tocolor(200, 170, 50, 255), 1.2, "bankgothic", "center", "top")
    dxDrawText("Begin your life in South Africa", bx, by + 50, bx + bw, by + 65, tocolor(136, 153, 170, 255), 0.7, "default", "center", "top")

    local fields = {
        { key = "charFirst", label = "FIRST NAME", y = 85 },
        { key = "charLast", label = "LAST NAME", y = 145 },
        { key = "charAge", label = "AGE (16-80)", y = 205 },
    }

    for _, field in ipairs(fields) do
        dxDrawText(field.label, bx + 30, by + field.y, bx + bw - 30, by + field.y + 15, tocolor(136, 153, 170, 255), 0.8, "default-bold", "left", "top")
        local focused = Mzansi.Login._focused == field.key
        local border = focused and tocolor(200, 170, 50, 255) or tocolor(60, 80, 100, 100)
        dxDrawRectangle(bx + 30, by + field.y + 20, bw - 60, 35, tocolor(20, 35, 55, 255), false)
        dxDrawRectangle(bx + 30, by + field.y + 20, bw - 60, 1, border, false)
        dxDrawRectangle(bx + 30, by + field.y + 54, bw - 60, 1, border, false)
        dxDrawRectangle(bx + 30, by + field.y + 20, 1, 35, border, false)
        dxDrawRectangle(bx + bw - 31, by + field.y + 20, 1, 35, border, false)

        local text = Mzansi.Login._fields[field.key]
        if text == "" and not focused then
            dxDrawText("Enter " .. string.lower(field.label), bx + 40, by + field.y + 25, bx + bw - 40, by + field.y + 50, tocolor(85, 102, 119, 255), 0.9, "default", "left", "center")
        else
            local display = text
            if focused and (getTickCount() % 1000 < 500) then display = display .. "|" end
            dxDrawText(display, bx + 40, by + field.y + 25, bx + bw - 40, by + field.y + 50, tocolor(255, 255, 255, 255), 0.9, "default", "left", "center")
        end
    end

    -- Gender Selector
    dxDrawText("GENDER", bx + 30, by + 265, bx + bw - 30, by + 280, tocolor(136, 153, 170, 255), 0.8, "default-bold", "left", "top")
    local maleBtnW = (bw - 70) / 2
    local maleSelected = Mzansi.Login._charGender == 0
    local maleBg = maleSelected and tocolor(200, 170, 50, 255) or tocolor(20, 35, 55, 255)
    local maleTxt = maleSelected and tocolor(10, 22, 40, 255) or tocolor(136, 153, 170, 255)
    dxDrawRectangle(bx + 30, by + 285, maleBtnW, 35, maleBg, false)
    dxDrawText("MALE", bx + 30, by + 285, bx + 30 + maleBtnW, by + 320, maleTxt, 0.9, "default-bold", "center", "center")

    local femaleBtnX = bx + 30 + maleBtnW + 10
    local femaleSelected = Mzansi.Login._charGender == 1
    local femaleBg = femaleSelected and tocolor(200, 170, 50, 255) or tocolor(20, 35, 55, 255)
    local femaleTxt = femaleSelected and tocolor(10, 22, 40, 255) or tocolor(136, 153, 170, 255)
    dxDrawRectangle(femaleBtnX, by + 285, maleBtnW, 35, femaleBg, false)
    dxDrawText("FEMALE", femaleBtnX, by + 285, femaleBtnX + maleBtnW, by + 320, femaleTxt, 0.9, "default-bold", "center", "center")

    -- Submit Button
    local submitHover = Mzansi.Login.handleClick(bx + 30, by + 340, bw - 60, 40)
    local submitColor = submitHover and tocolor(218, 184, 64, 255) or tocolor(200, 170, 50, 255)
    dxDrawRectangle(bx + 30, by + 340, bw - 60, 40, submitColor, false)
    dxDrawText("ENTER SOUTH AFRICA", bx + 30, by + 340, bx + bw - 30, by + 380, tocolor(10, 22, 40, 255), 1.0, "default-bold", "center", "center")

    if Mzansi.Login._error ~= "" and getTickCount() - Mzansi.Login._errorTime < 6000 then
        dxDrawText(Mzansi.Login._error, bx + 30, by + bh - 24, bx + bw - 30, by + bh - 4, tocolor(255, 68, 68, 255), 0.8, "default", "center", "top")
    end
end

-- Mouse Click Handler
addEventHandler("onClientClick", root, function(button, state)
    if not Mzansi.Login._active then return end
    if button ~= "left" or state ~= "down" then return end

    local sx, sy = guiGetScreenSize()

    if Mzansi.Login._screen == "login" then
        local bw, bh = 400, 380
        local bx = (sx - bw) / 2
        local by = (sy - bh) / 2

        if Mzansi.Login.handleClick(bx + 30, by + 105, bw - 60, 35) then
            Mzansi.Login._focused = "username"
        elseif Mzansi.Login.handleClick(bx + 30, by + 175, bw - 60, 35) then
            Mzansi.Login._focused = "password"
        elseif Mzansi.Login.handleClick(bx + 30, by + 225, bw - 60, 38) then
            Mzansi.Login._focused = nil
            local user = Mzansi.Login._fields.username
            local pass = Mzansi.Login._fields.password
            if #user < 1 or #pass < 1 then
                Mzansi.Login._error = "Please fill in all fields."
                Mzansi.Login._errorTime = getTickCount()
            else
                triggerServerEvent("mzansi:accounts:login", localPlayer, user, pass)
            end
        elseif Mzansi.Login.handleClick(bx + 30, by + 273, bw - 60, 32) then
            Mzansi.Login._focused = nil
            Mzansi.Login.showRegisterUI()
        elseif Mzansi.Login.handleClick(bx + 30, by + 315, bw - 60, 25) then
            Mzansi.Login._focused = nil
            Mzansi.Login.showRecoveryUI()
        else
            Mzansi.Login._focused = nil
        end

    elseif Mzansi.Login._screen == "register" then
        local bw, bh = 420, 430
        local bx = (sx - bw) / 2
        local by = (sy - bh) / 2

        local fieldAreas = {
            { key = "regUsername", y = 98 },
            { key = "regEmail", y = 148 },
            { key = "regPassword", y = 198 },
            { key = "regConfirm", y = 248 },
        }

        local clickedField = false
        for _, fa in ipairs(fieldAreas) do
            if Mzansi.Login.handleClick(bx + 30, by + fa.y, bw - 60, 32) then
                Mzansi.Login._focused = fa.key
                clickedField = true
            end
        end

        if not clickedField then
            if Mzansi.Login.handleClick(bx + 30, by + 290, bw - 60, 38) then
                Mzansi.Login._focused = nil
                local user = Mzansi.Login._fields.regUsername
                local pass = Mzansi.Login._fields.regPassword
                local confirm = Mzansi.Login._fields.regConfirm
                local email = Mzansi.Login._fields.regEmail

                if #user < 3 then
                    Mzansi.Login._error = "Username must be 3+ characters."
                    Mzansi.Login._errorTime = getTickCount()
                elseif #pass < 6 then
                    Mzansi.Login._error = "Password must be 6+ characters."
                    Mzansi.Login._errorTime = getTickCount()
                elseif pass ~= confirm then
                    Mzansi.Login._error = "Passwords do not match."
                    Mzansi.Login._errorTime = getTickCount()
                else
                    triggerServerEvent("mzansi:accounts:register", localPlayer, user, pass, email)
                end
            elseif Mzansi.Login.handleClick(bx + 30, by + 338, bw - 60, 32) then
                Mzansi.Login._focused = nil
                Mzansi.Login.showLoginUI()
            else
                Mzansi.Login._focused = nil
            end
        end

    elseif Mzansi.Login._screen == "recovery" then
        local bw, bh = 420, 430
        local bx = (sx - bw) / 2
        local by = (sy - bh) / 2

        local fieldAreas = {
            { key = "recUsername", y = 98 },
            { key = "recEmail", y = 148 },
            { key = "recPassword", y = 198 },
            { key = "recConfirm", y = 248 },
        }

        local clickedField = false
        for _, fa in ipairs(fieldAreas) do
            if Mzansi.Login.handleClick(bx + 30, by + fa.y, bw - 60, 32) then
                Mzansi.Login._focused = fa.key
                clickedField = true
            end
        end

        if not clickedField then
            if Mzansi.Login.handleClick(bx + 30, by + 290, bw - 60, 38) then
                Mzansi.Login._focused = nil
                local user = Mzansi.Login._fields.recUsername
                local email = Mzansi.Login._fields.recEmail
                local pass = Mzansi.Login._fields.recPassword
                local confirm = Mzansi.Login._fields.recConfirm

                if #user < 1 or #email < 3 then
                    Mzansi.Login._error = "Please enter your username and email."
                    Mzansi.Login._errorTime = getTickCount()
                elseif #pass < 6 then
                    Mzansi.Login._error = "New password must be 6+ characters."
                    Mzansi.Login._errorTime = getTickCount()
                elseif pass ~= confirm then
                    Mzansi.Login._error = "Passwords do not match."
                    Mzansi.Login._errorTime = getTickCount()
                else
                    triggerServerEvent("mzansi:accounts:recoverPassword", localPlayer, user, email, pass)
                end
            elseif Mzansi.Login.handleClick(bx + 30, by + 338, bw - 60, 32) then
                Mzansi.Login._focused = nil
                Mzansi.Login.showLoginUI()
            else
                Mzansi.Login._focused = nil
            end
        end

    elseif Mzansi.Login._screen == "charcreate" then
        local bw, bh = 420, 420
        local bx = (sx - bw) / 2
        local by = (sy - bh) / 2

        local fieldAreas = {
            { key = "charFirst", y = 105 },
            { key = "charLast", y = 165 },
            { key = "charAge", y = 225 },
        }

        local clickedField = false
        for _, fa in ipairs(fieldAreas) do
            if Mzansi.Login.handleClick(bx + 30, by + fa.y, bw - 60, 35) then
                Mzansi.Login._focused = fa.key
                clickedField = true
            end
        end

        if not clickedField then
            local maleBtnW = (bw - 70) / 2
            local femaleBtnX = bx + 30 + maleBtnW + 10

            if Mzansi.Login.handleClick(bx + 30, by + 285, maleBtnW, 35) then
                Mzansi.Login._charGender = 0
            elseif Mzansi.Login.handleClick(femaleBtnX, by + 285, maleBtnW, 35) then
                Mzansi.Login._charGender = 1
            elseif Mzansi.Login.handleClick(bx + 30, by + 340, bw - 60, 40) then
                Mzansi.Login._focused = nil
                local first = Mzansi.Login._fields.charFirst
                local last = Mzansi.Login._fields.charLast
                local age = Mzansi.Login._fields.charAge

                if #first < 2 then
                    Mzansi.Login._error = "First name must be 2+ characters."
                    Mzansi.Login._errorTime = getTickCount()
                elseif #last < 2 then
                    Mzansi.Login._error = "Last name must be 2+ characters."
                    Mzansi.Login._errorTime = getTickCount()
                elseif tonumber(age) == nil or tonumber(age) < 16 or tonumber(age) > 80 then
                    Mzansi.Login._error = "Age must be 16-80."
                    Mzansi.Login._errorTime = getTickCount()
                else
                    triggerServerEvent("mzansi:characters:create", localPlayer, first, last, tonumber(age), Mzansi.Login._charGender)
                end
            else
                Mzansi.Login._focused = nil
            end
        end
    end
end)

-- Character Input Handler: Captures uppercase letters (A-Z), lowercase (a-z), @ symbol, numbers & punctuation natively!
addEventHandler("onClientCharacter", root, function(character)
    if not Mzansi.Login._active then return end
    if not Mzansi.Login._focused then return end

    local fieldKey = Mzansi.Login._focused
    local maxLen = 32
    if fieldKey == "password" or fieldKey == "regPassword" or fieldKey == "regConfirm" or fieldKey == "recPassword" or fieldKey == "recConfirm" then
        maxLen = 64
    elseif fieldKey == "regEmail" or fieldKey == "recEmail" then
        maxLen = 128
    elseif fieldKey == "charAge" then
        maxLen = 3
    end

    local text = Mzansi.Login._fields[fieldKey] or ""
    if #text < maxLen then
        if fieldKey == "charAge" then
            if character >= "0" and character <= "9" then
                Mzansi.Login._fields[fieldKey] = text .. character
            end
        else
            Mzansi.Login._fields[fieldKey] = text .. character
        end
    end
end)

-- Key Handler: Strictly controls non-character actions (backspace, enter, tab)
addEventHandler("onClientKey", root, function(button, pressOrRelease)
    if not Mzansi.Login._active then return end
    if not Mzansi.Login._focused then return end
    if pressOrRelease then return end

    local fieldKey = Mzansi.Login._focused

    if button == "backspace" then
        local text = Mzansi.Login._fields[fieldKey] or ""
        if #text > 0 then
            Mzansi.Login._fields[fieldKey] = string.sub(text, 1, #text - 1)
        end
        cancelEvent()
        return
    end

    if button == "tab" then
        cancelEvent()
        return
    end

    if button == "enter" or button == "num_enter" then
        cancelEvent()
        return
    end
end)

addEventHandler("mzansi:accounts:showLogin", root, function()
    Mzansi.Login.showLoginUI()
end)

addEventHandler("mzansi:accounts:showRegistration", root, function()
    Mzansi.Login.showRegisterUI()
end)

addEventHandler("mzansi:accounts:showRecovery", root, function()
    Mzansi.Login.showRecoveryUI()
end)

addEventHandler("mzansi:accounts:showCharCreate", root, function()
    Mzansi.Login.showCharCreateUI()
end)

addEventHandler("mzansi:accounts:loginResult", root, function(success, message)
    if success then
        outputChatBox("[Mzansi] " .. message, 50, 255, 50)
    else
        Mzansi.Login._error = message
        Mzansi.Login._errorTime = getTickCount()
    end
end)

addEventHandler("mzansi:accounts:registerResult", root, function(success, message)
    if success then
        outputChatBox("[Mzansi] " .. message, 50, 255, 50)
        Mzansi.Login.showLoginUI()
    else
        Mzansi.Login._error = message
        Mzansi.Login._errorTime = getTickCount()
    end
end)

addEventHandler("mzansi:accounts:recoveryResult", root, function(success, message)
    if success then
        outputChatBox("[Mzansi] " .. message, 50, 255, 50)
        Mzansi.Login.showLoginUI()
    else
        Mzansi.Login._error = message
        Mzansi.Login._errorTime = getTickCount()
    end
end)

addEventHandler("mzansi:characters:createResult", root, function(success, message)
    if success then
        Mzansi.Login.hideLoginUI()
        setCameraTarget(localPlayer)
        fadeCamera(true, 1.0)
        outputChatBox("[Mzansi] " .. message, 50, 255, 50)
    else
        Mzansi.Login._error = message
        Mzansi.Login._errorTime = getTickCount()
    end
end)

addEventHandler("mzansi:characters:loaded", root, function(character)
    Mzansi.Login.hideLoginUI()
    setCameraTarget(localPlayer)
    fadeCamera(true, 1.0)
    local fn = character.firstName or character.first_name or ""
    local ln = character.lastName or character.last_name or ""
    outputChatBox("[Mzansi] Welcome, " .. fn .. " " .. ln .. "!", 255, 215, 0)
end)

addEventHandler("mzansi:characters:spawnComplete", root, function(sx, sy, sz)
    -- Freeze BEFORE hideLoginUI (hideLoginUI unfreezes — race caused mid-air falls)
    setElementFrozen(localPlayer, true)
    Mzansi.Login.hideLoginUI()
    showChat(true)
    setElementFrozen(localPlayer, true)

    -- Spawn intro cutscene starts ~400ms later and owns the camera.
    -- Do not force camera restore here — cutscene onDone restores.
    triggerEvent("mzansi:client:ready", localPlayer)

    setTimer(function()
        outputChatBox("[Mzansi RP] Press 'F1' anytime for the Roleplay Guide, Careers, Gangs & GPS!", 200, 170, 50)
        outputChatBox("[Mzansi RP] Free transport: Type /rent or use the green marker outside the airport.", 100, 200, 255)
        outputChatBox("#FFD700[CUTSCENE] #FFFFFFSPACE or /skip skips cinematics (flights, portals, spawn).", 255, 215, 0, true)
    end, 1500, 1)

    -- Fallback: if cutscene never started, restore gameplay camera + unfreeze
    setTimer(function()
        if isElement(localPlayer) and not (Mzansi.Cutscene and Mzansi.Cutscene.isPlaying()) then
            setCameraTarget(localPlayer)
            fadeCamera(true, 0.5)
            setElementFrozen(localPlayer, false)
            triggerServerEvent("mzansi:characters:unfreeze", localPlayer)
        end
    end, 8000, 1)
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    setTimer(function()
        if not getElementData(localPlayer, "mzansi:character") then
            Mzansi.Login.showLoginUI()
        else
            setCameraTarget(localPlayer)
            fadeCamera(true, 1.0)
        end
    end, 1000, 1)
end)

-- Diagnostic and self-healing camera command
addCommandHandler("fixcam", function()
    if isElement(localPlayer) then
        Mzansi.Login._cinematicActive = false
        Mzansi.Login._active = false
        setCameraTarget(localPlayer)
        fadeCamera(true, 0.5)
        setElementFrozen(localPlayer, false)
        showCursor(false)
        showChat(true)
        outputChatBox("[Mzansi] Camera target and visual renderer restored successfully.", 50, 255, 50)
    end
end)

addCommandHandler("fixcamera", function()
    executeCommandHandler("fixcam")
end)
