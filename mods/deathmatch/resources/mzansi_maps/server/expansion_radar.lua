-- ============================================================
-- Expansion radar references — blips for ocean maps + portal hubs
-- Zones: Custom-City-LS (dim 0), Vice City (dim 10), Liberty City (dim 20)
-- ============================================================
Mzansi = Mzansi or {}
Mzansi.ExpansionRadar = {}

local EXPANSION_BLIPS = {
    -- Vice City district (ocean, dimension 10)
    { x = -4000.0, y = -4000.0, z = 20.0,  sprite = 19,  dim = 10, r = 240, g = 100, b = 200, name = "Vice City District" },
    { x = -4000.0, y = -3845.0, z = 20.0,  sprite = 16,  dim = 10, r = 255, g = 215, b = 0,   name = "VCIA International" },
    -- Liberty City district (ocean, dimension 20)
    { x = 3995.0,  y = -3990.0, z = 20.0,  sprite = 19,  dim = 20, r = 100, g = 180, b = 240, name = "Liberty City District" },
    { x = 3990.0,  y = -4160.0, z = 20.0,  sprite = 16,  dim = 20, r = 255, g = 215, b = 0,   name = "Francis International" },
    -- Dimension-0 portal hubs (so the main radar shows multiverse gateways)
    { x = 2765.0,  y = -2455.0, z = 20.0,  sprite = 55,  dim = 0,  r = 240, g = 100, b = 200, name = "VC Maritime Portal" },
    { x = -1580.0, y = 65.0,    z = 20.0,  sprite = 55,  dim = 0,  r = 100, g = 180, b = 240, name = "LC Freight Portal" },
}

function Mzansi.ExpansionRadar.init()
    outputDebugString("[Mzansi-ExpansionRadar] Publishing multiverse zone blips...", 3)
    for _, b in ipairs(EXPANSION_BLIPS) do
        local blip = createBlip(b.x, b.y, b.z, b.sprite, 2, b.r, b.g, b.b, 255, 0, 600.0)
        if blip then
            setElementDimension(blip, b.dim)
            setBlipVisibleDistance(blip, 800.0)
            if type(setBlipAsShortRange) == "function" then
                setBlipAsShortRange(blip, true)
            end
        end
    end
end

addEventHandler("onResourceStart", resourceRoot, function()
    Mzansi.ExpansionRadar.init()
end)
