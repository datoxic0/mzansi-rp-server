-- ==============================================================
-- MZANSI ROAD NETWORK & ROADWAY WAYPOINT REPOSITORY
-- Authoritative surveyed road lanes across Los Santos metropolitan
-- Ensures all spawned ambient vehicles drive strictly on asphalt
-- ==============================================================

Mzansi = Mzansi or {}
Mzansi.Roads = {}

-- Curated Road Networks (Loops with exact lane coordinates and headings)
Mzansi.Roads.Circuits = {
    -- 1. Commerce & Pershing Square Civic Ring (Dual Lane Asphalt)
    COMMERCE_RING = {
        name = "Commerce & Pershing Square Loop",
        nodes = {
            { x = 1485.0, y = -1740.0, z = 13.5, heading = 0,   speed = 0.20 },
            { x = 1485.0, y = -1690.0, z = 13.5, heading = 0,   speed = 0.20 },
            { x = 1485.0, y = -1630.0, z = 13.5, heading = 0,   speed = 0.20 },
            { x = 1515.0, y = -1630.0, z = 13.5, heading = 90,  speed = 0.20 },
            { x = 1538.0, y = -1645.0, z = 13.5, heading = 180, speed = 0.20 },
            { x = 1538.0, y = -1700.0, z = 13.5, heading = 180, speed = 0.20 },
            { x = 1538.0, y = -1740.0, z = 13.5, heading = 180, speed = 0.20 },
            { x = 1510.0, y = -1740.0, z = 13.5, heading = 270, speed = 0.20 },
        }
    },

    -- 2. Idlewood - Ganton Main Arterial
    IDLEWOOD_GANTON = {
        name = "Idlewood & Ganton Commercial Corridor",
        nodes = {
            { x = 1930.0, y = -1772.0, z = 13.5, heading = 90,  speed = 0.22 },
            { x = 2030.0, y = -1772.0, z = 13.5, heading = 90,  speed = 0.22 },
            { x = 2140.0, y = -1772.0, z = 13.5, heading = 90,  speed = 0.22 },
            { x = 2240.0, y = -1772.0, z = 13.5, heading = 90,  speed = 0.22 },
            { x = 2240.0, y = -1725.0, z = 13.5, heading = 0,   speed = 0.22 },
            { x = 2140.0, y = -1725.0, z = 13.5, heading = 270, speed = 0.22 },
            { x = 2030.0, y = -1725.0, z = 13.5, heading = 270, speed = 0.22 },
            { x = 1930.0, y = -1725.0, z = 13.5, heading = 270, speed = 0.22 },
            { x = 1930.0, y = -1750.0, z = 13.5, heading = 180, speed = 0.22 },
        }
    },

    -- 3. Los Santos International Airport (LSIA) Access Loop
    AIRPORT_LOOP = {
        name = "LSIA Terminal Concourse & Boulevard",
        nodes = {
            { x = 1662.0, y = -2220.0, z = 13.5, heading = 180, speed = 0.20 },
            { x = 1662.0, y = -2270.0, z = 13.5, heading = 180, speed = 0.20 },
            { x = 1662.0, y = -2320.0, z = 13.5, heading = 180, speed = 0.20 },
            { x = 1695.0, y = -2335.0, z = 13.5, heading = 90,  speed = 0.20 },
            { x = 1725.0, y = -2310.0, z = 13.5, heading = 0,   speed = 0.20 },
            { x = 1725.0, y = -2250.0, z = 13.5, heading = 0,   speed = 0.20 },
            { x = 1700.0, y = -2220.0, z = 13.5, heading = 270, speed = 0.20 },
        }
    },

    -- 4. Market & Hospital District Loop
    HOSPITAL_MARKET = {
        name = "All Saints Hospital & Market Ring",
        nodes = {
            { x = 1195.0, y = -1310.0, z = 13.5, heading = 180, speed = 0.20 },
            { x = 1195.0, y = -1355.0, z = 13.5, heading = 180, speed = 0.20 },
            { x = 1240.0, y = -1355.0, z = 13.5, heading = 90,  speed = 0.20 },
            { x = 1290.0, y = -1355.0, z = 13.5, heading = 90,  speed = 0.20 },
            { x = 1350.0, y = -1355.0, z = 13.5, heading = 90,  speed = 0.20 },
            { x = 1350.0, y = -1310.0, z = 13.5, heading = 0,   speed = 0.20 },
            { x = 1290.0, y = -1310.0, z = 13.5, heading = 270, speed = 0.20 },
            { x = 1240.0, y = -1310.0, z = 13.5, heading = 270, speed = 0.20 },
        }
    }
}

-- Returns a random spawn point on a verified asphalt road lane
function Mzansi.Roads.getRandomSpawnNode()
    local circuits = {}
    for _, c in pairs(Mzansi.Roads.Circuits) do
        table.insert(circuits, c)
    end
    local chosenCircuit = circuits[math.random(1, #circuits)]
    local nodeIdx = math.random(1, #chosenCircuit.nodes)
    return chosenCircuit.nodes[nodeIdx], chosenCircuit, nodeIdx
end
