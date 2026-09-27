--[[
    Mzansi Cutscene Engine (Client)
    Letterboxed, camera-choreographed, skippable cinematics.
    Skip: SPACE, mouse click on SKIP, /skip, /skipcutscene
]]

Mzansi = Mzansi or {}
Mzansi.Cutscene = Mzansi.Cutscene or {}

local CS = Mzansi.Cutscene

CS._active = false
CS._def = nil
CS._sceneIndex = 0
CS._sceneStart = 0
CS._skipped = false
CS._props = {}
CS._letterbox = 0
CS._showCursor = false
CS._frozePlayer = false
CS._captionAlpha = 0

local FONT_TITLE = "default-bold"
local FONT_BODY = "default"
local FONT_SMALL = "default-small"

local function screen()
    local sx, sy = guiGetScreenSize()
    return sx, sy
end

local function easeInOut(t)
    if t <= 0 then return 0 end
    if t >= 1 then return 1 end
    return t * t * (3 - 2 * t)
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function lerpCam(from, to, t)
    return {
        lerp(from[1], to[1], t), lerp(from[2], to[2], t), lerp(from[3], to[3], t),
        lerp(from[4] or from[1], to[4] or to[1], t),
        lerp(from[5] or from[2], to[5] or to[2], t),
        lerp(from[6] or from[3], to[6] or to[3], t),
    }
end

local function destroyProps()
    for i = #CS._props, 1, -1 do
        local p = CS._props[i]
        if isElement(p) then destroyElement(p) end
        CS._props[i] = nil
    end
end

local function restoreCamera()
    if isElement(localPlayer) then
        setCameraTarget(localPlayer)
        fadeCamera(true, 0.35)
    end
    if CS._frozePlayer and isElement(localPlayer) then
        setElementFrozen(localPlayer, false)
    end
    CS._frozePlayer = false
    if CS._showCursor then
        showCursor(false)
        CS._showCursor = false
    end
end

local function emitAdvance(def)
    if not def or not def.token or not def.advancePhase then return end
    triggerServerEvent("mzansi:cutscene:advance", localPlayer, def.token, def.advancePhase)
end

function CS.isPlaying()
    return CS._active == true
end

function CS.stop(skipped, silent)
    if not CS._active then return end
    local def = CS._def
    CS._active = false
    CS._skipped = skipped and true or false
    destroyProps()
    restoreCamera()
    CS._letterbox = 0
    CS._captionAlpha = 0
    CS._sceneIndex = 0
    CS._def = nil
    if isElement(localPlayer) then
        setElementData(localPlayer, "mzansi:cutscene:active", false)
    end

    if def and def.advancePhase and not silent then
        emitAdvance(def)
    end
    if def and type(def.onDone) == "function" then
        def.onDone(CS._skipped)
    end
    CS._skipped = false
end

function CS.skip()
    if not CS._active then return end
    if CS._def and CS._def.skippable == false then return end
    playSoundFrontEnd(42)
    CS.stop(true, false)
end

local function startScene(index)
    local def = CS._def
    if not def then return end
    local scenes = def.scenes or {}
    if index > #scenes then
        CS.stop(false, false)
        return
    end
    CS._sceneIndex = index
    CS._sceneStart = getTickCount()
    CS._captionAlpha = 0
    local scene = scenes[index]

    if scene.fadeIn then
        fadeCamera(false, 0)
        fadeCamera(true, (scene.fadeIn / 1000))
    end

    if scene.plane and not isElement(CS._plane) then
        local pl = scene.plane
        local a = pl.from or pl.at
        if a then
            local modelId = tonumber(pl.model) or 577
            local elem
            if modelId >= 400 and modelId <= 611 then
                elem = createVehicle(modelId, a[1], a[2], a[3], 0, pl.pitchFrom or 0, a[4] or 0)
                if elem then
                    setElementFrozen(elem, true)
                    setElementCollisionsEnabled(elem, false)
                end
            else
                elem = createObject(modelId, a[1], a[2], a[3], 0, pl.pitchFrom or 0, a[4] or 0)
                if elem and pl.scale then
                    setObjectScale(elem, pl.scale)
                end
            end
            if elem then
                CS._plane = elem
                CS._props[#CS._props + 1] = elem
            end
        end
    end

    if scene.onStart then
        scene.onStart(scene)
    end
end

local function sceneProgress(scene)
    local elapsed = getTickCount() - CS._sceneStart
    local dur = math.max(1, scene.duration or 3000)
    local t = elapsed / dur
    if t > 1 then t = 1 end
    return t, elapsed, dur
end

function CS.play(def)
    if type(def) ~= "table" or type(def.scenes) ~= "table" or #def.scenes == 0 then
        return false
    end
    if CS._active then
        CS.stop(true, true)
    end

    triggerEvent("mzansi:flight:close", localPlayer)
    triggerEvent("mzansi:phone:close", localPlayer)
    triggerEvent("mzansi:radio:close", localPlayer)
    triggerEvent("mzansi:freeroam:close", localPlayer)
    triggerEvent("mzansi:admin:close", localPlayer)
    triggerEvent("mzansi:dashboard:close", localPlayer)
    triggerEvent("mzansi:market:close", localPlayer)
    triggerEvent("mzansi:bank:close", localPlayer)
    triggerEvent("mzansi:shop:closeUI", localPlayer)
    triggerEvent("mzansi:intel:uiToggle", resourceRoot, false)

    CS._def = def
    CS._active = true
    CS._skipped = false
    CS._letterbox = 0
    CS._props = {}
    CS._plane = nil
    CS._showCursor = false

    if def.freeze ~= false and isElement(localPlayer) then
        setElementFrozen(localPlayer, true)
        CS._frozePlayer = true
    end

    if def.showCursor then
        showCursor(true)
        CS._showCursor = true
    end

    fadeCamera(true, 0.2)
    setElementData(localPlayer, "mzansi:cutscene:active", true)
    startScene(1)
    playSoundFrontEnd(40)
    return true
end

-- ── Render ───────────────────────────────────────────────────
addEventHandler("onClientRender", root, function()
    if not CS._active or not CS._def then return end
    local scenes = CS._def.scenes or {}
    local scene = scenes[CS._sceneIndex]
    if not scene then
        CS.stop(false, false)
        return
    end

    local t, elapsed, dur = sceneProgress(scene)
    local et = easeInOut(t)
    local sx, sy = screen()

    -- Letterbox target
    local lbTarget = (CS._def.letterbox == false) and 0 or 1
    if lbTarget == 1 then
        CS._letterbox = math.min(1, CS._letterbox + 0.08)
    else
        CS._letterbox = math.max(0, CS._letterbox - 0.08)
    end

    -- Camera
    if scene.move then
        local cam = lerpCam(scene.move.from, scene.move.to, et)
        setCameraMatrix(cam[1], cam[2], cam[3], cam[4], cam[5], cam[6], 0, scene.fov or 70)
    elseif scene.cam then
        local c = scene.cam
        setCameraMatrix(c[1], c[2], c[3], c[4] or c[1], c[5] or c[2], c[6] or c[3], 0, scene.fov or 70)
    end

    -- Plane animation
    if scene.plane and isElement(CS._plane) then
        local pl = scene.plane
        local a, b = pl.from, pl.to or pl.from
        if a and b then
            local px = lerp(a[1], b[1], et)
            local py = lerp(a[2], b[2], et)
            local pz = lerp(a[3], b[3], et)
            local rz = lerp(a[4] or 0, b[4] or 0, et)
            local pitch = lerp(pl.pitchFrom or 0, pl.pitchTo or 0, et)
            setElementPosition(CS._plane, px, py, pz)
            setElementRotation(CS._plane, 0, pitch, rz)
        end
    end

    if scene.onProgress then
        scene.onProgress(et, scene)
    end

    -- Letterbox bars
    local barH = math.floor(sy * 0.11 * CS._letterbox)
    if barH > 0 then
        dxDrawRectangle(0, 0, sx, barH, tocolor(0, 0, 0, 255))
        dxDrawRectangle(0, sy - barH, sx, barH, tocolor(0, 0, 0, 255))
    end

    -- Caption fade in/out
    local capA = 255
    if t < 0.12 then capA = math.floor(255 * (t / 0.12)) end
    if t > 0.85 then capA = math.floor(255 * ((1 - t) / 0.15)) end
    if capA < 0 then capA = 0 end
    CS._captionAlpha = capA

    local midY = math.floor(sy * 0.78)
    if scene.caption and scene.caption ~= "" then
        dxDrawText(scene.caption, 0, midY, sx, midY + 28,
            tocolor(255, 215, 0, capA), 1.2, FONT_TITLE, "center", "top")
    end
    if scene.sub and scene.sub ~= "" then
        dxDrawText(scene.sub, 0, midY + 30, sx, midY + 52,
            tocolor(230, 235, 240, capA), 1.0, FONT_BODY, "center", "top")
    end

    -- Progress bar (bottom letterbox)
    if CS._letterbox > 0.5 then
        local totalDur = 0
        for i = 1, #scenes do totalDur = totalDur + (scenes[i].duration or 3000) end
        local before = 0
        for i = 1, CS._sceneIndex - 1 do before = before + (scenes[i].duration or 3000) end
        local overall = (before + elapsed) / math.max(1, totalDur)
        local pbW = math.floor(sx * 0.36)
        local pbX = math.floor((sx - pbW) / 2)
        local pbY = sy - math.floor(sy * 0.11 * CS._letterbox) + math.floor(sy * 0.11 * CS._letterbox * 0.35)
        dxDrawRectangle(pbX, pbY, pbW, 3, tocolor(80, 80, 80, 180))
        dxDrawRectangle(pbX, pbY, pbW * overall, 3, tocolor(200, 170, 50, 230))
    end

    -- Skip UI
    if CS._def.skippable ~= false then
        local hint = "SPACE  ·  /skip  ·  CLICK TO SKIP"
        local tw = 280
        local bx = sx - tw - 24
        local by = 18 + barH
        local mx, my = getCursorPosition()
        local hovered = false
        if mx and my then
            mx, my = mx * sx, my * sy
            hovered = mx >= bx and mx <= bx + tw and my >= by and my <= by + 28
        end
        local bg = hovered and tocolor(200, 170, 50, 230) or tocolor(10, 16, 28, 200)
        dxDrawRectangle(bx, by, tw, 28, bg)
        dxDrawRectangle(bx, by, tw, 1, tocolor(200, 170, 50, 160))
        dxDrawText("SKIP  ▶", bx + 10, by, bx + 80, by + 28,
            hovered and tocolor(10, 10, 10, 255) or tocolor(255, 215, 0, 255), 1.0, FONT_TITLE, "left", "center")
        dxDrawText(hint, bx + 70, by, bx + tw - 10, by + 28,
            hovered and tocolor(20, 20, 20, 230) or tocolor(160, 175, 190, 230), 0.85, FONT_SMALL, "right", "center")

        if hovered and getKeyState("mouse1") and not CS._clickLock then
            CS._clickLock = true
            setTimer(function() CS._clickLock = false end, 250, 1)
            CS.skip()
        end
    end

    -- Scene title top-left (small)
    if CS._def.title and barH > 4 then
        dxDrawText(CS._def.title, 18, 4, sx * 0.5, barH,
            tocolor(200, 210, 220, 200), 0.95, FONT_SMALL, "left", "center")
    end

    -- Advance scene
    if t >= 1 then
        if scene.onEnd then scene.onEnd(scene) end
        startScene(CS._sceneIndex + 1)
    end
end)

-- ── Skip inputs ──────────────────────────────────────────────
bindKey("space", "down", function()
    if CS._active then
        CS.skip()
    end
end)

addCommandHandler("skip", function()
    if CS._active then CS.skip() end
end)

addCommandHandler("skipcutscene", function()
    if CS._active then CS.skip() end
end)

addEventHandler("onClientKey", root, function(button, press)
    if not CS._active or not press then return end
    if button == "escape" and CS._def and CS._def.skippable ~= false then
        CS.skip()
        cancelEvent()
    end
end)

addEvent("mzansi:cutscene:play", true)
addEventHandler("mzansi:cutscene:play", root, function(def)
    -- Only play pre-built defs here; kind/phase payloads are handled by cutscene_scenes.lua
    if type(def) == "table" and type(def.scenes) == "table" then
        CS.play(def)
    end
end)

addEvent("mzansi:cutscene:stop", true)
addEventHandler("mzansi:cutscene:stop", root, function()
    if CS._active then
        CS.stop(true, true)
    end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if CS._active then
        CS._active = false
        destroyProps()
        restoreCamera()
    end
end)

outputDebugString("[Mzansi-Core] Cutscene engine loaded.")
