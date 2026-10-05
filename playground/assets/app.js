/**
 * WristReply AI playground — UI controller.
 *
 * Wires the form controls to the engine port in `engine.js`, animates the
 * eight-stage pipeline, and mirrors the generated pills onto the phone and
 * watch mockups. No network access, no build step, no framework.
 */
import { INTENT_BANKS, LANGUAGE_BANKS, createDebounceBuffer, runPipeline } from './engine.js';

const $ = (selector) => document.querySelector(selector);
const $$ = (selector) => [...document.querySelectorAll(selector)];

const PRESETS = [
  { label: 'Banglish', text: 'Kemon acho bhai? Kothay tumi?', icon: 'fa-comment' },
  { label: 'বাংলা', text: 'কেমন আছো? কখন আসছো?', icon: 'fa-globe' },
  { label: 'Español', text: 'Hola amigo, ¿dónde estás?', icon: 'fa-globe' },
  { label: 'Deutsch', text: 'Hallo, wo bist du?', icon: 'fa-globe' },
  { label: 'العربية', text: 'وينك يا غالي؟ متى توصل؟', icon: 'fa-globe' },
  { label: 'हिन्दी', text: 'Bhai kahan ho? Phone karo', icon: 'fa-globe' },
  { label: 'Français', text: 'Tu es où ? On se retrouve ?', icon: 'fa-globe' },
  { label: 'OTP Code', text: 'Your WristReply verification code: 849201. Valid for 5 min.', icon: 'fa-shield-halved' },
  { label: 'bKash Trx', text: 'You have received Tk 500.00. TrxID 9K34DAX891 at 29/09/2026.', icon: 'fa-money-bill-wave' },
  { label: 'UPI Ref', text: 'Paid Rs. 1500 to Merchant. UPI Ref: 329482718293.', icon: 'fa-receipt' },
  { label: 'Abusive Filter', text: 'you are an idiot, send money now', icon: 'fa-triangle-exclamation' },
  { label: 'Meeting Intent', text: 'Can we schedule a quick call tomorrow morning?', icon: 'fa-calendar' },
  { label: 'Well-being', text: 'Hey, how have you been doing lately?', icon: 'fa-handshake' },
  { label: 'Gratitude', text: 'Thank you so much for the assistance today!', icon: 'fa-heart' },
];

const STAGES = [
  'notification', 'gate', 'profanity', 'token', 'debounce', 'nlp', 'context', 'publish',
];

const state = {
  watchShape: 'round',
  lastPills: [],
  burstActive: false,
};

const els = {
  input: $('#message-input'),
  presets: $('#presets'),
  locale: $('#locale-select'),
  tone: $('#tone-select'),
  pillsRange: $('#pills-range'),
  pillsOutput: $('#pills-output'),
  meeting: $('#meeting-input'),
  driving: $('#toggle-driving'),
  chrono: $('#toggle-chrono'),
  shield: $('#toggle-shield'),
  location: $('#toggle-location'),
  toggleCustomPills: $('#toggle-custom-pills'),
  customPillsInput: $('#custom-pills-input'),
  btnBurst: $('#btn-burst'),
  burstIndicator: $('#burst-indicator'),
  btnShareScenario: $('#btn-share-scenario'),
  btnClearLog: $('#btn-clear-log'),
  toastNotice: $('#toast-notice'),
  strip: $('#pipeline-strip'),
  log: $('#device-log'),
  phoneSender: $('#phone-sender'),
  phoneText: $('#phone-text'),
  phonePills: $('#phone-pills'),
  phoneToken: $('#phone-token'),
  phoneCompanion: $('#phone-companion'),
  phoneSub: $('#phone-wr-sub'),
  watchSender: $('#watch-sender'),
  watchMsg: $('#watch-msg'),
  watchPills: $('#watch-pills'),
  watchSent: $('#watch-sent'),
  watch: $('#watch'),
  dispatch: $('#dispatch-line'),
  engineBadge: $('#engine-badge'),
  cdnStatus: $('#cdn-status'),
  languageTable: $('#language-table'),
  metrics: {
    latency: $('#m-latency'),
    locale: $('#m-locale'),
    rule: $('#m-rule'),
    count: $('#m-count'),
  },
};

/* ---------------------------------------------------------------- *
 * Toast notification
 * ---------------------------------------------------------------- */
let toastTimer = null;
function showToast(message) {
  const textEl = $('#toast-text') || els.toastNotice;
  textEl.textContent = message;
  els.toastNotice.classList.add('is-active-toast');
  window.clearTimeout(toastTimer);
  toastTimer = window.setTimeout(() => {
    els.toastNotice.classList.remove('is-active-toast');
  }, 2400);
}

/* ---------------------------------------------------------------- *
 * Presets rendering
 * ---------------------------------------------------------------- */
function renderPresets() {
  els.presets.replaceChildren(
    ...PRESETS.map((preset) => {
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'wr-preset';
      button.innerHTML = `<i class="fa-solid ${preset.icon} text-[10px] text-mint"></i><span>${preset.label}</span>`;
      button.addEventListener('click', () => {
        $$('.wr-preset').forEach((b) => b.classList.remove('is-active-preset'));
        button.classList.add('is-active-preset');
        els.input.value = preset.text;
        run();
        els.input.focus({ preventScroll: true });
        showToast(`Loaded preset: ${preset.label}`);
      });
      return button;
    }),
  );
}

/* ---------------------------------------------------------------- *
 * Pipeline strip
 * ---------------------------------------------------------------- */
function renderStrip() {
  els.strip.replaceChildren(
    ...STAGES.map((stage) => {
      const cell = document.createElement('div');
      cell.className = 'wr-stage-cell';
      cell.dataset.stage = stage;
      cell.innerHTML = `<span class="wr-stage-dot"></span><span class="truncate">${stage}</span>`;
      return cell;
    }),
  );
}

function setStage(stage, status) {
  const cell = els.strip.querySelector(`[data-stage="${stage}"]`);
  if (!cell) return;
  cell.classList.remove('is-ok', 'is-skip', 'is-blocked', 'is-off', 'is-active');
  cell.classList.add(`is-${status}`, 'is-active');
}

/* ---------------------------------------------------------------- *
 * Device log
 * ---------------------------------------------------------------- */
function log(line, kind = 'info') {
  const row = document.createElement('div');
  row.className = `wr-log-row wr-log-${kind}`;
  const time = new Date().toLocaleTimeString('en-GB', { hour12: false });
  row.textContent = `${time}  ${line}`;
  els.log.prepend(row);
  while (els.log.childElementCount > 80) els.log.lastElementChild.remove();
}

/* ---------------------------------------------------------------- *
 * Pills
 * ---------------------------------------------------------------- */
function truncate(text, max = 26) {
  return text.length > max ? `${text.slice(0, max - 1)}…` : text;
}

function renderPills(pills) {
  state.lastPills = pills;

  els.phonePills.replaceChildren(
    ...pills.map((pill) => pillButton(pill, 'wr-pill', pill)),
  );

  // A watch comfortably fits three; the rest stay in the phone shade.
  els.watchPills.replaceChildren(
    ...pills.slice(0, 3).map((pill) => pillButton(pill, 'watch-pill', pill)),
  );

  if (pills.length === 0) {
    const empty = document.createElement('p');
    empty.className = 'wr-empty';
    empty.textContent = 'No pills — content filter active.';
    els.phonePills.append(empty);
    els.watchPills.append(empty.cloneNode(true));
  }
}

function pillButton(pill, className, fullText) {
  const button = document.createElement('button');
  button.type = 'button';
  button.className = className;
  button.textContent = truncate(pill);
  button.title = pill;
  button.addEventListener('click', () => dispatch(fullText));
  return button;
}

/* ---------------------------------------------------------------- *
 * Dispatch simulation
 * ---------------------------------------------------------------- */
function dispatch(pill) {
  const watchClass = state.watchShape === 'round' ? 'watch-frame--round' : 'watch-frame--square';
  els.watchSent.textContent = `Sent ✓ ${truncate(pill, 16)}`;
  els.watch.classList.add('is-sending');
  els.watchSent.classList.add('is-visible');

  // Trigger celebration confetti if canvas-confetti is loaded
  if (typeof window.confetti === 'function') {
    try {
      window.confetti({
        particleCount: 26,
        spread: 60,
        origin: { y: 0.72 },
        colors: ['#38ef7d', '#00f2fe', '#ffffff'],
      });
    } catch {
      // Confetti fallback
    }
  }

  els.dispatch.textContent = `RemoteInput.addResultsToIntent("${pill}") → PendingIntent.send() · notification shade dismissed`;
  els.dispatch.classList.remove('text-muted');
  els.dispatch.classList.add('text-mint');
  log(`dispatch → "${pill}" attached to RemoteInput`, 'ok');
  showToast(`Dispatched reply: "${truncate(pill, 20)}"`);

  window.setTimeout(() => {
    els.watch.classList.remove('is-sending');
    els.watchSent.classList.remove('is-visible');
    els.dispatch.classList.add('text-muted');
    els.dispatch.classList.remove('text-mint');
  }, 2200);
  void watchClass;
}

/* ---------------------------------------------------------------- *
 * Rapid burst debounce simulation
 * ---------------------------------------------------------------- */
function simulateBurst() {
  if (state.burstActive) return;
  state.burstActive = true;
  els.burstIndicator.classList.add('is-active-burst');
  log('⚡ Starting Rapid 3-Message Burst Simulation...', 'ok');

  const burstBuffer = createDebounceBuffer(1500);
  const burstMessages = [
    'Hey Rifat!',
    'Are you free right now?',
    'Can we do a quick call about the project?',
  ];

  burstMessages.forEach((msg, idx) => {
    window.setTimeout(() => {
      log(`[Burst incoming ${idx + 1}/3] "${msg}"`, 'dim');
      burstBuffer.enqueue('Alice', msg, (combined) => {
        state.burstActive = false;
        els.burstIndicator.classList.remove('is-active-burst');
        els.input.value = combined;
        run();
        log(`✓ MessageDebounceBuffer aggregated burst → "${combined}"`, 'ok');
        showToast('Burst aggregated into single prompt!');
      });
    }, idx * 360);
  });
}

/* ---------------------------------------------------------------- *
 * Language table
 * ---------------------------------------------------------------- */
const LANGUAGE_ROWS = [
  ['English (global)', 'default / ML Kit', 'ENGLISH_CASUAL', 'ENGLISH_LATE_NIGHT'],
  ['Spanish (LatAm, Spain)', 'hola · dónde · gracias', 'SPANISH_CASUAL', 'SPANISH_LATE_NIGHT'],
  ['German (DACH)', 'hallo · wo · später', 'GERMAN_CASUAL', 'GERMAN_LATE_NIGHT'],
  ['Portuguese (BR, PT)', 'onde · obrigado · beleza', 'PORTUGUESE_CASUAL', 'PORTUGUESE_LATE_NIGHT'],
  ['French (FR, CA)', 'où · salut · merci', 'FRENCH_CASUAL', 'FRENCH_LATE_NIGHT'],
  ['Arabic (MENA)', 'U+0600–U+06FF script', 'ARABIC_CASUAL', 'ARABIC_LATE_NIGHT'],
  ['Hindi / Hinglish', 'U+0900–U+097F · kahan · bhai', 'HINDI_CASUAL', 'HINDI_LATE_NIGHT'],
  ['Bengali / Banglish', 'U+0980–U+09FF · kothay · kemon', 'BANGLISH_CASUAL', 'BENGALI_LATE_NIGHT'],
];

function renderLanguageTable() {
  const body = els.languageTable;
  body.replaceChildren(
    ...LANGUAGE_ROWS.map(([market, trigger, casual, lateNight]) => {
      const row = document.createElement('tr');
      row.innerHTML =
        `<td class="whitespace-nowrap font-medium text-ink">${market}</td>` +
        `<td class="whitespace-nowrap font-mono text-xs text-faint">${trigger}</td>` +
        `<td>${LANGUAGE_BANKS[casual][1]}</td>` +
        `<td class="text-faint">${LANGUAGE_BANKS[lateNight][0]}</td>`;
      return row;
    }),
  );
}

/* ---------------------------------------------------------------- *
 * Run the engine
 * ---------------------------------------------------------------- */
function run() {
  const text = els.input.value;
  const customPills = (els.toggleCustomPills && els.toggleCustomPills.checked && els.customPillsInput)
    ? els.customPillsInput.value.split(',').map((s) => s.trim()).filter(Boolean)
    : [];

  const options = {
    localeOverride: els.locale.value,
    tone: els.tone.value,
    pillsPerMessage: Number(els.pillsRange.value),
    meetingUntil: els.meeting.value.trim() || null,
    drivingMode: els.driving.checked,
    applyChronoBias: els.chrono.checked,
    shieldEnabled: els.shield.checked,
    locationPinEnabled: els.location.checked,
    customPills,
  };

  const result = runPipeline({ text, options });

  // Phone mirror
  els.phoneSender.textContent = 'Rifat';
  els.phoneText.textContent = text.trim() || '—';
  els.phoneSub.textContent = result.blocked
    ? 'Abusive content blocked — no auto-reply generated'
    : 'Quick replies generated on-device';

  const tokenTextEl = $('#phone-token-text');
  if (result.token) {
    els.phoneToken.classList.remove('hidden');
    const label = `${result.token.type.replace('_', ' ')}: ${result.token.value}`;
    if (tokenTextEl) {
      tokenTextEl.textContent = label;
    } else {
      els.phoneToken.textContent = label;
    }
    els.phoneToken.onclick = () => {
      if (navigator.clipboard) {
        navigator.clipboard.writeText(result.token.value);
        showToast(`Copied ${result.token.value} to clipboard!`);
        log(`Clipboard copy → ${result.token.value}`, 'ok');
      }
    };
  } else {
    els.phoneToken.classList.add('hidden');
    els.phoneToken.onclick = null;
  }

  els.watchSender.textContent = 'Rifat';
  els.watchMsg.textContent = truncate(text.trim() || '—', 30);

  renderPills(result.pills);

  // Metrics
  els.metrics.latency.textContent = `${result.metrics.latencyMs.toFixed(2)} ms`;
  els.metrics.locale.textContent = result.metrics.locale;
  els.metrics.rule.textContent = result.metrics.rule;
  els.metrics.count.textContent = String(result.metrics.pillCount);

  // Pipeline animation + log
  STAGES.forEach((stage) => setStage(stage, 'skip'));
  const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  result.trace.forEach((step, index) => {
    const delay = reduced ? 0 : index * 60;
    window.setTimeout(() => {
      setStage(step.stage, step.status);
      log(`[${step.stage}] ${step.detail}`, step.status === 'blocked' ? 'bad' : step.status === 'ok' ? 'ok' : 'dim');
    }, delay);
  });
}

let debounceTimer = null;
function scheduleRun() {
  window.clearTimeout(debounceTimer);
  debounceTimer = window.setTimeout(run, 180);
}

/* ---------------------------------------------------------------- *
 * Scenario URL Sharing
 * ---------------------------------------------------------------- */
function shareScenario() {
  const text = encodeURIComponent(els.input.value);
  const tone = encodeURIComponent(els.tone.value);
  const url = `${window.location.origin}${window.location.pathname}#text=${text}&tone=${tone}`;
  if (navigator.clipboard) {
    navigator.clipboard.writeText(url);
    showToast('Simulation link copied to clipboard!');
  }
}

function restoreScenarioFromHash() {
  const hash = window.location.hash.slice(1);
  if (!hash) return;
  const params = new URLSearchParams(hash);
  if (params.has('text')) {
    els.input.value = decodeURIComponent(params.get('text'));
  }
  if (params.has('tone') && els.tone) {
    els.tone.value = decodeURIComponent(params.get('tone'));
  }
}

/* ---------------------------------------------------------------- *
 * Boot
 * ---------------------------------------------------------------- */
function bind() {
  els.input.addEventListener('input', scheduleRun);
  [els.locale, els.tone, els.meeting].forEach((el) => el && el.addEventListener('change', run));
  [els.driving, els.chrono, els.shield, els.location].forEach((el) => el && el.addEventListener('change', run));
  if (els.toggleCustomPills) els.toggleCustomPills.addEventListener('change', run);
  if (els.customPillsInput) els.customPillsInput.addEventListener('input', scheduleRun);

  els.pillsRange.addEventListener('input', () => {
    els.pillsOutput.textContent = els.pillsRange.value;
    run();
  });

  if (els.btnBurst) els.btnBurst.addEventListener('click', simulateBurst);
  if (els.btnShareScenario) els.btnShareScenario.addEventListener('click', shareScenario);
  if (els.btnClearLog) {
    els.btnClearLog.addEventListener('click', () => {
      els.log.replaceChildren();
      log('logcat cleared', 'dim');
    });
  }

  $$('[data-watch]').forEach((button) => {
    button.addEventListener('click', () => {
      $$('[data-watch]').forEach((b) => b.classList.remove('is-active'));
      button.classList.add('is-active');
      state.watchShape = button.dataset.watch;
      els.watch.classList.toggle('watch-frame--round', state.watchShape === 'round');
      els.watch.classList.toggle('watch-frame--square', state.watchShape === 'square');
      showToast(`Switched to ${state.watchShape} form-factor`);
    });
  });
}

function reportCdn() {
  const tailwind = document.documentElement.classList.contains('tw-ready');
  const aos = typeof window.AOS !== 'undefined';
  els.cdnStatus.textContent = `Tailwind CDN ${tailwind ? 'loaded' : 'unavailable (fallback CSS active)'} · AOS ${aos ? 'loaded' : 'unavailable (animations off)'}`;
}

function initAos() {
  if (typeof window.AOS === 'undefined') return;
  document.documentElement.classList.add('aos-ready');
  window.AOS.init({ duration: 600, easing: 'ease-out-cubic', once: true, offset: 60 });
}

renderPresets();
renderStrip();
renderLanguageTable();
bind();
restoreScenarioFromHash();
run();
initAos();
reportCdn();
log(`engine ready · 24 reply banks · ${Object.keys(INTENT_BANKS).length} intent banks · 68 blocked tokens · 0 network calls`, 'ok');
