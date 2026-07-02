/* ========================================================================
   deck-kit — Shared behaviour
   - Detect ?presenter → enable presenter mode + progress bar
   - Keyboard nav: ArrowRight/Space = next, ArrowLeft = prev, Esc = index
   - Inject prev/next/index buttons (unless disabled)
   - Slide order hardcoded here — must match filenames

   NOTE: in slides include as <script src="shared.js" defer></script>
         but in index.html include WITHOUT defer — index's inline script
         reads window.WORKSHOP_SLIDES at parse time, so shared.js must
         execute first (defer would reorder it after).

   The SLIDES array below is populated incrementally by the
   deck-build skill as each slide is generated. Keep in sync with
   actual filenames in the output directory; mismatch breaks navigation.
   ======================================================================== */

(function () {
  "use strict";

  var SLIDES = [
    { file: "01-cover.html",          title: "Test-Driven Refactoring" },
    { file: "02-quote.html",          title: "Code for Humans" },
    { file: "03-concept.html",        title: "The Refactoring Safety Net" },
    { file: "04-phase-1.html",        title: "Phase 1 · Pin Current Behaviour" },
    { file: "05-demo-1-tests.html",   title: "Demo · Pinning Behaviour, Red to Green" },
    { file: "06-refactor-flow.html",  title: "The Refactor Loop" },
    { file: "07-gate-review.html",    title: "Gate · Ready to Ship?" },
    { file: "08-closing.html",        title: "Refactor with a Net" },
  ];

  // Expose for use by index.html
  window.WORKSHOP_SLIDES = SLIDES;

  // ----- Helpers -----

  function currentFilename() {
    var path = window.location.pathname;
    var file = path.substring(path.lastIndexOf("/") + 1);
    return file || "index.html";
  }

  function currentIndex() {
    var file = currentFilename();
    for (var i = 0; i < SLIDES.length; i++) {
      if (SLIDES[i].file === file) return i;
    }
    return -1;
  }

  function isPresenter() {
    return window.location.search.indexOf("presenter") !== -1;
  }

  function withSearch(href) {
    return isPresenter() ? href + "?presenter" : href;
  }

  // ----- Init -----

  function init() {
    var idx = currentIndex();
    var isSlide = idx !== -1;

    if (isPresenter()) {
      document.body.classList.add("presenter");
      if (isSlide) {
        renderProgress(idx);
      }
    }

    if (isSlide && !document.body.hasAttribute("data-nav-disabled")) {
      renderNavigation(idx);
    }

    bindKeyboard(idx);
  }

  // ----- Progress bar -----

  function renderProgress(idx) {
    var pct = ((idx + 1) / SLIDES.length) * 100;

    var bar = document.createElement("div");
    bar.className = "progress-bar";
    bar.style.width = pct.toFixed(2) + "%";
    document.body.appendChild(bar);

    var label = document.createElement("div");
    label.className = "progress-label";
    label.textContent = (idx + 1) + " / " + SLIDES.length;
    document.body.appendChild(label);
  }

  // ----- Prev / Next / Index links -----

  function renderNavigation(idx) {
    var prev = document.createElement("a");
    prev.className = "nav-btn nav-prev";
    prev.textContent = "\u2190"; // left arrow
    prev.setAttribute("aria-label", "Previous slide");
    if (idx > 0) {
      prev.href = withSearch(SLIDES[idx - 1].file);
      prev.title = "\u2190 " + SLIDES[idx - 1].title;
    } else {
      prev.setAttribute("disabled", "");
      prev.removeAttribute("href");
    }
    document.body.appendChild(prev);

    var next = document.createElement("a");
    next.className = "nav-btn nav-next";
    next.textContent = "\u2192"; // right arrow
    next.setAttribute("aria-label", "Next slide");
    if (idx < SLIDES.length - 1) {
      next.href = withSearch(SLIDES[idx + 1].file);
      next.title = SLIDES[idx + 1].title + " \u2192";
    } else {
      next.setAttribute("disabled", "");
      next.removeAttribute("href");
    }
    document.body.appendChild(next);

    var index = document.createElement("a");
    index.className = "nav-index";
    index.textContent = "\u2630 INDEX";
    index.href = withSearch("index.html");
    index.setAttribute("aria-label", "Return to index");
    document.body.appendChild(index);
  }

  // ----- Keyboard -----

  function bindKeyboard(idx) {
    document.addEventListener("keydown", function (e) {
      var tag = (e.target && e.target.tagName) || "";
      if (tag === "INPUT" || tag === "TEXTAREA" || (e.target && e.target.isContentEditable)) {
        return;
      }

      if (e.key === "ArrowRight" || e.key === "PageDown" || e.key === " " || e.code === "Space") {
        if (idx !== -1 && idx < SLIDES.length - 1) {
          e.preventDefault();
          window.location.href = withSearch(SLIDES[idx + 1].file);
        }
        return;
      }

      if (e.key === "ArrowLeft" || e.key === "PageUp") {
        if (idx !== -1 && idx > 0) {
          e.preventDefault();
          window.location.href = withSearch(SLIDES[idx - 1].file);
        }
        return;
      }

      if (e.key === "Escape") {
        if (currentFilename() !== "index.html") {
          e.preventDefault();
          window.location.href = withSearch("index.html");
        }
        return;
      }

      if (e.key === "p" || e.key === "P") {
        var url = new URL(window.location.href);
        if (isPresenter()) {
          url.searchParams.delete("presenter");
        } else {
          url.searchParams.set("presenter", "");
        }
        window.location.href = url.toString().replace("presenter=", "presenter");
      }
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
