-- ==============================================================
-- MZANSI LIVING WORLD — CLIENT AMBIENT SCENARIOS
-- Ambient props, smoking, mobile phone calls, and talking pairs
-- ==============================================================
local _scenarioTimer = nil

local IDLE_SCENARIOS = {
    { anim = { "SMOKING", "M_smk_in" },    duration = 4000 },
    { anim = { "SMOKING", "M_smk_loop" },  duration = 6000 },
    { anim = { "DEALER", "DEALER_IDLE" },  duration = 8000 },
    { anim = { "GANGS", "prtial_gngtlkA" },duration = 5000 },
    { anim = { "GANGS", "prtial_gngtlkB" },duration = 5000 }
}

-- Periodic evaluation of ambient ped idles
function MzansiLiving_ScenarioTick()
    local peds = getElementsByType("ped", root, true)

    for _, ped in ipairs(peds) do
        if getElementData(ped, "mzansi:ai:enabled") and isElementSyncer(ped) then
            local state = getElementData(ped, "mzansi:ai:state")
            if state == MzansiLiving.Enums.State.SCENARIO then
                local currentAnim = getPedAnimation(ped)
                if not currentAnim then
                    local s = IDLE_SCENARIOS[math.random(1, #IDLE_SCENARIOS)]
                    setPedAnimation(ped, s.anim[1], s.anim[2], -1, false, false, false)
                end
            end
        end
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    _scenarioTimer = setTimer(MzansiLiving_ScenarioTick, 4000, 0)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if isTimer(_scenarioTimer) then killTimer(_scenarioTimer) end
end)
