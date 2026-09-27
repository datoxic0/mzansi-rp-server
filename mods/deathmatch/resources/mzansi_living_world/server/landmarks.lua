-- ==============================================================
-- MZANSI LIVING WORLD — PERMANENT ATMOSPHERIC LANDMARKS
-- Anchors authentic human activity at airport, Ganton, banks, SAPS
-- ==============================================================
MzansiLiving = MzansiLiving or {}
MzansiLiving.Landmarks = {}

local _landmarkPeds = {}

local LANDMARK_DEFINITIONS = {
    -- -------------------------------------------------------------
    -- Cape Town International Airport (CTIA / LSIA Terminal Area)
    -- Elevated concourse sidewalk: Z = 14.5
    -- -------------------------------------------------------------
    {
        name = "CTIA Airport Security Guard",
        model = 71, x = 1686.0, y = -2258.0, z = 14.5, rot = 180,
        anim = { "COP_AMBIENT", "Coplook_loop" }
    },
    {
        name = "CTIA Traveler Waiting",
        model = 17, x = 1680.0, y = -2262.0, z = 14.5, rot = 85,
        anim = { "DEALER", "DEALER_IDLE" }
    },
    {
        name = "CTIA Business Executive",
        model = 240, x = 1692.0, y = -2264.0, z = 14.5, rot = 265,
        anim = { "SMOKING", "M_smk_loop" }
    },
    {
        name = "CTIA Taxi Rank Attendant",
        model = 42, x = 1665.0, y = -2257.0, z = 13.5, rot = 90,
        anim = { "GANGS", "prtial_gngtlkA" }
    },

    -- -------------------------------------------------------------
    -- Ganton / Grove Street Cul-De-Sac
    -- -------------------------------------------------------------
    {
        name = "Grove Fam Street Soldier 1",
        model = 105, x = 2495.0, y = -1668.0, z = 13.3, rot = 115,
        anim = { "GANGS", "prtial_gngtlkA" }
    },
    {
        name = "Grove Fam Street Soldier 2",
        model = 106, x = 2493.5, y = -1669.5, z = 13.3, rot = 295,
        anim = { "GANGS", "prtial_gngtlkB" }
    },
    {
        name = "Grove Fam Porch Chiller",
        model = 107, x = 2503.0, y = -1672.0, z = 13.3, rot = 45,
        anim = { "SMOKING", "M_smk_in" }
    },

    -- -------------------------------------------------------------
    -- Idlewood Gas Station & 24/7 Mini-Mart
    -- -------------------------------------------------------------
    {
        name = "Idlewood Petrol Attendant",
        model = 50, x = 1938.0, y = -1772.0, z = 13.4, rot = 90,
        anim = { "SCRATCHING", "scdrgb_loop" }
    },
    {
        name = "Idlewood Corner Civilian",
        model = 142, x = 1934.0, y = -1769.0, z = 13.4, rot = 260,
        anim = { "DEALER", "DEALER_IDLE" }
    },

    -- -------------------------------------------------------------
    -- Market District & SAPS Central Police Station
    -- -------------------------------------------------------------
    {
        name = "SAPS Guard Officer Alpha",
        model = 280, x = 1555.0, y = -1676.0, z = 16.2, rot = 90,
        anim = { "COP_AMBIENT", "Coplook_loop" }
    },
    {
        name = "SAPS Guard Officer Bravo",
        model = 281, x = 1555.0, y = -1673.5, z = 16.2, rot = 90,
        anim = { "COP_AMBIENT", "Coplook_think" }
    },
    {
        name = "Market District Bus Passenger",
        model = 186, x = 1538.0, y = -1665.0, z = 13.5, rot = 180,
        anim = { "ped", "idle_chat" }
    },

    -- -------------------------------------------------------------
    -- Downtown / City Hall & Standard Bank Vault Plaza
    -- -------------------------------------------------------------
    {
        name = "Standard Bank Plaza Security",
        model = 164, x = 1461.0, y = -1016.0, z = 23.5, rot = 180,
        anim = { "COP_AMBIENT", "Coplook_loop" }
    },
    {
        name = "Financial District Broker",
        model = 295, x = 1466.0, y = -1020.0, z = 23.5, rot = 350,
        anim = { "SMOKING", "M_smk_loop" }
    },

    -- -------------------------------------------------------------
    -- Santa Maria Beach Boardwalk
    -- -------------------------------------------------------------
    {
        name = "Santa Maria Lifeguard",
        model = 97, x = 368.0, y = -2040.0, z = 7.8, rot = 180,
        anim = { "BEACH", "bng_wlk" }
    },
    {
        name = "Santa Maria Pier Chiller",
        model = 18, x = 378.0, y = -2046.0, z = 7.8, rot = 210,
        anim = { "BEACH", "SitnWait_loop_W" }
    },

    -- =============================================================
    -- DURBAN / KWAZULU-NATAL (KZN / SF) LANDMARKS
    -- =============================================================
    -- King Shaka International Airport (KSIA)
    {
        name = "KSIA Arrival Ambassador",
        model = 17, x = -1420.0, y = -287.0, z = 14.1, rot = 90,
        anim = { "COP_AMBIENT", "Coplook_loop" }
    },
    {
        name = "KSIA Taxi Marshall",
        model = 42, x = -1415.0, y = -295.0, z = 14.1, rot = 350,
        anim = { "GANGS", "prtial_gngtlkA" }
    },
    -- Durban Golden Mile & Ocean Flats
    {
        name = "Golden Mile Lifeguard",
        model = 97, x = -1985.0, y = 160.0, z = 27.5, rot = 180,
        anim = { "BEACH", "bng_wlk" }
    },
    {
        name = "Durban Beachfront Vendor",
        model = 186, x = -1978.0, y = 165.0, z = 27.5, rot = 220,
        anim = { "DEALER", "DEALER_IDLE" }
    },
    -- Durban Garcia Hostels (Zulu Warriors Stronghold)
    {
        name = "Hostel Izinduna Guard",
        model = 143, x = -2160.5, y = -235.5, z = 36.5, rot = 90,
        anim = { "GANGS", "prtial_gngtlkA" }
    },
    {
        name = "Zulu Warrior Gate Lookout",
        model = 105, x = -2155.0, y = -240.0, z = 36.5, rot = 35,
        anim = { "SMOKING", "M_smk_loop" }
    },
    -- Easter Basin Durban Harbour (Smuggling & Freight)
    {
        name = "Easter Basin Port Docker",
        model = 260, x = -1600.0, y = 150.0, z = 7.1, rot = 270,
        anim = { "SCRATCHING", "scdrgb_loop" }
    },
    {
        name = "Harbour Container Supervisor",
        model = 73, x = -1595.0, y = 155.0, z = 7.1, rot = 180,
        anim = { "ped", "idle_chat" }
    },

    -- =============================================================
    -- JOHANNESBURG / GAUTENG (JOZI / LV) LANDMARKS
    -- =============================================================
    -- O.R. Tambo International Airport (ORTIA)
    {
        name = "ORTIA Customs Officer",
        model = 71, x = 1612.0, y = 1622.0, z = 10.8, rot = 180,
        anim = { "COP_AMBIENT", "Coplook_loop" }
    },
    {
        name = "ORTIA Chauffeur Waiting",
        model = 240, x = 1608.0, y = 1618.0, z = 10.8, rot = 45,
        anim = { "SMOKING", "M_smk_in" }
    },
    -- Egoli Gold Reef Strip & Casino Vault
    {
        name = "Gold Reef High Roller",
        model = 295, x = 2028.0, y = 1008.0, z = 10.8, rot = 0,
        anim = { "SMOKING", "M_smk_loop" }
    },
    {
        name = "Casino Strip Bouncer",
        model = 164, x = 2035.0, y = 1012.0, z = 10.8, rot = 270,
        anim = { "COP_AMBIENT", "Coplook_think" }
    },
    -- Redsands East (Boere Mafia Stronghold)
    {
        name = "Boere Mafia Enforcer",
        model = 158, x = 2270.5, y = 1430.5, z = 11.5, rot = 90,
        anim = { "GANGS", "prtial_gngtlkA" }
    },
    {
        name = "Redsands Arms Stockist",
        model = 161, x = 2275.0, y = 1435.0, z = 11.5, rot = 180,
        anim = { "SMOKING", "M_smk_loop" }
    },
    -- Old Venturas Strip (Nyau Dust Cartel)
    {
        name = "Nyau Cartel Sentry",
        model = 29, x = 2480.5, y = 2110.5, z = 11.0, rot = 0,
        anim = { "DEALER", "DEALER_IDLE" }
    },
    {
        name = "Dust Alley Street Dealer",
        model = 142, x = 2485.0, y = 2115.0, z = 11.0, rot = 210,
        anim = { "GANGS", "prtial_gngtlkB" }
    }
}

function MzansiLiving.Landmarks.spawnAll()
    for _, def in ipairs(LANDMARK_DEFINITIONS) do
        local ped = createPed(def.model, def.x, def.y, def.z, def.rot, true)
        if ped then
            setElementFrozen(ped, true)
            -- NOTE: setPedCanBeKnockedOffBike is CLIENT-ONLY — not called on server
            setElementData(ped, "mzansi:ai:landmark", true)
            setElementData(ped, "mzansi:ai:enabled", false)
            setElementData(ped, "mzansi:landmark:name", def.name)

            if def.anim then
                setPedAnimation(ped, def.anim[1], def.anim[2], -1, true, false, false)
            end

            table.insert(_landmarkPeds, ped)
        end
    end
    outputDebugString("[Mzansi-LivingWorld] ✓ " .. #_landmarkPeds .. " permanent atmospheric landmark peds deployed!")
end

addEventHandler("onResourceStart", resourceRoot, function()
    MzansiLiving.Landmarks.spawnAll()
end)

addEventHandler("onResourceStop", resourceRoot, function()
    for _, ped in ipairs(_landmarkPeds) do
        if isElement(ped) then destroyElement(ped) end
    end
    _landmarkPeds = {}
end)
