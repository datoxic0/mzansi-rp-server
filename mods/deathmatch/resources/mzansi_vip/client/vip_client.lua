--[[
    Mzansi Roleplay - Ngamla (GQonqa) VIP Client Subsystem
    
    Features:
    1. Singleplayer-style keystroke sequence cheat listener ("gqonqa").
    2. 3D Floating Gold Nametags for Ngamla VIP & Sovereign Creators.
]]

local _keyBuffer = ""
local CHEAT_WORD = "gqonqa"

-- Listen to printable character inputs
addEventHandler("onClientCharacter", root, function(character)
    if isChatBoxInputActive() or isConsoleActive() then return end

    _keyBuffer = (_keyBuffer .. string.lower(character))
    if string.len(_keyBuffer) > 20 then
        _keyBuffer = string.sub(_keyBuffer, -20)
    end

    -- Check if cheat code matches ending
    if string.sub(_keyBuffer, -string.len(CHEAT_WORD)) == CHEAT_WORD then
        _keyBuffer = ""
        triggerServerEvent("mzansi:vip:activateCheat", localPlayer)
    end
end)

-- 3D World Floating VIP Nametags
addEventHandler("onClientRender", root, function()
    local cx, cy, cz = getCameraMatrix()
    local myDim = getElementDimension(localPlayer)
    local myInt = getElementInterior(localPlayer)

    for _, p in ipairs(getElementsByType("player", root, true)) do
        if p ~= localPlayer and isElement(p) and isElementOnScreen(p) then
            if getElementDimension(p) == myDim and getElementInterior(p) == myInt then
                local vipTier = getElementData(p, "mzansi:vip")
                local isCreator = getElementData(p, "mzansi:creator")

                if isCreator or (vipTier and vipTier > 0) then
                    local hx, hy, hz = getPedBonePosition(p, 8) -- Head bone
                    hz = hz + 0.45

                    local dist = getDistanceBetweenPoints3D(cx, cy, cz, hx, hy, hz)
                    if dist <= 25.0 and isLineOfSightClear(cx, cy, cz, hx, hy, hz, true, false, false, true, false, false, false) then
                        local sx, sy = getScreenFromWorldPosition(hx, hy, hz)
                        if sx and sy then
                            local scale = math.max(0.6, 1.0 - (dist / 35.0))
                            local tagText = isCreator and "👑 SOVEREIGN CREATOR 👑" or "⭐ NGAMLA CITIZEN ⭐"
                            local tagColor = isCreator and tocolor(255, 223, 0, 240) or tocolor(255, 215, 0, 220)

                            -- Text shadow & main text
                            dxDrawText(tagText, sx + 1, sy + 1, sx + 1, sy + 1, tocolor(0, 0, 0, 200), scale * 0.9, "default-bold", "center", "center", false, false, false)
                            dxDrawText(tagText, sx, sy, sx, sy, tagColor, scale * 0.9, "default-bold", "center", "center", false, false, false)
                        end
                    end
                end
            end
        end
    end
end)
