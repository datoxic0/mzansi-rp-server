Mzansi = Mzansi or {}
Mzansi.Lab = Mzansi.Lab or {}

local browserElement = nil
local isOpen = false

local function openLab()
    if isOpen and browserElement and isElement(browserElement) then
        -- toggle via parent GUI browser visibility is controlled by showCursor + render
        -- recreate on reopen if destroyed
    end

    if browserElement and isElement(browserElement) then
        isOpen = true
        showCursor(true)
        return
    end

    local w, h = 1100, 700
    local sw, sh = guiGetScreenSize()
    local x = math.floor((sw - w) / 2)
    local y = math.floor((sh - h) / 2)

    local browser = guiCreateBrowser(x, y, w, h, false, false, false)
    if not browser then
        outputChatBox("[LAB] Failed to create browser.", 255, 80, 80)
        return
    end

    browserElement = guiGetBrowser(browser)
    addEventHandler("onClientBrowserCreated", browserElement, function()
        loadBrowserURL(source, "http://mta/local/ui/lab.html")
        triggerServerEvent("mzansi:lab:listChallenges", localPlayer)
    end)

    isOpen = true
    showCursor(true)
end

local function closeLab()
    if browserElement and isElement(browserElement) then
        -- guiCreateBrowser returns GUI element; destroy via parent
        local parent = browserElement
        if isElement(parent) then
            destroyElement(parent)
        end
    end
    browserElement = nil
    isOpen = false
    showCursor(false)
end

local function js(code)
    if browserElement and isElement(browserElement) then
        executeBrowserJavascript(browserElement, code)
    end
end

addCommandHandler("lab", function()
    if isOpen and not browserElement then
        isOpen = false
    end
    if isOpen and browserElement and isElement(browserElement) then
        closeLab()
    else
        openLab()
    end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Lab] Client lab ready. Type /lab to open.")
end)

addEvent("mzansi:lab:setChallenges", true)
addEventHandler("mzansi:lab:setChallenges", root, function(list)
    local json = toJSON(list) or "[]"
    -- MTA toJSON produces non-standard tokens; replace with JS-safe via global assignment string
    js("window.__setChallenges && window.__setChallenges(" .. json .. ");")
end)

addEvent("mzansi:lab:result", true)
addEventHandler("mzansi:lab:result", root, function(ok, message, challengeId)
    local safeMsg = tostring(message):gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", "")
    js("window.__setResult && window.__setResult(" .. (ok and "true" or "false") ..
        ', "' .. safeMsg .. '", "' .. tostring(challengeId) .. '");')
    outputChatBox(
        (ok and "#00cc66[LAB] #ffffff" or "#ff5555[LAB] #ffffff") .. tostring(message),
        255, 255, 255, true
    )
end)

addEvent("mzansi:lab:draftSaved", true)
addEventHandler("mzansi:lab:draftSaved", root, function(ok)
    js("window.__draftSaved && window.__draftSaved(" .. (ok and "true" or "false") .. ");")
end)

addEvent("mzansi:lab:submitCef", true)
addEventHandler("mzansi:lab:submitCef", root, function(challengeId, circuit)
    triggerServerEvent("mzansi:lab:submit", client or source, challengeId, circuit)
end)

addEvent("mzansi:lab:saveCef", true)
addEventHandler("mzansi:lab:saveCef", root, function(challengeId, circuit)
    triggerServerEvent("mzansi:lab:saveDraft", client or source, challengeId, circuit)
end)

addEvent("mzansi:lab:closeCef", true)
addEventHandler("mzansi:lab:closeCef", root, function()
    closeLab()
end)

addEvent("mzansi:lab:listCef", true)
addEventHandler("mzansi:lab:listCef", root, function()
    triggerServerEvent("mzansi:lab:listChallenges", client or source)
end)
