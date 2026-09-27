Mzansi = Mzansi or {}
Mzansi.Mech = Mzansi.Mech or {}

-- Original pedagogy (topics only — no third-party source content).
Mzansi.Mech.Stages = {
    {
        id = 1,
        name = "Boolean Gates",
        concept = "AND / OR / XOR / NOT truth tables",
        kind = "truth",
        gate = "XOR",
        inputs = { { 0, 0 }, { 0, 1 }, { 1, 0 }, { 1, 1 } },
        payout = 400,
        reward_item = nil,
    },
    {
        id = 2,
        name = "Combinational Keypad",
        concept = "Security keypad enable logic",
        kind = "truth",
        gate = "AND",
        inputs = { { 0, 0 }, { 0, 1 }, { 1, 0 }, { 1, 1 } },
        payout = 550,
        reward_item = "logic_module",
    },
    {
        id = 3,
        name = "Sequential Counter",
        concept = "Latch / counter state sequence",
        kind = "sequence",
        sequence = { 1, 0, 1, 1, 0 },
        payout = 700,
        reward_item = nil,
    },
    {
        id = 4,
        name = "Analog Divider",
        concept = "Ohm's law / voltage divider tolerance",
        kind = "value",
        target = 5.0,
        tolerance = 0.5,
        unit = "V",
        payout = 800,
        reward_item = nil,
    },
    {
        id = 5,
        name = "Continuity Board",
        concept = "Solder-path click order",
        kind = "order",
        order = { 2, 4, 1, 3 },
        payout = 950,
        reward_item = "logic_module",
    },
    {
        id = 6,
        name = "PLC Start/Stop Rung",
        concept = "Ladder start-stop with interlock",
        kind = "truth",
        gate = "OR",
        inputs = { { 0, 0 }, { 0, 1 }, { 1, 0 }, { 1, 1 } },
        payout = 1200,
        reward_item = "plc_basic",
    },
    {
        id = 7,
        name = "Sensor Calibration",
        concept = "Proximity sensor threshold window",
        kind = "value",
        target = 42.0,
        tolerance = 3.0,
        unit = "mm",
        payout = 1400,
        reward_item = nil,
    },
    {
        id = 8,
        name = "Robot Arm Path",
        concept = "Waypoint order + safety interlock first",
        kind = "order",
        order = { 0, 1, 3, 2, 4 },
        safety = true,
        payout = 1600,
        reward_item = "servo_kit",
    },
    {
        id = 9,
        name = "Joint CE/PLC Ticket",
        concept = "Integrate CE ticket board + ladder",
        kind = "truth",
        gate = "NAND",
        inputs = { { 0, 0 }, { 0, 1 }, { 1, 0 }, { 1, 1 } },
        payout = 1800,
        reward_item = nil,
    },
    {
        id = 10,
        name = "Maintenance Shift",
        concept = "Plant walkdown sign-off",
        kind = "value",
        target = 100,
        tolerance = 0.1,
        unit = "%",
        payout = 2000,
        reward_item = "plc_basic",
    },
}

function Mzansi.Mech.gateEval(gate, a, b)
    a = (tonumber(a) or 0) ~= 0 and 1 or 0
    b = (tonumber(b) or 0) ~= 0 and 1 or 0
    if gate == "AND" then return a * b end
    if gate == "OR" then return (a + b > 0) and 1 or 0 end
    if gate == "XOR" then return (a ~= b) and 1 or 0 end
    if gate == "NOT" then return 1 - a end
    if gate == "NAND" then return (a * b == 1) and 0 or 1 end
    if gate == "NOR" then return (a + b > 0) and 0 or 1 end
    return 0
end
