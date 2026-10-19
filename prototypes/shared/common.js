// Shared mock data + behaviour for the UI prototypes.
// Everything here is fake: nothing is persisted, it only makes the mockups feel alive.

(function () {
  // ---------- Mock data (mirrors lib/models/sleep_session.dart + optional tags) ----------
  const NOTES = {
    0: 'Woke once around 3am, fell back asleep quickly.',
    1: 'Late coffee. Took a while to drift off.',
    3: 'Best sleep in weeks — cool room, no phone.',
    4: 'Neighbour’s dog barking at 5.',
    6: 'Read for 20 min before bed.',
    9: 'Travel day, slept on the late side.',
    12: 'Vivid dreams.',
    15: 'Headache in the morning.',
    20: 'Weekend lie-in.',
  };
  const TAG_POOL = ['Caffeine', 'Exercise', 'Screens late', 'Alcohol', 'Stress', 'Nap', 'Reading'];

  function seeded(seed) {
    return () => (seed = (seed * 16807) % 2147483647) / 2147483647;
  }

  function generate() {
    const rnd = seeded(42);
    const out = [];
    for (let i = 0; i < 30; i++) {
      const night = new Date(2026, 9, 18 - i);
      const bed = new Date(2026, 9, 18 - i, 0, 0);
      bed.setMinutes(22 * 60 + 10 + Math.round(rnd() * 160));
      const dur = 330 + Math.round(rnd() * 205);
      const wake = new Date(bed.getTime() + dur * 60000);
      let q = Math.round((dur - 300) / 55 + rnd() * 1.4);
      q = rnd() < 0.2 ? null : Math.max(1, Math.min(5, q));
      const tags = TAG_POOL.filter(() => rnd() < 0.14);
      out.push({ id: 30 - i, night, bed, wake, dur, quality: q, notes: NOTES[i] || '', tags });
    }
    return out;
  }

  const sessions = generate();
  const byId = (id) => sessions.find((s) => s.id === Number(id));

  // ---------- Formatting ----------
  const fmtDur = (m) => {
    m = Math.max(0, Math.round(m));
    if (m < 60) return m + 'm';
    const h = Math.floor(m / 60), r = m % 60;
    return r ? `${h}h ${r}m` : `${h}h`;
  };
  const fmtHours = (m) => (m / 60).toFixed(1);
  const fmtClock = (d) => d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
  const fmtDay = (d) => d.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' });
  const fmtDow = (d) => d.toLocaleDateString('en-US', { weekday: 'short' });
  const fmtLong = (d) => d.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' });
  const pad = (n) => String(n).padStart(2, '0');
  const toInput = (d) =>
    `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
  const timer = (ms) => {
    const s = Math.floor(ms / 1000);
    return `${pad(Math.floor(s / 3600))}:${pad(Math.floor((s % 3600) / 60))}:${pad(s % 60)}`;
  };
  // Minutes after 6pm, so 11pm and 1am average sensibly.
  const eveMin = (d) => ((d.getHours() + 6) % 24) * 60 + d.getMinutes();
  const fromEveMin = (m) => {
    const d = new Date(2026, 0, 1, 18, 0);
    d.setMinutes(Math.round(m));
    return d;
  };

  // ---------- Stats (matches the plan: avg / max / min / weekly / monthly / best) ----------
  function stats(list = sessions) {
    const avg = (a) => a.reduce((x, y) => x + y, 0) / (a.length || 1);
    const durs = list.map((s) => s.dur);
    const week = list.slice(0, 7), prev = list.slice(7, 14);
    // Times are measured in minutes after 6pm so 11pm and 1am average to midnight, not noon.
    const bedMins = list.map((s) => eveMin(s.bed));
    const meanBed = avg(bedMins);
    const sd = Math.sqrt(avg(bedMins.map((m) => (m - meanBed) ** 2)));
    const rated = list.filter((s) => s.quality);
    return {
      avg: avg(durs),
      longest: list.reduce((a, b) => (b.dur > a.dur ? b : a)),
      shortest: list.reduce((a, b) => (b.dur < a.dur ? b : a)),
      weekAvg: avg(week.map((s) => s.dur)),
      prevWeekAvg: avg(prev.map((s) => s.dur)),
      monthAvg: avg(durs),
      avgBed: fromEveMin(meanBed),
      avgWake: fromEveMin(avg(list.map((s) => eveMin(s.wake)))),
      consistency: Math.round(sd), // standard deviation of bedtime, in minutes
      avgQuality: avg(rated.map((s) => s.quality)),
      best: [...rated].sort((a, b) => b.quality - a.quality || b.dur - a.dur).slice(0, 3),
      goalHits: week.filter((s) => s.dur >= GOAL).length,
      count: list.length,
    };
  }
  const GOAL = 8 * 60;

  // ---------- Icons (inline stroke SVG) ----------
  const p = (d, extra = '') =>
    `<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" ${extra}>${d}</svg>`;
  const icons = {
    moon: p('<path d="M20 14.5A8 8 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5Z"/>'),
    sun: p('<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>'),
    star: p('<path d="m12 3 2.7 5.6 6.1.9-4.4 4.3 1 6.1L12 17l-5.4 2.9 1-6.1L3.2 9.5l6.1-.9Z"/>'),
    starFill: p('<path fill="currentColor" d="m12 3 2.7 5.6 6.1.9-4.4 4.3 1 6.1L12 17l-5.4 2.9 1-6.1L3.2 9.5l6.1-.9Z"/>'),
    edit: p('<path d="M4 20h4L19 9l-4-4L4 16v4Z"/><path d="m13.5 6.5 4 4"/>'),
    trash: p('<path d="M4 7h16M10 11v6M14 11v6M6 7l1 13h10l1-13M9 7V4h6v3"/>'),
    plus: p('<path d="M12 5v14M5 12h14"/>'),
    x: p('<path d="M6 6l12 12M18 6 6 18"/>'),
    home: p('<path d="M4 11 12 4l8 7v9h-5v-6H9v6H4Z"/>'),
    list: p('<path d="M8 6h12M8 12h12M8 18h12M4 6h.01M4 12h.01M4 18h.01"/>'),
    chart: p('<path d="M4 20V10M10 20V4M16 20v-7M22 20H2"/>'),
    book: p('<path d="M4 5a2 2 0 0 1 2-2h13v16H6a2 2 0 0 0-2 2Z"/><path d="M4 19V5"/>'),
    cal: p('<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/>'),
    clock: p('<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>'),
    tile: p('<rect x="3" y="3" width="8" height="8" rx="2"/><rect x="13" y="3" width="8" height="8" rx="2"/><rect x="3" y="13" width="8" height="8" rx="2"/><rect x="13" y="13" width="8" height="8" rx="2"/>'),
    gear: p('<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1Z"/>'),
    more: p('<circle cx="12" cy="5" r="1.2" fill="currentColor"/><circle cx="12" cy="12" r="1.2" fill="currentColor"/><circle cx="12" cy="19" r="1.2" fill="currentColor"/>'),
    info: p('<circle cx="12" cy="12" r="9"/><path d="M12 11v6M12 7.5v.01"/>'),
    back: p('<path d="M15 6l-6 6 6 6"/>'),
    up: p('<path d="M7 14l5-5 5 5"/>'),
    down: p('<path d="M7 10l5 5 5-5"/>'),
    note: p('<path d="M5 4h14v12l-4 4H5Z"/><path d="M15 20v-4h4M9 9h6M9 13h4"/>'),
  };
  const stars = (q, size = 14) =>
    Array.from({ length: 5 }, (_, i) =>
      `<span class="st ${q && i < q ? 'on' : ''}" style="display:inline-flex;width:${size}px;height:${size}px">${(q && i < q ? icons.starFill : icons.star).replace(/width="20" height="20"/, `width="${size}" height="${size}"`)}</span>`
    ).join('');

  // ---------- Theme toggle ----------
  function initTheme() {
    let saved = null;
    try { saved = localStorage.getItem('st-proto-theme'); } catch (e) {}
    const prefersDark = window.matchMedia && matchMedia('(prefers-color-scheme: dark)').matches;
    setTheme(saved || (prefersDark ? 'dark' : 'light'));
    document.addEventListener('click', (e) => {
      const btn = e.target.closest('[data-theme-toggle]');
      if (!btn) return;
      setTheme(document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark');
    });
  }
  function setTheme(t) {
    document.documentElement.dataset.theme = t;
    try { localStorage.setItem('st-proto-theme', t); } catch (e) {}
    document.querySelectorAll('[data-theme-toggle]').forEach((b) => {
      b.innerHTML = t === 'dark' ? icons.sun : icons.moon;
      b.setAttribute('aria-label', t === 'dark' ? 'Switch to light theme' : 'Switch to dark theme');
    });
  }

  // ---------- Tabs ----------
  function initTabs() {
    document.addEventListener('click', (e) => {
      const t = e.target.closest('[data-tab]');
      if (!t) return;
      showTab(t.dataset.tab);
    });
  }
  function showTab(name) {
    document.querySelectorAll('[data-tab]').forEach((b) => {
      b.classList.toggle('active', b.dataset.tab === name);
      b.setAttribute('aria-selected', b.dataset.tab === name);
    });
    document.querySelectorAll('[data-view]').forEach((v) => (v.hidden = v.dataset.view !== name));
    const scroller = document.querySelector('.scroll');
    if (scroller) scroller.scrollTop = 0;
  }

  // ---------- Sleep state (start/stop, live timer) ----------
  const tracker = { active: false, start: null, listeners: [] };
  function setSleeping(on, start) {
    tracker.active = on;
    tracker.start = on ? start || new Date() : null;
    document.body.classList.toggle('is-sleeping', on);
    document.querySelectorAll('[data-bed-label]').forEach((el) => (el.textContent = on ? fmtClock(tracker.start) : '—'));
    tick();
    if (!on) toast('Session saved · tap it to rate or add notes', 'Undo', () => setSleeping(true, lastStart));
    else lastStart = tracker.start;
    tracker.listeners.forEach((f) => f(on));
  }
  let lastStart = null;
  function tick() {
    const ms = tracker.active ? Date.now() - tracker.start : 0;
    document.querySelectorAll('[data-live-timer]').forEach((el) => (el.textContent = timer(ms)));
    document.querySelectorAll('[data-live-dur]').forEach((el) => (el.textContent = fmtDur(ms / 60000)));
  }
  function initSleep() {
    document.addEventListener('click', (e) => {
      if (e.target.closest('[data-sleep-toggle]')) setSleeping(!tracker.active);
    });
    setInterval(tick, 1000);
  }

  // ---------- Toast ----------
  let toastTimer;
  function toast(msg, action, onAction) {
    let el = document.getElementById('toast');
    if (!el) return;
    el.innerHTML = `<span>${msg}</span>${action ? `<button type="button">${action}</button>` : ''}`;
    el.classList.add('show');
    if (action) el.querySelector('button').onclick = () => { el.classList.remove('show'); onAction && onAction(); };
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => el.classList.remove('show'), 3800);
  }

  // ---------- Edit sheet (any session, any time — no artificial locks) ----------
  // Expects in the page: #sheet with #f-bed, #f-wake, #f-dur, #f-err, #f-notes, .star-input, .tag-input, [data-close-sheet], [data-save], [data-delete], #sheet-title
  let editing = null, draftQ = null;
  function openSheet(id) {
    const sheet = document.getElementById('sheet');
    if (!sheet) return;
    const s = id === 'new'
      ? { id: 'new', bed: new Date(2026, 9, 17, 23, 0), wake: new Date(2026, 9, 18, 7, 0), quality: null, notes: '', tags: [] }
      : id === 'active'
        ? { id: 'active', bed: tracker.start || new Date(), wake: null, quality: null, notes: '', tags: [] }
        : byId(id);
    if (!s) return;
    editing = s;
    draftQ = s.quality;
    sheet.querySelector('#sheet-title').textContent =
      s.id === 'new' ? 'Add a past night' : s.id === 'active' ? 'Current session' : fmtLong(window.Proto && Proto.dateOf ? Proto.dateOf(s) : s.night);
    sheet.querySelector('#f-bed').value = toInput(s.bed);
    const w = sheet.querySelector('#f-wake');
    w.value = s.wake ? toInput(s.wake) : '';
    w.placeholder = 'Still sleeping';
    sheet.querySelector('#f-notes').value = s.notes || '';
    const del = sheet.querySelector('[data-delete]');
    if (del) del.hidden = s.id === 'new';
    renderStarInput();
    renderTagInput();
    updateDur();
    sheet.classList.add('open');
    document.body.classList.add('sheet-open');
  }
  function closeSheet() {
    const sheet = document.getElementById('sheet');
    sheet && sheet.classList.remove('open');
    document.body.classList.remove('sheet-open');
  }
  function renderStarInput() {
    const wrap = document.querySelector('#sheet .star-input');
    if (!wrap) return;
    wrap.innerHTML =
      Array.from({ length: 5 }, (_, i) =>
        `<button type="button" class="${draftQ && i < draftQ ? 'on' : ''}" data-v="${i + 1}" aria-label="${i + 1} star${i ? 's' : ''}">${draftQ && i < draftQ ? icons.starFill : icons.star}</button>`
      ).join('') + `<button type="button" class="clear" data-v="0">${draftQ ? 'Clear' : 'Not rated'}</button>`;
  }
  function renderTagInput() {
    const wrap = document.querySelector('#sheet .tag-input');
    if (!wrap) return;
    wrap.innerHTML = TAG_POOL.map(
      (t) => `<button type="button" class="chip ${editing.tags.includes(t) ? 'on' : ''}" aria-pressed="${editing.tags.includes(t)}">${t}</button>`
    ).join('');
  }
  function updateDur() {
    const bed = new Date(document.getElementById('f-bed').value);
    const wv = document.getElementById('f-wake').value;
    const err = document.getElementById('f-err');
    const dur = document.getElementById('f-dur');
    if (!wv) { dur.textContent = 'In progress'; err.textContent = ''; return; }
    const m = (new Date(wv) - bed) / 60000;
    if (m <= 0) { dur.textContent = '—'; err.textContent = 'Wake time needs to be after bed time.'; }
    else { dur.textContent = fmtDur(m); err.textContent = ''; }
  }
  function initSheet() {
    document.addEventListener('click', (e) => {
      const o = e.target.closest('[data-open-session]');
      if (o) { openSheet(o.dataset.openSession); return; }
      if (e.target.closest('[data-add-session]')) { openSheet('new'); return; }
      if (e.target.closest('[data-close-sheet]')) { closeSheet(); return; }
      const sb = e.target.closest('#sheet .star-input button');
      if (sb) { const v = Number(sb.dataset.v); draftQ = v === 0 || v === draftQ ? null : v; renderStarInput(); return; }
      const chip = e.target.closest('#sheet .tag-input .chip');
      if (chip) { chip.classList.toggle('on'); chip.setAttribute('aria-pressed', chip.classList.contains('on')); return; }
      if (e.target.closest('[data-save]')) {
        if (document.getElementById('f-err').textContent) return;
        closeSheet(); toast(editing.id === 'new' ? 'Night added' : 'Changes saved'); return;
      }
      if (e.target.closest('[data-delete]')) {
        closeSheet(); toast('Session deleted', 'Undo', () => toast('Restored')); return;
      }
    });
    document.addEventListener('input', (e) => {
      if (e.target.id === 'f-bed' || e.target.id === 'f-wake') updateDur();
    });
    document.addEventListener('keydown', (e) => { if (e.key === 'Escape') closeSheet(); });
  }

  // ---------- Inline quick-rate (rate straight from a list, any night) ----------
  function initQuickRate() {
    document.addEventListener('click', (e) => {
      const b = e.target.closest('[data-rate]');
      if (!b) return;
      e.stopPropagation();
      const [id, v] = b.dataset.rate.split(':').map(Number);
      const s = byId(id);
      s.quality = s.quality === v ? null : v;
      const holder = b.closest('[data-rate-wrap]');
      if (holder) holder.innerHTML = rateButtons(s);
      toast(s.quality ? `Rated ${s.quality}/5` : 'Rating cleared');
    }, true);
  }
  const rateButtons = (s, size = 16) =>
    Array.from({ length: 5 }, (_, i) =>
      `<button type="button" class="rate ${s.quality && i < s.quality ? 'on' : ''}" data-rate="${s.id}:${i + 1}" aria-label="Rate ${i + 1} of 5">${(s.quality && i < s.quality ? icons.starFill : icons.star).replace(/width="20" height="20"/, `width="${size}" height="${size}"`)}</button>`
    ).join('');

  function mountChrome() {
    const phone = document.querySelector('.phone');
    if (!phone || document.getElementById('sheet')) return;
    phone.insertAdjacentHTML('beforeend', `
      <div class="sheet-scrim" data-close-sheet></div>
      <section id="sheet" class="sheet" role="dialog" aria-modal="true" aria-labelledby="sheet-title">
        <div class="sheet-grab" aria-hidden="true"></div>
        <header class="sheet-head">
          <h2 id="sheet-title">Edit night</h2>
          <button type="button" class="icon-btn" data-close-sheet aria-label="Close">${icons.x}</button>
        </header>
        <div class="sheet-body">
          <div class="time-grid">
            <label class="field"><span>Went to bed</span><input id="f-bed" type="datetime-local"></label>
            <label class="field"><span>Woke up</span><input id="f-wake" type="datetime-local"></label>
          </div>
          <div class="dur-row"><span>Duration</span><strong id="f-dur">—</strong></div>
          <p id="f-err" class="err" role="alert"></p>
          <div class="field"><span>How did you sleep?</span><div class="star-input"></div></div>
          <div class="field"><span>Tags <em>(optional)</em></span><div class="tag-input"></div></div>
          <label class="field"><span>Notes</span><textarea id="f-notes" rows="3" placeholder="Dreams, wake-ups, how you feel…"></textarea></label>
          <p class="hint">${icons.clock}<span>Times, rating, tags and notes stay editable forever — come back any time.</span></p>
        </div>
        <footer class="sheet-foot">
          <button type="button" class="btn ghost danger" data-delete>${icons.trash}<span>Delete</span></button>
          <button type="button" class="btn primary" data-save>Save</button>
        </footer>
      </section>
      <div id="toast" class="toast" role="status" aria-live="polite"></div>`);
  }

  function boot() {
    mountChrome();
    initTheme(); initTabs(); initSleep(); initSheet(); initQuickRate();
    document.querySelectorAll('[data-icon]').forEach((el) => (el.innerHTML = icons[el.dataset.icon] + el.innerHTML));
  }

  window.Proto = {
    sessions, byId, stats, GOAL, TAG_POOL, icons, stars, rateButtons,
    fmtDur, fmtHours, fmtClock, fmtDay, fmtDow, fmtLong, timer, eveMin,
    tracker, setSleeping, setTheme, showTab, openSheet, toast, boot,
  };
})();
