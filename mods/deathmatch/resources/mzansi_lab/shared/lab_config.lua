Mzansi = Mzansi or {}
Mzansi.Lab = Mzansi.Lab or {}

-- Allowed palette per challenge. Gate kinds match ASCADS evaluateGate.
Mzansi.Lab.AllowedGates = {
    INPUT = true, OUTPUT = true, PROBE = true,
    BUFFER = true, NOT = true,
    AND = true, OR = true, NAND = true, NOR = true, XOR = true, XNOR = true,
    CONST0 = true, CONST1 = true, BUTTON = true, CLOCK = true,
    HALFADDER = true, FULLADDER = true,
}

Mzansi.Lab.Challenges = {
    {
        id = "lab_xor_from_nand",
        title = "XOR from NANDs",
        brief = "Build a 2-input XOR using only INPUT, OUTPUT and NAND gates. Truth table must match XOR exactly.",
        job = 14, -- MECHATRONIC_TECH (also open to CE)
        alt_job = 13,
        palette = { "INPUT", "OUTPUT", "NAND" },
        inputs = { "A", "B" },
        outputs = { "Y" },
        golden = { 0, 1, 1, 0 }, -- XOR AB 00,01,10,11
        min_gates = 3,
        max_gates = 12,
        payout = 1200,
        xp = 180,
        reward_item = "logic_module",
        concepts = { "NAND universality", "XOR identity: (A NAND (B NAND B)) NAND ((A NAND A) NAND B)" },
    },
    {
        id = "lab_half_adder",
        title = "Half Adder",
        brief = "Inputs A,B → outputs SUM (XOR) and CARRY (AND). Both tables must match.",
        job = 14,
        alt_job = 13,
        palette = { "INPUT", "OUTPUT", "XOR", "AND", "NOT", "OR", "NAND", "BUFFER" },
        inputs = { "A", "B" },
        outputs = { "S", "C" },
        golden = {
            S = { 0, 1, 1, 0 },
            C = { 0, 0, 0, 1 },
        },
        min_gates = 2,
        max_gates = 16,
        payout = 1500,
        xp = 200,
        reward_item = "pc_toolkit",
        concepts = { "Sum = A XOR B", "Carry = A AND B" },
    },
    {
        id = "lab_majority3",
        title = "Majority Voter (3-bit)",
        brief = "Output Y=1 when at least two of A,B,C are 1. Build any correct combinational network.",
        job = 14,
        alt_job = 13,
        palette = { "INPUT", "OUTPUT", "AND", "OR", "XOR", "NAND", "NOR", "NOT", "BUFFER" },
        inputs = { "A", "B", "C" },
        outputs = { "Y" },
        golden = { 0, 0, 0, 1, 0, 1, 1, 1 }, -- minterms 3,5,6,7
        min_gates = 3,
        max_gates = 20,
        payout = 1800,
        xp = 240,
        reward_item = "logic_module",
        concepts = { "AB + BC + AC", "Quine-McCluskey minimization" },
    },
    {
        id = "lab_and_or_mix",
        title = "Safety Interlock",
        brief = "Y = (START AND ENABLE) OR (RESET AND NOT FAULT). Four inputs, one output.",
        job = 13,
        alt_job = 14,
        palette = { "INPUT", "OUTPUT", "AND", "OR", "NOT", "NAND", "NOR", "BUFFER" },
        inputs = { "START", "ENABLE", "RESET", "FAULT" },
        outputs = { "Y" },
        golden_formula = { START = "S", ENABLE = "E", RESET = "R", FAULT = "F" },
        min_gates = 4,
        max_gates = 24,
        payout = 2000,
        xp = 260,
        reward_item = "plc_basic",
        concepts = { "Permissive series path", "Fault inhibit via NOT" },
    },
    {
        id = "lab_full_adder_xor",
        title = "Full Adder SUM only",
        brief = "Three inputs A,B,Cin. Output SUM = A XOR B XOR Cin. Cout ignored for this ticket.",
        job = 13,
        alt_job = 14,
        palette = { "INPUT", "OUTPUT", "XOR", "AND", "OR", "NAND", "NOT", "BUFFER" },
        inputs = { "A", "B", "Cin" },
        outputs = { "S" },
        golden = { 0, 1, 1, 0, 1, 0, 0, 1 },
        min_gates = 2,
        max_gates = 18,
        payout = 2200,
        xp = 280,
        reward_item = "servo_kit",
        concepts = { "Associative XOR chain" },
    },
    {
        id = "lab_inverter_chain",
        title = "Double Negation",
        brief = "Y = NOT(NOT(A)). Prove the identity with BUFFER or two NOTs.",
        job = 13,
        alt_job = 14,
        palette = { "INPUT", "OUTPUT", "NOT", "BUFFER" },
        inputs = { "A" },
        outputs = { "Y" },
        golden = { 1, 0 }, -- NOT: A=0 → 1, A=1 → 0
        min_gates = 1,
        max_gates = 6,
        payout = 400,
        xp = 80,
        reward_item = nil,
        concepts = { "¬¬A = A" },
    },
}

-- Golden formula evaluation for lab_and_or_mix (row index from 4-bit counter)
function Mzansi.Lab.evalGolden(challenge, rowBits)
    if challenge.id == "lab_and_or_mix" then
        local a = rowBits[1]
        local e = rowBits[2]
        local r = rowBits[3]
        local f = rowBits[4]
        if (a == 1 and e == 1) or (r == 1 and f == 0) then return 1 end
        return 0
    end
    return nil
end

function Mzansi.Lab.getChallenge(id)
    for _, c in ipairs(Mzansi.Lab.Challenges) do
        if c.id == id then return c end
    end
    return nil
end
