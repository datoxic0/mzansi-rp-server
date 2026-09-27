/* Mzansi Lab — ASCADS engine ports (component-defs evaluateGate, simulator, truth-table, wire geometry) */
(function (global) {
  "use strict";

  var MAX_ITERATIONS = 200;
  var GRID = 32;
  var GATE_W = 72;
  var GATE_H = 48;

  function invertSig(v) {
    if (v === "X") return "X";
    return v === 1 ? 0 : 1;
  }

  function reduceAnd(inputs) {
    var hasX = false;
    for (var i = 0; i < inputs.length; i++) {
      if (inputs[i] === 0) return 0;
      if (inputs[i] === "X") hasX = true;
    }
    return hasX ? "X" : 1;
  }

  function reduceOr(inputs) {
    var hasX = false;
    for (var i = 0; i < inputs.length; i++) {
      if (inputs[i] === 1) return 1;
      if (inputs[i] === "X") hasX = true;
    }
    return hasX ? "X" : 0;
  }

  function reduceXor(inputs) {
    var ones = 0;
    for (var i = 0; i < inputs.length; i++) {
      if (inputs[i] === "X") return "X";
      if (inputs[i] === 1) ones++;
    }
    return ones % 2 === 1 ? 1 : 0;
  }

  function evaluateGate(kind, inputs) {
    inputs = inputs || [];
    switch (kind) {
      case "INPUT":
      case "BUTTON":
      case "CLOCK":
        return [inputs[0] !== undefined ? inputs[0] : 0];
      case "BUFFER":
      case "PROBE":
        return [inputs[0] !== undefined ? inputs[0] : "X"];
      case "NOT":
        return [invertSig(inputs[0])];
      case "AND":
        return [reduceAnd(inputs)];
      case "NAND":
        return [invertSig(reduceAnd(inputs))];
      case "OR":
        return [reduceOr(inputs)];
      case "NOR":
        return [invertSig(reduceOr(inputs))];
      case "XOR":
        return [reduceXor(inputs)];
      case "XNOR":
        return [invertSig(reduceXor(inputs))];
      case "CONST0":
        return [0];
      case "CONST1":
        return [1];
      case "OUTPUT":
        return [];
      case "HALFADDER":
        return [reduceXor([inputs[0] || 0, inputs[1] || 0]), reduceAnd([inputs[0] || 0, inputs[1] || 0])];
      case "FULLADDER": {
        var a = inputs[0] || 0, b = inputs[1] || 0, cin = inputs[2] || 0;
        var s = reduceXor([reduceXor([a, b]), cin]);
        var c = reduceOr([
          reduceAnd([a, b]),
          reduceAnd([a, cin]),
          reduceAnd([b, cin]),
        ]);
        return [s, c];
      }
      default:
        return ["X"];
    }
  }

  var SOURCES = { INPUT: 1, BUTTON: 1, CLOCK: 1, CONST0: 1, CONST1: 1 };
  var SINKS = { OUTPUT: 1, PROBE: 1 };
  var ONE_IN = { NOT: 1, BUFFER: 1 };
  var TWO_IN = { AND: 1, OR: 1, NAND: 1, NOR: 1, XOR: 1, XNOR: 1, HALFADDER: 1 };

  function pinCount(kind, side) {
    if (SOURCES[kind]) return side === "in" ? 0 : 1;
    if (SINKS[kind]) return side === "in" ? 1 : 0;
    if (side === "in") {
      if (kind === "FULLADDER") return 3;
      if (ONE_IN[kind]) return 1;
      if (TWO_IN[kind]) return 2;
      return 2;
    }
    if (kind === "HALFADDER" || kind === "FULLADDER") return 2;
    return 1;
  }

  function inKey(id, i) { return id + ":in:" + i; }
  function outKey(id, i) { return id + ":out:" + i; }

  function sizeOf(kind) {
    return { w: GATE_W, h: GATE_H };
  }

  function pinsFor(gate) {
    var kind = gate.kind;
    var nIn = pinCount(kind, "in");
    var nOut = pinCount(kind, "out");
    var sz = sizeOf(kind);
    var pins = [];
    var i;
    for (i = 0; i < nIn; i++) {
      var yIn = nIn === 1 ? gate.y + sz.h / 2 : gate.y + ((i + 1) * sz.h) / (nIn + 1);
      pins.push({ gateId: gate.id, side: "in", index: i, x: gate.x, y: yIn });
    }
    for (i = 0; i < nOut; i++) {
      var yOut = nOut === 1 ? gate.y + sz.h / 2 : gate.y + ((i + 1) * sz.h) / (nOut + 1);
      pins.push({ gateId: gate.id, side: "out", index: i, x: gate.x + sz.w, y: yOut });
    }
    return pins;
  }

  function snap(v) {
    return Math.round(v / GRID) * GRID;
  }

  function wirePath(x1, y1, x2, y2) {
    var mx = snap((x1 + x2) / 2);
    return [
      { x: x1, y: y1 },
      { x: mx, y: y1 },
      { x: mx, y: y2 },
      { x: x2, y: y2 },
    ];
  }

  function simulate(circuit, inputAssignment) {
    var gates = circuit.gates || [];
    var wires = circuit.wires || [];
    var pinValues = {};
    var i, k, g, kind;

    for (i = 0; i < gates.length; i++) {
      g = gates[i];
      kind = g.kind;
      var nIn = pinCount(kind, "in");
      var nOut = pinCount(kind, "out");
      for (k = 0; k < nIn; k++) pinValues[inKey(g.id, k)] = "X";
      for (k = 0; k < nOut; k++) pinValues[outKey(g.id, k)] = "X";
    }

    for (i = 0; i < gates.length; i++) {
      g = gates[i];
      kind = g.kind;
      if (kind === "INPUT" || kind === "BUTTON" || kind === "CLOCK") {
        var val = 0;
        if (inputAssignment) {
          var name = g.label || g.id;
          val = Number(inputAssignment[name]) || (inputAssignment[g.id] !== undefined ? Number(inputAssignment[g.id]) : 0);
        } else if (g.on !== undefined) {
          val = g.on ? 1 : 0;
        }
        pinValues[outKey(g.id, 0)] = val === 1 ? 1 : 0;
      } else if (kind === "CONST1") {
        pinValues[outKey(g.id, 0)] = 1;
      } else if (kind === "CONST0") {
        pinValues[outKey(g.id, 0)] = 0;
      }
    }

    var stable = false;
    var iterations = 0;
    for (var pass = 1; pass <= MAX_ITERATIONS; pass++) {
      iterations = pass;
      var changed = false;
      for (i = 0; i < wires.length; i++) {
        var w = wires[i];
        var fromKey = outKey(w.from, w.fromPin || 0);
        var toKey = inKey(w.to, w.toPin || 0);
        if (pinValues[fromKey] !== undefined && pinValues[toKey] !== pinValues[fromKey]) {
          pinValues[toKey] = pinValues[fromKey];
          changed = true;
        }
      }
      for (i = 0; i < gates.length; i++) {
        g = gates[i];
        kind = g.kind;
        if (SOURCES[kind] || SINKS[kind]) continue;
        var nI = pinCount(kind, "in");
        var ins = [];
        for (k = 0; k < nI; k++) {
          var pv = pinValues[inKey(g.id, k)];
          ins.push(pv === undefined ? "X" : pv);
        }
        var outs = evaluateGate(kind, ins);
        for (k = 0; k < outs.length; k++) {
          var key = outKey(g.id, k);
          if (pinValues[key] !== outs[k]) {
            pinValues[key] = outs[k];
            changed = true;
          }
        }
      }
      if (!changed) {
        stable = true;
        break;
      }
    }

    var outValues = {};
    for (i = 0; i < gates.length; i++) {
      g = gates[i];
      if (g.kind === "OUTPUT") {
        var v = pinValues[inKey(g.id, 0)];
        outValues[g.label || g.id] = v === undefined ? "X" : v;
      }
    }

    return {
      pinValues: pinValues,
      outputs: outValues,
      iterations: iterations,
      oscillating: !stable,
      stable: stable,
    };
  }

  function analyzeTruthTable(circuit, inputNames, outputNames) {
    var gates = circuit.gates || [];
    var inputs = inputNames;
    if (!inputs) {
      inputs = [];
      for (var i = 0; i < gates.length; i++) {
        if (gates[i].kind === "INPUT") inputs.push(gates[i].label || gates[i].id);
      }
      inputs.sort();
    }
    var n = inputs.length;
    if (n > 8) return { error: "too many inputs (max 8)" };
    var rows = [];
    var total = Math.pow(2, n);
    for (var mask = 0; mask < total; mask++) {
      var assignment = {};
      var bitRow = [];
      for (var b = 0; b < n; b++) {
        var bit = Math.floor(mask / Math.pow(2, n - 1 - b)) % 2;
        assignment[inputs[b]] = bit;
        bitRow.push(bit);
      }
      var sim = simulate(circuit, assignment);
      var outs = {};
      if (outputNames) {
        for (var o = 0; o < outputNames.length; o++) {
          outs[outputNames[o]] = sim.outputs[outputNames[o]];
        }
      } else {
        outs = sim.outputs;
      }
      rows.push({ inputs: bitRow, outputs: outs, oscillating: sim.oscillating });
    }
    return { inputs: inputs, rows: rows };
  }

  function vectorsEqual(a, b) {
    if (!a || !b || a.length !== b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (Number(a[i]) !== Number(b[i])) return false;
    }
    return true;
  }

  function packOutputColumn(rows, outName) {
    var col = [];
    for (var i = 0; i < rows.length; i++) {
      var v = rows[i].outputs[outName];
      col.push(v === "X" || v === undefined || v === null ? -1 : Number(v));
    }
    return col;
  }

  function countGates(circuit) {
    var gates = circuit.gates || [];
    var n = 0;
    for (var i = 0; i < gates.length; i++) {
      if (gates[i].kind !== "INPUT") n++;
    }
    return n;
  }

  function gateKindsUsed(circuit) {
    var set = {};
    var gates = circuit.gates || [];
    for (var i = 0; i < gates.length; i++) set[gates[i].kind] = true;
    return set;
  }

  function sopFromTable(tt) {
    var terms = [];
    for (var r = 0; r < tt.rows.length; r++) {
      if (Number(tt.rows[r].outputs[Object.keys(tt.rows[r].outputs)[0]]) !== 1) continue;
      var parts = [];
      for (var i = 0; i < tt.rows[r].inputs.length; i++) {
        parts.push(tt.rows[r].inputs[i] === 1 ? tt.inputs[i] : "¬" + tt.inputs[i]);
      }
      terms.push(parts.join(" · "));
    }
    return terms.length ? terms.join(" + ") : "0";
  }

  global.MzansiLabEngines = {
    MAX_ITERATIONS: MAX_ITERATIONS,
    GRID: GRID,
    GATE_W: GATE_W,
    GATE_H: GATE_H,
    evaluateGate: evaluateGate,
    pinCount: pinCount,
    sizeOf: sizeOf,
    pinsFor: pinsFor,
    snap: snap,
    wirePath: wirePath,
    simulate: simulate,
    analyzeTruthTable: analyzeTruthTable,
    vectorsEqual: vectorsEqual,
    packOutputColumn: packOutputColumn,
    countGates: countGates,
    gateKindsUsed: gateKindsUsed,
    sopFromTable: sopFromTable,
  };
})(typeof window !== "undefined" ? window : this);
