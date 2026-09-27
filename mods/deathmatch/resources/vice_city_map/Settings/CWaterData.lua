-- ==============================================================
-- VICE CITY WATER DATA & DYNAMIC SEA LEVEL CONTROLLER
-- Sets authentic Vice City sea level in Dimension 10 (-5.0m)
-- so all streets, avenues, and beaches are dry, while oceans and
-- canals maintain natural water. Restores standard sea level in Dim 0.
-- ==============================================================

local isVCWaterActive = false

local function applyViceCityWaterLevel()
    local dim = getElementDimension(localPlayer)
    if dim == 10 then
        if not isVCWaterActive then
            setWaterLevel(-5.0)
            isVCWaterActive = true
            outputDebugString("[ViceCity-Water] Dimension 10 active: setWaterLevel(-5.0)")
        end
    else
        if isVCWaterActive then
            resetWaterLevel()
            isVCWaterActive = false
            outputDebugString("[ViceCity-Water] Dimension 0 active: resetWaterLevel()")
        end
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    applyViceCityWaterLevel()
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if isVCWaterActive then
        resetWaterLevel()
        isVCWaterActive = false
    end
end)

setTimer(applyViceCityWaterLevel, 1000, 0)