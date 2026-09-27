/* Mzansi Lab Ã¢â‚¬â€ CEF bench: palette, canvas editor, truth table, submit bridge */
(function () {
  "use strict";

  var E = window.MzansiLabEngines;
  var canvas = document.getElementById("bench");
  var ctx = canvas.getContext("2d");

  var state = {
    tool: "wire",
    paletteKind: "AND",
    challenges: [],
    activeId: null,
    active: null,
    gates: [],
    wires: [],
    nextGate: 1,
    wireFrom: null,
    drag: null,
    hover: null,
    inputToggles: {},
    lastTT: null,
  };

  var KIND_COLOR = {
    INPUT: "#2ea8ff", BUTTON: "#2ea8ff", CLOCK: "#2ea8ff",
    OUTPUT: "#ff9f2e", PROBE: "#ff9f2e",
    AND: "#3d8f5c", OR: "#3d8f5c", NAND: "#5c8f3d", NOR: "#5c8f3d",
    XOR: "#8f3d5c", XNOR: "#8f3d5c",
    NOT: "#8f7a3d", BUFFER: "#8f7a3d",
    CONST0: "#556", CONST1: "#556",
    HALFADDER: "#4ea1ff", FULLADDER: "#4ea1ff",
  };

  function $(id) { return document.getElementById(id); }

  function logLine(msg, cls) {
    var el = $("log");
    var d = document.createElement("div");
    if (cls) d.className = cls;
    d.textContent = "[" + new Date().toTimeString().slice(0, 8) + "] " + msg;
    el.appendChild(d);
    el.scrollTop = el.scrollHeight;
  }

  function showBanner(ok, msg) {
    var b = $("resultBanner");
    b.classList.remove("hidden", "ok", "fail");
    b.classList.add(ok ? "ok" : "fail");
    b.textContent = msg;
    setTimeout(function () { b.classList.add("hidden"); }, 6000);
  }

  function trigger(name, args) {
    if (typeof window.mta !== "undefined" && window.mta.triggerEvent) {
      window.mta.triggerEvent.apply(window.mta, [name].concat(args || []));
    } else {
      logLine("bridge missing: " + name, "fail");
    }
  }

  /* ---------- challenges / palette ---------- */

  function findChallenge(id) {
    for (var i = 0; i < state.challenges.length; i++) {
      if (state.challenges[i].id === id) return state.challenges[i];
    }
    return null;
  }

  function renderChallenges() {
    var ul = $("challengeList");
    ul.innerHTML = "";
    state.challenges.forEach(function (c) {
      var li = document.createElement("li");
      li.className = (c.id === state.activeId ? "active " : "") + (c.completed ? "done" : "");
      li.innerHTML =
        "<strong>" + escapeHtml(c.title) + "</strong>" +
        '<span class="sub">' + (c.completed ? "PASSED" : "open") +
        " Ã‚Â· R" + (c.payout || 0) +
        " Ã‚Â· job " + c.job + "</span>";
      li.addEventListener("click", function () { selectChallenge(c.id); });
      ul.appendChild(li);
    });
    renderPalette();
  }

  function renderPalette() {
    var box = $("gatePalette");
    box.innerHTML = "";
    var pal = (state.active && state.active.palette) || ["INPUT", "OUTPUT", "AND", "OR", "NOT"];
    pal.forEach(function (kind) {
      var d = document.createElement("div");
      d.className = "gchip" + (state.paletteKind === kind ? " sel" : "");
      d.textContent = kind;
      d.addEventListener("click", function () {
        state.paletteKind = kind;
        if (state.tool !== "move") setTool("wire");
        renderPalette();
        logLine("selected " + kind);
      });
      box.appendChild(d);
    });
    var brief = $("briefBox");
    if (state.active) {
      brief.textContent =
        state.active.title + "\n\n" + state.active.brief +
        "\n\nInputs: " + (state.active.inputs || []).join(", ") +
        "\nOutputs: " + (state.active.outputs || []).join(", ") +
        "\nGates: " + (state.active.min_gates || 1) + "Ã¢â‚¬â€œ" + (state.active.max_gates || 99) +
        "\n\nConcepts:\nÃ¢â‚¬Â¢ " + ((state.active.concepts || []).join("\nÃ¢â‚¬Â¢ ") || "Ã¢â‚¬â€");
      $("challpill").textContent = state.active.title;
    } else {
      brief.textContent = "Select a challenge.";
    }
  }

  function selectChallenge(id) {
    state.activeId = id;
    state.active = findChallenge(id);
    clearBench();
    // Seed input/output anchors so players can wire immediately
    if (state.active) {
      var ins = state.active.inputs || [];
      var outs = state.active.outputs || [];
      ins.forEach(function (name, i) {
        addGate("INPUT", 64, 96 + i * 96, name);
      });
      outs.forEach(function (name, i) {
        addGate("OUTPUT", 880, 160 + i * 96, name);
      });
      // INPUT toggles default 0
      state.inputToggles = {};
      ins.forEach(function (n) { state.inputToggles[n] = 0; });
    }
    renderChallenges();
    updateScorePill();
    livePreview();
    logLine("challenge: " + id);
  }

  function escapeHtml(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
    });
  }

  /* ---------- circuit ops ---------- */

  function addGate(kind, x, y, label) {
    var id = "g" + state.nextGate++;
    var g = {
      id: id,
      kind: kind,
      x: E.snap(x),
      y: E.snap(y),
      label: label || kind.charAt(0) + id.slice(1),
      on: kind === "INPUT" ? 0 : undefined,
    };
    if (kind === "INPUT" && label) state.inputToggles[label] = 0;
    state.gates.push(g);
    return g;
  }

  function gateById(id) {
    for (var i = 0; i < state.gates.length; i++) if (state.gates[i].id === id) return state.gates[i];
    return null;
  }

  function allPins() {
    var out = [];
    state.gates.forEach(function (g) {
      E.pinsFor(g).forEach(function (p) { out.push(p); });
    });
    return out;
  }

  function hitPin(x, y, sideFilter, tol) {
    tol = tol || 8;
    var pins = allPins();
    var best = null;
    var bd = tol;
    for (var i = 0; i < pins.length; i++) {
      if (sideFilter && pins[i].side !== sideFilter) continue;
      var d = Math.hypot(pins[i].x - x, pins[i].y - y);
      if (d <= bd) { bd = d; best = pins[i]; }
    }
    return best;
  }

  function hitGate(x, y) {
    for (var i = state.gates.length - 1; i >= 0; i--) {
      var g = state.gates[i];
      var sz = E.sizeOf(g.kind);
      if (x >= g.x && x <= g.x + sz.w && y >= g.y && y <= g.y + sz.h) return g;
    }
    return null;
  }

  function clearBench() {
    state.gates = [];
    state.wires = [];
    state.nextGate = 1;
    state.wireFrom = null;
    state.drag = null;
    state.lastTT = null;
    $("truthWrap").innerHTML = "<em>Hit TRUTH or VALIDATE</em>";
    $("liveOutputs").innerHTML = "";
    draw();
  }

  function autoLayout() {
    // Column place INPUTs left, OUTPUTs right, logic middle Ã¢â‚¬â€ snap 32
    var ins = [], mids = [], outs = [];
    state.gates.forEach(function (g) {
      if (g.kind === "INPUT") ins.push(g);
      else if (g.kind === "OUTPUT") outs.push(g);
      else mids.push(g);
    });
    ins.forEach(function (g, i) { g.x = E.snap(64); g.y = E.snap(80 + i * 96); });
    mids.forEach(function (g, i) {
      var col = Math.floor(i / 3);
      var row = i % 3;
      g.x = E.snap(320 + col * 96);
      g.y = E.snap(96 + row * 112);
    });
    outs.forEach(function (g, i) { g.x = E.snap(864); g.y = E.snap(144 + i * 96); });
    draw();
    logLine("auto layout applied");
  }

  function currentCircuit() {
    // apply INPUT toggle state onto gates for serialize
    state.gates.forEach(function (g) {
      if (g.kind === "INPUT" && g.label && state.inputToggles[g.label] !== undefined) {
        g.on = state.inputToggles[g.label];
      }
    });
    return {
      gates: state.gates.map(function (g) {
        var o = { id: g.id, kind: g.kind, x: g.x, y: g.y, label: g.label };
        if (g.kind === "INPUT") o.on = g.on ? 1 : 0;
        return o;
      }),
      wires: state.wires.map(function (w) {
        return { from: w.from, fromPin: w.fromPin, to: w.to, toPin: w.toPin };
      }),
    };
  }

  /* ---------- validation / truth ---------- */

  function localValidate() {
    if (!state.active) {
      showBanner(false, "Select a challenge first.");
      return null;
    }
    var circuit = currentCircuit();
    var used = E.gateKindsUsed(circuit);
    var allowed = {};
    (state.active.palette || []).forEach(function (k) { allowed[k] = true; });
    for (var kind in used) {
      if (!allowed[kind]) {
        showBanner(false, "Gate not allowed: " + kind);
        logLine("palette reject: " + kind, "fail");
        return null;
      }
    }
    var gc = E.countGates(circuit);
    if (gc < (state.active.min_gates || 1)) {
      showBanner(false, "Too few gates (min " + state.active.min_gates + ")");
      return null;
    }
    if (gc > (state.active.max_gates || 99)) {
      showBanner(false, "Too many gates (max " + state.active.max_gates + ")");
      return null;
    }

    var inLabels = {};
    state.gates.forEach(function (g) {
      if (g.kind === "INPUT") inLabels[g.label || g.id] = true;
    });
    var missing = (state.active.inputs || []).filter(function (n) { return !inLabels[n]; });
    if (missing.length) {
      showBanner(false, "Missing input: " + missing.join(", "));
      return null;
    }

    var tt = E.analyzeTruthTable(circuit, state.active.inputs, state.active.outputs);
    if (tt.error) {
      showBanner(false, tt.error);
      return null;
    }

    var golden = state.active.golden;
    var ok = true;
    var reason = "";
    if (golden && typeof golden[0] !== "undefined") {
      var col = E.packOutputColumn(tt.rows, state.active.outputs[0]);
      ok = E.vectorsEqual(col, golden);
      if (!ok) reason = "truth table mismatch on " + state.active.outputs[0];
    } else if (golden && typeof golden === "object") {
      Object.keys(golden).forEach(function (oname) {
        if (!ok) return;
        var col = E.packOutputColumn(tt.rows, oname);
        if (!E.vectorsEqual(col, golden[oname])) {
          ok = false;
          reason = "truth table mismatch on " + oname;
        }
      });
    } else {
      // formula challenges validated server-side; still surface rows
      reason = "server formula check";
    }

    for (var r = 0; r < tt.rows.length; r++) {
      if (tt.rows[r].oscillating) {
        ok = false;
        reason = "row " + (r + 1) + " oscillates";
        break;
      }
      var okeys = Object.keys(tt.rows[r].outputs);
      for (var k = 0; k < okeys.length; k++) {
        if (tt.rows[r].outputs[okeys[k]] === "X") {
          ok = false;
          reason = "floating output row " + (r + 1);
          break;
        }
      }
      if (!ok) break;
    }

    state.lastTT = tt;
    renderTruth(tt);
    livePreview();

    if (!state.active.golden_formula && !ok) {
      showBanner(false, reason || "validation failed");
      return null;
    }
    if (!state.active.golden_formula && ok) {
      showBanner(true, "Local validation PASS Ã¢â‚¬â€ submittingÃ¢â‚¬Â¦");
    }
    return { circuit: circuit, tt: tt };
  }

  function renderTruth(tt) {
    var wrap = $("truthWrap");
    var ins = tt.inputs;
    var outs = [];
    if (state.active && state.active.outputs) outs = state.active.outputs;
    if (!outs.length) {
      outs = Object.keys(tt.rows[0] ? tt.rows[0].outputs : {});
    }
    var html = "<table><tr>";
    ins.forEach(function (n) { html += "<th>" + escapeHtml(n) + "</th>"; });
    outs.forEach(function (n) { html += "<th>" + escapeHtml(n) + "</th>"; });
    html += "</tr>";
    tt.rows.forEach(function (row) {
      html += "<tr>";
      row.inputs.forEach(function (b) { html += "<td>" + b + "</td>"; });
      outs.forEach(function (n) {
        var v = row.outputs[n];
        html += "<td>" + (v === "X" || v === undefined ? "X" : v) + "</td>";
      });
      html += "</tr>";
    });
    html += "</table>";
    if (state.active && state.active.inputs && state.active.inputs.length <= 4) {
      try {
        var sop = E.sopFromTable(tt);
        html += '<div style="margin-top:6px;color:#c8aa32;font-family:Consolas">SOP: ' + escapeHtml(sop) + "</div>";
      } catch (e) { /* ignore */ }
    }
    wrap.innerHTML = html;
  }

  function livePreview() {
    var circuit = currentCircuit();
    // Drive INPUTs from toggles
    var assign = {};
    Object.keys(state.inputToggles).forEach(function (k) { assign[k] = state.inputToggles[k]; });
    var sim = E.simulate(circuit, assign);
    var box = $("liveOutputs");
    box.innerHTML = "";
    var keys = Object.keys(sim.outputs).sort();
    if (!keys.length) {
      box.innerHTML = '<div class="oline"><span>Y</span><span class="vx">Ã¢â‚¬â€</span></div>';
    }
    keys.forEach(function (k) {
      var v = sim.outputs[k];
      var cls = v === 1 ? "v1" : (v === 0 ? "v0" : "vx");
      var row = document.createElement("div");
      row.className = "oline";
      row.innerHTML = "<span>" + escapeHtml(k) + '</span><span class="' + cls + '">' + v + "</span>";
      box.appendChild(row);
    });
    updateScorePill();
    draw();
  }

  function updateScorePill() {
    $("scorepill").textContent = E.countGates(currentCircuit()) + " gates Ã‚Â· " +
      state.wires.length + " wires";
  }

  /* ---------- draw ---------- */

  function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // wires
    state.wires.forEach(function (w) {
      var g1 = gateById(w.from);
      var g2 = gateById(w.to);
      if (!g1 || !g2) return;
      var p1 = E.pinsFor(g1).filter(function (p) { return p.side === "out" && p.index === (w.fromPin || 0); })[0];
      var p2 = E.pinsFor(g2).filter(function (p) { return p.side === "in" && p.index === (w.toPin || 0); })[0];
      if (!p1 || !p2) return;
      var pts = E.wirePath(p1.x, p1.y, p2.x, p2.y);
      ctx.beginPath();
      ctx.strokeStyle = KIND_COLOR[w.hover] || "#4ea1ff";
      ctx.lineWidth = 2;
      ctx.moveTo(pts[0].x, pts[0].y);
      for (var i = 1; i < pts.length; i++) ctx.lineTo(pts[i].x, pts[i].y);
      ctx.stroke();
      // value color if known (outKey: id:out:pin)
      var sim = window.__labSim || null;
      if (sim && sim.pinValues && sim.pinValues[w.from + ":out:" + (w.fromPin || 0)] !== undefined) {
        var v = sim.pinValues[w.from + ":out:" + (w.fromPin || 0)];
        ctx.fillStyle = v === 1 ? "#00cc66" : (v === 0 ? "#556677" : "#ff5555");
        var mx = (pts[1].x + pts[2].x) / 2;
        var my = (pts[1].y + pts[2].y) / 2;
        ctx.fillRect(mx - 3, my - 3, 6, 6);
      }
    });

    // in-progress wire
    if (state.wireFrom && state.mouse) {
      var gf = gateById(state.wireFrom.gateId);
      if (gf) {
        var pf = E.pinsFor(gf).filter(function (p) {
          return p.side === state.wireFrom.side && p.index === state.wireFrom.index;
        })[0];
        if (pf) {
          ctx.beginPath();
          ctx.strokeStyle = "#c8aa32";
          ctx.setLineDash([6, 4]);
          ctx.moveTo(pf.x, pf.y);
          ctx.lineTo(state.mouse.x, state.mouse.y);
          ctx.stroke();
          ctx.setLineDash([]);
        }
      }
    }

    // gates
    state.gates.forEach(function (g) {
      var sz = E.sizeOf(g.kind);
      var fill = "#132134";
      var stroke = KIND_COLOR[g.kind] || "#4ea1ff";
      if (state.hover === g.id || (state.drag && state.drag.id === g.id)) stroke = "#c8aa32";
      ctx.fillStyle = fill;
      ctx.strokeStyle = stroke;
      ctx.lineWidth = 2;
      roundRect(g.x, g.y, sz.w, sz.h, 6);
      ctx.fill();
      ctx.stroke();

      ctx.fillStyle = "#d7e0ea";
      ctx.font = "11px Segoe UI, sans-serif";
      ctx.textAlign = "center";
      ctx.textBaseline = "middle";
      var label = g.kind;
      if (g.kind === "INPUT" || g.kind === "OUTPUT") label = (g.label || g.kind);
      ctx.fillText(label, g.x + sz.w / 2, g.y + sz.h / 2 - (g.kind === "INPUT" ? 8 : 0));

      if (g.kind === "INPUT") {
        var val = state.inputToggles[g.label] || 0;
        ctx.fillStyle = val ? "#00cc66" : "#556677";
        ctx.font = "bold 12px Consolas, monospace";
        ctx.fillText(String(val), g.x + sz.w / 2, g.y + sz.h / 2 + 10);
      } else if (g.kind === "CONST1") {
        ctx.fillStyle = "#00cc66";
        ctx.fillText("1", g.x + sz.w / 2, g.y + sz.h / 2 + 12);
      } else if (g.kind === "CONST0") {
        ctx.fillStyle = "#556677";
        ctx.fillText("0", g.x + sz.w / 2, g.y + sz.h / 2 + 12);
      }

      // pins
      E.pinsFor(g).forEach(function (p) {
        ctx.beginPath();
        ctx.fillStyle = p.side === "out" ? "#4ea1ff" : "#ff9f2e";
        ctx.arc(p.x, p.y, 4, 0, Math.PI * 2);
        ctx.fill();
      });

      // type mini
      ctx.fillStyle = "rgba(137,153,170,.7)";
      ctx.font = "9px Segoe UI";
      ctx.textAlign = "left";
      ctx.fillText(g.kind, g.x + 4, g.y + 8);
    });
  }


  function roundRect(x, y, w, h, r) {
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.arcTo(x + w, y, x + w, y + h, r);
    ctx.arcTo(x + w, y + h, x, y + h, r);
    ctx.arcTo(x, y + h, x, y, r);
    ctx.arcTo(x, y, x + w, y, r);
    ctx.closePath();
  }

  function canvasPos(ev) {
    var rect = canvas.getBoundingClientRect();
    var sx = canvas.width / rect.width;
    var sy = canvas.height / rect.height;
    return {
      x: (ev.clientX - rect.left) * sx,
      y: (ev.clientY - rect.top) * sy,
    };
  }

  /* ---------- mouse ---------- */

  canvas.addEventListener("mousemove", function (ev) {
    var p = canvasPos(ev);
    state.mouse = p;
    if (state.drag) {
      state.drag.gx = E.snap(p.x - state.drag.ox);
      state.drag.gy = E.snap(p.y - state.drag.oy);
      var g = gateById(state.drag.id);
      if (g) { g.x = state.drag.gx; g.y = state.drag.gy; }
      draw();
      return;
    }
    var g = hitGate(p.x, p.y);
    state.hover = g ? g.id : null;
    draw();
  });

    canvas.addEventListener("mousedown", function (ev) {
    var p = canvasPos(ev);
    if (ev.button === 2) {
      state.wireFrom = null;
      draw();
      return;
    }

    if (state.tool === "delete") {
      var gd = hitGate(p.x, p.y);
      if (gd) {
        state.wires = state.wires.filter(function (w) {
          return w.from !== gd.id && w.to !== gd.id;
        });
        state.gates = state.gates.filter(function (x) { return x.id !== gd.id; });
        if (gd.label && state.inputToggles[gd.label] !== undefined) delete state.inputToggles[gd.label];
        logLine("deleted " + gd.id);
        livePreview();
      }
      return;
    }

    var pin = hitPin(p.x, p.y, null, 10);

    if (pin && pin.side === "out") {
      state.wireFrom = pin;
      setActiveTool("wire");
      draw();
      return;
    }

    if (pin && pin.side === "in" && state.wireFrom) {
      var fromG = gateById(state.wireFrom.gateId);
      if (fromG && fromG.id !== pin.gateId) {
        state.wires = state.wires.filter(function (w) {
          return !(w.to === pin.gateId && (w.toPin || 0) === pin.index);
        });
        state.wires.push({
          from: state.wireFrom.gateId,
          fromPin: state.wireFrom.index,
          to: pin.gateId,
          toPin: pin.index,
        });
        logLine("wire " + state.wireFrom.gateId + " -> " + pin.gateId);
      }
      state.wireFrom = null;
      livePreview();
      return;
    }

    var g = hitGate(p.x, p.y);
    if (!g && !state.wireFrom) {
      var want = state.paletteKind;
      if (want) {
        var ng = addGate(want, p.x - 36, p.y - 24,
          want === "INPUT" || want === "OUTPUT" ? autoLabel(want) : undefined);
        logLine("add " + want + " " + ng.id);
        livePreview();
      }
      return;
    }

    if (g) {
      state.drag = {
        id: g.id,
        ox: p.x - g.x,
        oy: p.y - g.y,
        startX: p.x,
        startY: p.y,
        sawMove: false,
      };
      draw();
    }
  });

  window.addEventListener("mouseup", function () {
    if (!state.drag) return;
    var d = state.drag;
    state.drag = null;
    var g = gateById(d.id);
    if (!g) { livePreview(); return; }

    if (!d.sawMove) {
      if (g.kind === "INPUT") {
        var name = g.label || g.id;
        state.inputToggles[name] = state.inputToggles[name] ? 0 : 1;
        g.on = state.inputToggles[name];
        logLine("toggle " + name + " -> " + state.inputToggles[name]);
        livePreview();
        return;
      }
      if (g.kind === "BUTTON") {
        g.on = g.on ? 0 : 1;
        livePreview();
        return;
      }
    }
    livePreview();
  });

  canvas.addEventListener("contextmenu", function (ev) {
    ev.preventDefault();
    state.wireFrom = null;
    draw();
  });

  canvas.addEventListener("dblclick", function (ev) {
    var p = canvasPos(ev);
    var g = hitGate(p.x, p.y);
    if (g && (g.kind === "INPUT" || g.kind === "OUTPUT")) {
      var name = prompt("Label for " + g.kind, g.label || "");
      if (name) {
        g.label = name;
        if (g.kind === "INPUT" && state.inputToggles[name] === undefined) {
          state.inputToggles[name] = 0;
        }
        livePreview();
      }
    }
  });

  function autoLabel(kind) {
    var n = 1;
    var prefix = kind === "OUTPUT" ? "Y" : "I";
    var used = {};
    state.gates.forEach(function (g) { if (g.label) used[g.label] = true; });
    while (used[prefix + n]) n++;
    return prefix + n;
  }

  /* ---------- tools / buttons ---------- */

  function setActiveTool(t) {
    state.tool = t;
    document.querySelectorAll(".tool[data-tool]").forEach(function (b) {
      b.classList.toggle("active", b.getAttribute("data-tool") === t);
    });
  }

  $("btnWire").addEventListener("click", function () { setActiveTool("wire"); });
  $("btnMove").addEventListener("click", function () { setActiveTool("move"); });
  $("btnDelete").addEventListener("click", function () { setActiveTool("delete"); });
  $("btnClear").addEventListener("click", function () {
    if (confirm("Clear entire bench?")) {
      clearBench();
      selectChallenge(state.activeId);
    }
  });
  $("btnAutoLayout").addEventListener("click", autoLayout);

  $("btnValidate").addEventListener("click", function () {
    var r = localValidate();
    if (r) {
      showBanner(true, "Local PASS (" + E.countGates(r.circuit) + " gates). Submit to finish.");
      logLine("local validate pass", "ok");
    } else {
      logLine("local validate fail", "fail");
    }
  });

  $("btnTruth").addEventListener("click", function () {
    var circuit = currentCircuit();
    var tt = E.analyzeTruthTable(circuit,
      (state.active && state.active.inputs) || undefined,
      (state.active && state.active.outputs) || undefined);
    if (tt.error) {
      showBanner(false, tt.error);
      return;
    }
    state.lastTT = tt;
    renderTruth(tt);
    logLine("truth table: " + tt.rows.length + " rows");
  });

  $("btnSubmit").addEventListener("click", function () {
    if (!state.activeId) {
      showBanner(false, "Select a challenge.");
      return;
    }
    var circuit = currentCircuit();
    // Always ship circuit to server; server is source of truth for formula challenges
    trigger("mzansi:lab:submitCef", [state.activeId, circuit]);
    logLine("submitted " + state.activeId);
  });

  $("btnClose").addEventListener("click", function () {
    trigger("mzansi:lab:closeCef", []);
  });

  $("btnNum").addEventListener("click", function () {
    var raw = $("numIn").value.trim();
    var base = $("numBase").value;
    var n;
    try {
      if (base === "dec") n = parseInt(raw, 10);
      else if (base === "hex") n = parseInt(raw.replace(/^0x/i, ""), 16);
      else if (base === "bin") n = parseInt(raw.replace(/^0b/i, ""), 2);
      else n = parseInt(raw, 8);
      if (isNaN(n)) throw new Error("bad");
      var neg = n < 0;
      var abs = Math.abs(n);
      $("numOut").innerHTML =
        "DEC: " + n + "<br/>HEX: 0x" + abs.toString(16).toUpperCase() +
        "<br/>BIN: " + abs.toString(2) +
        "<br/>OCT: 0" + abs.toString(8) +
        (neg ? "<br/>NEG: Ã¢Ë†â€™" + abs : "");
    } catch (e) {
      $("numOut").textContent = "Invalid number";
    }
  });

  /* ---------- MTA bridge handlers (window.__*) ---------- */

  window.__setChallenges = function (list) {
    state.challenges = list || [];
    if (!state.activeId && state.challenges.length) {
      selectChallenge(state.challenges[0].id);
    } else {
      // refresh completed flags
      if (state.activeId) {
        var again = findChallenge(state.activeId);
        if (again) state.active = again;
      }
      renderChallenges();
    }
    logLine("challenges loaded: " + state.challenges.length, "ok");
  };

  window.__setResult = function (ok, message, challengeId) {
    showBanner(!!ok, message);
    logLine(message, ok ? "ok" : "fail");
    if (ok && challengeId) {
      trigger("mzansi:lab:listCef", []);
    }
  };

  window.__draftSaved = function () {
    logLine("draft saved", "ok");
  };

  /* ---------- number systems + live sim tick ---------- */

  function tickSim() {
    try {
      var circuit = currentCircuit();
      var assign = {};
      Object.keys(state.inputToggles).forEach(function (k) { assign[k] = state.inputToggles[k]; });
      window.__labSim = E.simulate(circuit, assign);
      if (state.tool === "wire" || state.wires.length) draw();
    } catch (e) { /* ignore */ }
    setTimeout(tickSim, 400);
  }

  /* ---------- init ---------- */

  function init() {
    logLine("bench boot Ã¢â‚¬â€ ASCADS engines online");
    setActiveTool("wire");
    trigger("mzansi:lab:listCef", []);
    draw();
    tickSim();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
