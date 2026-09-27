Mzansi = Mzansi or {}
Mzansi.LabEngine = Mzansi.LabEngine or {}

-- Ported from ASCADS component-defs.ts evaluateGate + simulator.ts simulate (3-phase).
-- Tri-valued Signal: 0 | 1 | "X"

local MAX_ITERATIONS = 200
local SETTLE_PASSES = 4

local function isUnknown(v) return v == "X" end

local function invertSig(v)
    if v == "X" then return "X" end
    if v == 1 then return 0 end
    return 1
end

local function reduceAnd(inputs)
    local hasX = false
    for _, v in ipairs(inputs) do
        if v == 0 then return 0 end
        if isUnknown(v) then hasX = true end
    end
    if hasX then return "X" end
    return 1
end

local function reduceOr(inputs)
    local hasX = false
    for _, v in ipairs(inputs) do
        if v == 1 then return 1 end
        if isUnknown(v) then hasX = true end
    end
    if hasX then return "X" end
    return 0
end

local function reduceXor(inputs)
    local ones = 0
    for _, v in ipairs(inputs) do
        if isUnknown(v) then return "X" end
        if v == 1 then ones = ones + 1 end
    end
    return (ones % 2 == 1) and 1 or 0
end

local function packBits(arr)
    local n = 0
    for i, b in ipairs(arr) do
        if b == 1 then n = n + bit32 and bit32.lshift(1, i - 1) or (2 ^ (i - 1)) end
    end
    return n
end

function Mzansi.LabEngine.evaluateGate(kind, inputs)
    inputs = inputs or {}
    if kind == "INPUT" then
        return { inputs[1] or 0 }
    elseif kind == "BUFFER" then
        return { inputs[1] or "X" }
    elseif kind == "NOT" then
        return { invertSig(inputs[1] or "X") }
    elseif kind == "AND" then
        return { reduceAnd(inputs) }
    elseif kind == "NAND" then
        return { invertSig(reduceAnd(inputs)) }
    elseif kind == "OR" then
        return { reduceOr(inputs) }
    elseif kind == "NOR" then
        return { invertSig(reduceOr(inputs)) }
    elseif kind == "XOR" then
        return { reduceXor(inputs) }
    elseif kind == "XNOR" then
        return { invertSig(reduceXor(inputs)) }
    elseif kind == "CONST0" then
        return { 0 }
    elseif kind == "CONST1" then
        return { 1 }
    elseif kind == "BUTTON" or kind == "CLOCK" or kind == "PROBE" then
        return { inputs[1] or 0 }
    elseif kind == "HALFADDER" then
        local a, b = inputs[1] or 0, inputs[2] or 0
        return { reduceXor({ a, b }), reduceAnd({ a, b }) }
    elseif kind == "FULLADDER" then
        local a, b, cin = inputs[1] or 0, inputs[2] or 0, inputs[3] or 0
        local s = reduceXor({ reduceXor({ a, b }), cin })
        local c = reduceOr({
            reduceAnd({ a, b }),
            reduceAnd({ a, cin }),
            reduceAnd({ b, cin }),
        })
        return { s, c }
    elseif kind == "OUTPUT" then
        return {}
    end
    return { "X" }
end

-- in/out pin counts; sources have out only, sinks have in only
local function pinCount(kind, side)
    local twoIn = {
        AND = true, OR = true, NAND = true, NOR = true, XOR = true, XNOR = true,
        HALFADDER = true,
    }
    local sources = { INPUT = true, BUTTON = true, CLOCK = true, CONST0 = true, CONST1 = true }
    local sinks = { OUTPUT = true, PROBE = true }
    if sources[kind] then
        return (side == "in") and 0 or 1
    end
    if sinks[kind] then
        return (side == "in") and 1 or 0
    end
    if side == "in" then
        if kind == "FULLADDER" then return 3 end
        if kind == "NOT" or kind == "BUFFER" then return 1 end
        if twoIn[kind] then return 2 end
        return 2
    end
    if kind == "HALFADDER" or kind == "FULLADDER" then return 2 end
    return 1
end

local function inKey(id, i) return id .. ":in:" .. tostring(i) end
local function outKey(id, i) return id .. ":out:" .. tostring(i) end

local function normalizeCircuit(circuit)
    local gates = circuit.gates or circuit or {}
    local wires = circuit.wires or {}
    return gates, wires
end

-- 3-phase simulate: seed → combinational loop → outputs
function Mzansi.LabEngine.simulate(circuit, inputAssignment)
    local gates, wires = normalizeCircuit(circuit)
    local pinValues = {}
    local byId = {}

    for _, g in ipairs(gates) do
        byId[g.id] = g
        local k0 = g.kind or g.type or ""
        local nIn = pinCount(k0, "in")
        local nOut = pinCount(k0, "out")
        for i = 0, nIn - 1 do
            pinValues[inKey(g.id, i)] = "X"
        end
        for i = 0, nOut - 1 do
            pinValues[outKey(g.id, i)] = "X"
        end
    end

    -- Seed source gates
    local inputList = {}
    for _, g in ipairs(gates) do
        local k = g.kind or g.type
        if k == "INPUT" or k == "BUTTON" or k == "CLOCK" then
            local val = 0
            if inputAssignment then
                local name = g.label or g.id
                val = tonumber(inputAssignment[name]) or tonumber(inputAssignment[g.id]) or 0
            elseif g.on ~= nil then
                val = g.on and 1 or 0
            end
            pinValues[outKey(g.id, 0)] = (val == 1) and 1 or 0
            inputList[#inputList + 1] = g.id
        elseif k == "CONST1" then
            pinValues[outKey(g.id, 0)] = 1
        elseif k == "CONST0" then
            pinValues[outKey(g.id, 0)] = 0
        end
    end

    local stable = false
    local iterations = 0
    local oscillating = false

    for pass = 1, MAX_ITERATIONS do
        iterations = pass
        local changed = false

        -- Wire propagation: source out -> sink in
        for _, w in ipairs(wires) do
            local fromKey = outKey(w.from_gate or w.fromGate or w.from, w.from_pin or w.fromPin or 0)
            local toKey = inKey(w.to_gate or w.toGate or w.to, w.to_pin or w.toPin or 0)
            if pinValues[fromKey] ~= nil then
                if pinValues[toKey] ~= pinValues[fromKey] then
                    pinValues[toKey] = pinValues[fromKey]
                    changed = true
                end
            end
        end

        -- Combinational / sink gates
        for _, g in ipairs(gates) do
            local k = g.kind or g.type
            if k ~= "INPUT" and k ~= "OUTPUT" and k ~= "PROBE" and k ~= "CONST0" and k ~= "CONST1"
               and k ~= "BUTTON" and k ~= "CLOCK" then
                local nIn = pinCount(k, "in")
                local ins = {}
                for i = 0, nIn - 1 do
                    local v = pinValues[inKey(g.id, i)]
                    ins[i + 1] = (v == nil) and "X" or v
                end
                local outs = Mzansi.LabEngine.evaluateGate(k, ins)
                for i, v in ipairs(outs) do
                    local key = outKey(g.id, i - 1)
                    if pinValues[key] ~= v then
                        pinValues[key] = v
                        changed = true
                    end
                end
            end
        end

        if not changed then
            stable = true
            break
        end
    end

    if not stable then oscillating = true end

    -- Collect sinks (OUTPUT gates — value on in:0)
    local outValues = {}
    for _, g in ipairs(gates) do
        if (g.kind or g.type) == "OUTPUT" then
            local v = pinValues[inKey(g.id, 0)]
            if v == nil then v = "X" end
            local label = g.label or g.id
            outValues[label] = v
        end
    end

    return {
        pinValues = pinValues,
        outputs = outValues,
        iterations = iterations,
        oscillating = oscillating,
        stable = stable,
    }
end

function Mzansi.LabEngine.inputGateLabels(circuit)
    local gates = normalizeCircuit(circuit)
    local labels = {}
    for _, g in ipairs(gates) do
        if (g.kind or g.type) == "INPUT" then
            labels[#labels + 1] = g.label or g.id
        end
    end
    table.sort(labels)
    return labels
end

function Mzansi.LabEngine.analyzeTruthTable(circuit, inputNames, outputNames)
    local gates = normalizeCircuit(circuit)
    local inputs = inputNames or Mzansi.LabEngine.inputGateLabels(circuit)
    local n = #inputs
    if n > 8 then
        return nil, "too many inputs (max 8)"
    end
    local rows = {}
    local total = 2 ^ n
    for mask = 0, total - 1 do
        local assignment = {}
        local bitRow = {}
        for i = 1, n do
            local bit = math.floor(mask / (2 ^ (n - i))) % 2
            assignment[inputs[i]] = bit
            bitRow[i] = bit
        end
        local sim = Mzansi.LabEngine.simulate(circuit, assignment)
        local row = { inputs = bitRow, outputs = {}, oscillating = sim.oscillating }
        if outputNames then
            for _, oname in ipairs(outputNames) do
                row.outputs[oname] = sim.outputs[oname]
            end
        else
            for k, v in pairs(sim.outputs) do
                row.outputs[k] = v
            end
        end
        rows[#rows + 1] = row
    end
    return rows
end

-- Pack output vector for a single named output (or first output) as golden array
function Mzansi.LabEngine.packOutputColumn(rows, outName)
    local col = {}
    for _, row in ipairs(rows) do
        local v = row.outputs[outName]
        if v == "X" or v == nil then
            col[#col + 1] = -1
        else
            col[#col + 1] = tonumber(v) or 0
        end
    end
    return col
end

function Mzansi.LabEngine.vectorsEqual(a, b)
    if #a ~= #b then return false end
    for i = 1, #a do
        if tonumber(a[i]) ~= tonumber(b[i]) then return false end
    end
    return true
end

function Mzansi.LabEngine.countGates(circuit)
    local gates = normalizeCircuit(circuit)
    local n = 0
    for _, g in ipairs(gates) do
        local k = g.kind or g.type
        if k ~= "INPUT" then n = n + 1 end
    end
    return n
end

function Mzansi.LabEngine.gateKindsUsed(circuit)
    local gates = normalizeCircuit(circuit)
    local set = {}
    for _, g in ipairs(gates) do
        set[g.kind or g.type] = true
    end
    return set
end

function Mzansi.LabEngine.validateAgainstChallenge(circuit, challenge)
    if type(circuit) ~= "table" then
        return false, "invalid circuit payload"
    end
    local gates = circuit.gates
    if type(gates) ~= "table" or #gates == 0 then
        return false, "circuit is empty"
    end
    local wires = circuit.wires or {}
    if type(wires) ~= "table" then
        return false, "invalid wires"
    end

    -- Palette whitelist
    local allowed = {}
    for _, name in ipairs(challenge.palette or {}) do allowed[name] = true end
    local used = Mzansi.LabEngine.gateKindsUsed(circuit)
    for kind in pairs(used) do
        if not allowed[kind] then
            return false, "gate not allowed: " .. tostring(kind)
        end
    end

    local gcount = Mzansi.LabEngine.countGates(circuit)
    if gcount < (challenge.min_gates or 1) then
        return false, "too few gates (min " .. tostring(challenge.min_gates) .. ")"
    end
    if gcount > (challenge.max_gates or 99) then
        return false, "too many gates (max " .. tostring(challenge.max_gates) .. ")"
    end

    -- Required input labels present
    local inLabels = {}
    for _, g in ipairs(gates) do
        if (g.kind or g.type) == "INPUT" then
            inLabels[g.label or g.id] = true
        end
    end
    for _, name in ipairs(challenge.inputs or {}) do
        if not inLabels[name] then
            return false, "missing input: " .. name
        end
    end

    local rows, err = Mzansi.LabEngine.analyzeTruthTable(circuit, challenge.inputs, challenge.outputs)
    if not rows then
        return false, err or "truth table failed"
    end

    -- Multi-output golden table
    if type(challenge.golden) == "table" and challenge.golden[1] ~= nil then
        local outName = challenge.outputs[1]
        local col = Mzansi.LabEngine.packOutputColumn(rows, outName)
        if not Mzansi.LabEngine.vectorsEqual(col, challenge.golden) then
            return false, "truth table mismatch on " .. outName
        end
    elseif type(challenge.golden) == "table" then
        for outName, golden in pairs(challenge.golden) do
            local col = Mzansi.LabEngine.packOutputColumn(rows, outName)
            if not Mzansi.LabEngine.vectorsEqual(col, golden) then
                return false, "truth table mismatch on " .. outName
            end
        end
    elseif challenge.golden_formula then
        -- formula challenges: evaluate golden per row
        for i, row in ipairs(rows) do
            local expected = Mzansi.Lab.evalGolden(challenge, row.inputs)
            local actual = tonumber(row.outputs[challenge.outputs[1]]) or -1
            if expected ~= nil and actual ~= expected then
                return false, "row " .. i .. " expected " .. expected .. " got " .. tostring(actual)
            end
        end
    else
        return false, "challenge has no golden reference"
    end

    -- Oscillation check
    for i, row in ipairs(rows) do
        if row.oscillating then
            return false, "row " .. i .. " oscillates (combinational loop)"
        end
        for _, v in pairs(row.outputs) do
            if v == "X" then
                return false, "undefined output (floating pin) in row " .. i
            end
        end
    end

    return true, "ok", rows, gcount
end

-- Convenience for external tools
function Mzansi.LabEngine.sopFromTable(rows, outName)
    local terms = {}
    for _, row in ipairs(rows) do
        local v = tonumber(row.outputs[outName])
        if v == 1 then
            local parts = {}
            for i, bit in ipairs(row.inputs) do
                local name = tostring(i)
                if bit == 1 then parts[#parts + 1] = name
                else parts[#parts + 1] = "¬" .. name end
            end
            terms[#terms + 1] = table.concat(parts, " · ")
        end
    end
    if #terms == 0 then return "0" end
    return table.concat(terms, " + ")
end
