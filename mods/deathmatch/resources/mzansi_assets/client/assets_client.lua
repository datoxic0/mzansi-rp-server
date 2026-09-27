-- ==============================================================
-- MZANSI ROLEPLAY: 3D ASSET STREAMING & MODEL REPLACEMENT PIPELINE
-- Angel: 3D Model Replacement & Asset Hydrator
-- ==============================================================

Mzansi = Mzansi or {}
Mzansi.Assets = {}

-- Target Model Replacement Manifest for authentic South African immersion
local REPLACEMENT_MANIFEST = {


    -- Road Signs (Object-Znaki)
    { modelId = 1234, name = "Road Sign - Speed Limit 60",         txd = "models/road_signs/Limit60.txd", dff = "models/road_signs/Limit60.dff", col = "models/road_signs/Limit60.col" },
    { modelId = 1235, name = "Road Sign - No Entry",               txd = "models/road_signs/NotEnter.txd", dff = "models/road_signs/NotEnter.dff", col = "models/road_signs/NotEnter.col" },
    { modelId = 1236, name = "Road Sign - Phone",                  txd = "models/road_signs/Phone.txd", dff = "models/road_signs/Phone.dff", col = "models/road_signs/Phone.col" },
    { modelId = 1237, name = "Road Sign - Yield",                  txd = "models/road_signs/Pov.txd", dff = "models/road_signs/Pov.dff", col = "models/road_signs/Pov.col" },
    { modelId = 1238, name = "Road Sign - Stop",                   txd = "models/road_signs/Stop.txd", dff = "models/road_signs/Stop.dff", col = "models/road_signs/Stop.col" },
    { modelId = 1239, name = "Road Sign - Warning",                txd = "models/road_signs/Warning.txd", dff = "models/road_signs/Warning.dff", col = "models/road_signs/Warning.col" },
    { modelId = 1240, name = "Road Sign - Railway Crossing",       txd = "models/road_signs/ZapPov.txd", dff = "models/road_signs/ZapPov.dff", col = "models/road_signs/ZapPov.col" },

    -- Interior Furniture Objects
    { modelId = 1300, name = "Interior - Carpet",                  txd = "models/interiors/alfombra.txd", dff = "models/interiors/alfombra.dff", col = nil },
    { modelId = 1301, name = "Interior - Apartment Set",           txd = "models/interiors/apartment.txd", dff = "models/interiors/apartment.dff", col = nil },
    { modelId = 1302, name = "Interior - Bar",                     txd = "models/interiors/barra.txd", dff = "models/interiors/barra.dff", col = nil },
    { modelId = 1303, name = "Interior - Closet",                  txd = "models/interiors/closet.txd", dff = "models/interiors/closet.dff", col = nil },
    { modelId = 1304, name = "Interior - Dining Set",              txd = "models/interiors/comedor.txd", dff = "models/interiors/comedor.dff", col = nil },
    { modelId = 1305, name = "Interior - Wall Art",                txd = "models/interiors/cuadros.txd", dff = "models/interiors/cuadros.dff", col = nil },
    { modelId = 1306, name = "Interior - Structures",              txd = "models/interiors/estructuras.txd", dff = "models/interiors/estructuras.dff", col = "models/interiors/estructuras.col" },
    { modelId = 1307, name = "Interior - Sink",                    txd = "models/interiors/lavabo.txd", dff = "models/interiors/lavabo.dff", col = nil },
    { modelId = 1308, name = "Interior - Patio Set",               txd = "models/interiors/patio.txd", dff = "models/interiors/patio.dff", col = nil },
    { modelId = 1309, name = "Interior - Flooring",                txd = "models/interiors/piso.txd", dff = "models/interiors/piso.dff", col = nil },
    { modelId = 1310, name = "Interior - Plants",                  txd = "models/interiors/plantas.txd", dff = "models/interiors/plantas.dff", col = nil },
    { modelId = 1311, name = "Interior - Living Room Set",         txd = "models/interiors/sala.txd", dff = "models/interiors/sala.dff", col = nil },
    { modelId = 1312, name = "Interior - TV Set",                  txd = "models/interiors/settv.txd", dff = "models/interiors/settv.dff", col = nil },
    { modelId = 1313, name = "Interior - Sofa/Armchair",           txd = "models/interiors/sillon.txd", dff = "models/interiors/sillon.dff", col = nil },

    -- DayZ Survival Items
    { modelId = 1400, name = "DayZ - Alice Backpack",              txd = "models/dayz_items/backpack_alice.txd", dff = "models/dayz_items/backpack_alice.dff", col = nil },
    { modelId = 1401, name = "DayZ - Coyote Backpack",             txd = "models/dayz_items/backpack_coyote.txd", dff = "models/dayz_items/backpack_coyote.dff", col = nil },
    { modelId = 1402, name = "DayZ - First Aid Kit",               txd = "models/dayz_items/first_aid_kit.txd", dff = "models/dayz_items/first_aid_kit.dff", col = nil },
    { modelId = 1403, name = "DayZ - Pain Killers",                txd = "models/dayz_items/pain_killers.txd", dff = "models/dayz_items/pain_killers.dff", col = nil },
    { modelId = 1404, name = "DayZ - Water Bottle",                txd = "models/dayz_items/water_bottle.txd", dff = "models/dayz_items/water_bottle.dff", col = nil },
    { modelId = 1405, name = "DayZ - Beans Can",                   txd = "models/dayz_items/beans_can.txd", dff = "models/dayz_items/beans_can.dff", col = nil },
    { modelId = 1406, name = "DayZ - Civilian Clothes",            txd = "models/dayz_items/civilian_clothes.txd", dff = "models/dayz_items/civilian_clothes.dff", col = nil },
    { modelId = 1407, name = "DayZ - Army Clothes",                txd = "models/dayz_items/army_clothes.txd", dff = "models/dayz_items/army_clothes.dff", col = nil },
    { modelId = 1408, name = "DayZ - Katana",                      txd = "models/dayz_items/katana.txd", dff = "models/dayz_items/katana.dff", col = nil },

    -- DayZ Skins (TXD-only replacements)
    { modelId = 73, name = "DayZ - Civilian Male 1",               txd = "models/dayz_skins/13.txd", dff = nil, col = nil },
    { modelId = 179, name = "DayZ - Civilian Male 2",              txd = "models/dayz_skins/22.txd", dff = nil, col = nil },
    { modelId = 180, name = "DayZ - Military Male 1",              txd = "models/dayz_skins/280.txd", dff = nil, col = nil },
    { modelId = 181, name = "DayZ - Military Male 2",              txd = "models/dayz_skins/287.txd", dff = nil, col = nil },
    { modelId = 182, name = "DayZ - Bandit Skin",                  txd = "models/dayz_skins/229.txd", dff = nil, col = nil },
    { modelId = 183, name = "DayZ - Hero Skin",                    txd = "models/dayz_skins/230.txd", dff = nil, col = nil },
    { modelId = 184, name = "DayZ - Medic Skin",                   txd = "models/dayz_skins/274.txd", dff = nil, col = nil },

    -- PUBG Tactical Items
    { modelId = 1500, name = "PUBG - Large Backpack (Lvl 3)",      txd = "models/pubg_items/backpack_large.txd", dff = "models/pubg_items/backpack_large.dff", col = nil },
    { modelId = 1501, name = "PUBG - Medium Backpack (Lvl 2)",     txd = "models/pubg_items/backpack_medium.txd", dff = "models/pubg_items/backpack_medium.dff", col = nil },
    { modelId = 1502, name = "PUBG - Armor Level 1",               txd = "models/pubg_items/armor1.txd", dff = "models/pubg_items/armor1.dff", col = nil },
    { modelId = 1503, name = "PUBG - Armor Level 2",               txd = "models/pubg_items/armor2.txd", dff = "models/pubg_items/armor2.dff", col = nil },
    { modelId = 1504, name = "PUBG - Armor Level 3",               txd = "models/pubg_items/armor3.txd", dff = "models/pubg_items/armor3.dff", col = nil },
    { modelId = 1505, name = "PUBG - Helmet Level 1",              txd = "models/pubg_items/helmet1.txd", dff = "models/pubg_items/helmet1.dff", col = nil },
    { modelId = 1506, name = "PUBG - Helmet Level 2",              txd = "models/pubg_items/helmet2.txd", dff = "models/pubg_items/helmet2.dff", col = nil },
    { modelId = 1507, name = "PUBG - Helmet Level 3",              txd = "models/pubg_items/helmet3.txd", dff = "models/pubg_items/helmet3.dff", col = nil },
    { modelId = 1508, name = "PUBG - Frying Pan",                  txd = "models/pubg_items/pan.txd", dff = "models/pubg_items/pan.dff", col = nil },
    { modelId = 1509, name = "PUBG - Machete",                     txd = "models/pubg_items/machete.txd", dff = "models/pubg_items/machete.dff", col = nil },
    { modelId = 1510, name = "PUBG - AWM Sniper Rifle",            txd = "models/pubg_items/awm.txd", dff = "models/pubg_items/awm.dff", col = nil },


}

function replaceModel(modelId, txdPath, dffPath, colPath)
    if not modelId then return false end

    -- Strict Safety Guard: Never replace native vehicle IDs (400-611) to prevent RenderWare frame crashes at 0x7F120E
    if modelId >= 400 and modelId <= 611 then
        outputDebugString("[Mzansi-Assets] Shield: Protected vehicle model " .. modelId .. " from custom replacement (prevents 0x7F120E crash).", 3)
        return false
    end

    -- 1. TXD Texture Archive
    if txdPath and fileExists(txdPath) then
        local txd = engineLoadTXD(txdPath)
        if txd then
            engineImportTXD(txd, modelId)
        end
    end

    -- 2. DFF 3D Geometry
    if dffPath and fileExists(dffPath) then
        local dff = engineLoadDFF(dffPath)
        if dff then
            engineReplaceModel(dff, modelId)
        end
    end

    -- 3. COL Collision Mesh (optional)
    if colPath and fileExists(colPath) then
        local col = engineLoadCOL(colPath)
        if col then
            engineReplaceCOL(col, modelId)
        end
    end

    return true
end

function getPendingModels()
    local pending = {}
    for _, item in ipairs(REPLACEMENT_MANIFEST) do
        local hasTxd = item.txd and fileExists(item.txd)
        local hasDff = item.dff and fileExists(item.dff)
        table.insert(pending, {
            modelId = item.modelId,
            name = item.name,
            installed = (hasTxd and hasDff)
        })
    end
    return pending
end

-- HD Roads Shader System
local hdRoadsShader = nil
local hdRoadsTextures = {}

function initHDRoadsShader()
    local shaderPath = "shaders/hdroads/shader.fx"
    if not fileExists(shaderPath) then
        outputDebugString("[Mzansi-Assets] HD Roads shader not found at " .. shaderPath)
        return false
    end

    hdRoadsShader = dxCreateShader(shaderPath)
    if not hdRoadsShader then
        outputDebugString("[Mzansi-Assets] Failed to create HD Roads shader!")
        return false
    end

    -- Load road textures
    local textureList = {
        "cos_hiwaymid_256", "crossing2_law", "crossing_law", "desert_1line256",
        "des_oldrunway", "dt_road_stoplinea", "hiwayend_256", "roadnew4_256",
        "sf_junction1", "sf_junction2", "sl_freew2road1", "snpedtest1BLND",
        "Tar_1line256HV", "Tar_1line256HVblend2", "Tar_freewyleft", "Tar_freewyright",
        "vegasdirtyroad3_256", "vegastriproad1_256"
    }

    for _, texName in ipairs(textureList) do
        local texPath = "shaders/hdroads/img/" .. texName .. ".png"
        if fileExists(texPath) then
            local tex = dxCreateTexture(texPath)
            if tex then
                hdRoadsTextures[texName] = tex
                dxSetShaderValue(hdRoadsShader, texName, tex)
            end
        end
    end

    -- Apply to world textures
    local roadTextures = {
        "cj_roads*", "road*", "highway*", "freeway*", "tar*", "asphalt*",
        "street*", "pavement*", "concrete*", "dirt*", "gravel*"
    }

    for _, pattern in ipairs(roadTextures) do
        engineApplyShaderToWorldTexture(hdRoadsShader, pattern)
    end

    outputDebugString("[Mzansi-Assets] HD Roads Shader activated with " .. #textureList .. " high-res textures!")
    return true
end

-- Initialize asset pipeline on resource start
addEventHandler("onClientResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Assets] Angel: Initializing South African 3D Asset Pipeline...")
    local loadedCount = 0

    for _, item in ipairs(REPLACEMENT_MANIFEST) do
        local hasDff = item.dff and fileExists(item.dff)
        local hasTxd = item.txd and fileExists(item.txd)
        if hasDff or hasTxd then
            if replaceModel(item.modelId, item.txd, item.dff, item.col) then
                loadedCount = loadedCount + 1
                outputDebugString("[Mzansi-Assets] Replaced Model " .. item.modelId .. " -> " .. item.name)
            end
        end
    end

    -- Initialize HD Roads Shader (textures now on disk)
    setTimer(function()
        if initHDRoadsShader() then
            loadedCount = loadedCount + 1
        end
    end, 1000, 1)

    if loadedCount == 0 then
        outputDebugString("[Mzansi-Assets] Asset pipeline active. Place custom .dff / .txd models into mzansi_assets/models/ to stream South African vehicles and skins.")
    else
        outputDebugString("[Mzansi-Assets] Successfully loaded " .. loadedCount .. " custom South African 3D models + HD Roads Shader.")
    end
end)

-- Cleanup on resource stop
addEventHandler("onClientResourceStop", resourceRoot, function()
    if hdRoadsShader then
        destroyElement(hdRoadsShader)
        hdRoadsShader = nil
    end
    for _, tex in pairs(hdRoadsTextures) do
        if isElement(tex) then destroyElement(tex) end
    end
    hdRoadsTextures = {}
end)