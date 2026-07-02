/* ========================================================================
   Demo terminal runner — shared helpers.
   Each demo-N file builds a `steps` array and calls `runDemo({ command, steps })`.
   Expects DOM:
     <div class="terminal">
       <div class="terminal-titlebar">...</div>
       <div class="terminal-body" id="body"></div>
       <div class="run-overlay" id="overlay">
         <button class="run-btn" id="run">▶ RUN</button>
         <div class="run-hint">Press to run the demo</div>
       </div>
       <button class="reset-btn" id="reset">↻ RESET</button>
     </div>
   ======================================================================== */

(function (global) {
  "use strict";

  function sleep(ms) { return new Promise(function (r) { setTimeout(r, ms); }); }

  function el(tag, cls, text) {
    var node = document.createElement(tag);
    if (cls)  node.className = cls;
    if (text !== undefined) node.textContent = text;
    return node;
  }

  function scrollToBottom(body) {
    body.scrollTop = body.scrollHeight;
  }

  async function typewriter(target, text, speed) {
    speed = speed || 35;
    for (var i = 0; i < text.length; i++) {
      target.appendChild(document.createTextNode(text[i]));
      if (text[i] !== " ") {
        await sleep(speed + (Math.random() * 12 - 6));
      }
    }
  }

  /*
    step := {
      type: "line" | "blank" | "pause" | "progress" | "multi",
      class?: string,     // css class for the line (for types line/multi)
      text?: string,      // text content (for line)
      delayBefore?: ms,
      typewrite?: boolean,// if true, text is typed char by char
      lines?: [{class, text}],  // for multi
      pct?: number,       // for progress final pct (0..100)
      label?: string,     // for progress label
      duration?: ms       // for progress animation time
    }
  */
  async function renderStep(body, step) {
    if (step.delayBefore) await sleep(step.delayBefore);

    if (step.type === "blank") {
      var br = el("div");
      br.innerHTML = "&nbsp;";
      body.appendChild(br);
      scrollToBottom(body);
      return;
    }

    if (step.type === "pause") {
      await sleep(step.duration || 400);
      return;
    }

    if (step.type === "line") {
      var line = el("div", step.class || "");
      body.appendChild(line);
      if (step.typewrite) {
        await typewriter(line, step.text || "", step.speed);
      } else {
        line.textContent = step.text || "";
      }
      scrollToBottom(body);
      return;
    }

    if (step.type === "multi") {
      var lines = step.lines || [];
      for (var i = 0; i < lines.length; i++) {
        var l = el("div", lines[i].class || "");
        l.innerHTML = lines[i].text || "";
        body.appendChild(l);
        scrollToBottom(body);
        if (i < lines.length - 1) await sleep(step.gap || 45);
      }
      return;
    }

    if (step.type === "progress") {
      var row = el("div", "progress-row");
      row.style.cssText = "display: flex; align-items: center; gap: 10px; margin: 4px 0;";

      var labelSpan = el("span", "terminal-muted");
      labelSpan.textContent = step.label || "progress";
      labelSpan.style.cssText = "min-width: 180px; display: inline-block;";

      var bar = el("span", "progress-inline");
      var fill = el("span", "fill");
      bar.appendChild(fill);

      var pctLabel = el("span", "terminal-ok");
      pctLabel.textContent = "  0%";
      pctLabel.style.cssText = "min-width: 52px;";

      row.appendChild(labelSpan);
      row.appendChild(bar);
      row.appendChild(pctLabel);
      body.appendChild(row);
      scrollToBottom(body);

      var finalPct = step.pct === undefined ? 100 : step.pct;
      var duration = step.duration || 1200;
      var frames = Math.max(6, Math.floor(duration / 80));
      var step_pct = finalPct / frames;
      var current = 0;
      for (var j = 0; j < frames; j++) {
        current = Math.min(finalPct, current + step_pct);
        fill.style.width = current.toFixed(1) + "%";
        pctLabel.textContent = (" " + Math.round(current)).slice(-3) + "%";
        await sleep(duration / frames);
      }

      if (step.doneLabel) {
        pctLabel.textContent = step.doneLabel;
        pctLabel.className = "terminal-ok";
      }

      return;
    }

    if (step.type === "raw") {
      var wrap = el("div", step.class || "");
      wrap.innerHTML = step.html || "";
      body.appendChild(wrap);
      scrollToBottom(body);
      return;
    }
  }

  async function runDemo(config) {
    var body    = document.getElementById("body");
    var overlay = document.getElementById("overlay");
    var resetBtn= document.getElementById("reset");

    body.innerHTML = "";
    if (overlay) overlay.style.display = "none";
    if (resetBtn) resetBtn.classList.remove("visible");

    // 1. Prompt line with typed command
    var line = el("div");
    var prompt = el("span", "terminal-prompt");
    prompt.textContent = config.prompt || "claude>";
    var space = document.createTextNode(" ");
    var cmdSpan = el("span", "terminal-command");
    line.appendChild(prompt);
    line.appendChild(space);
    line.appendChild(cmdSpan);
    body.appendChild(line);

    await sleep(300);
    await typewriter(cmdSpan, config.command || "", config.commandSpeed || 60);

    // blinking cursor briefly
    var cursor = el("span", "terminal-cursor");
    line.appendChild(cursor);
    await sleep(550);
    cursor.remove();

    // blank line after command
    body.appendChild(el("div"));

    // 2. Iterate steps
    var steps = config.steps || [];
    for (var i = 0; i < steps.length; i++) {
      await renderStep(body, steps[i]);
    }

    if (resetBtn) resetBtn.classList.add("visible");
  }

  function initDemo(config) {
    var runBtn  = document.getElementById("run");
    var resetBtn= document.getElementById("reset");
    var overlay = document.getElementById("overlay");

    function start() { runDemo(config); }
    function reset() {
      if (overlay) overlay.style.display = "";
      if (resetBtn) resetBtn.classList.remove("visible");
      document.getElementById("body").innerHTML = "";
    }

    if (runBtn)   runBtn.addEventListener("click", start);
    if (resetBtn) resetBtn.addEventListener("click", reset);
  }

  global.DemoRunner = {
    init: initDemo,
    run: runDemo,
    sleep: sleep
  };
})(window);
