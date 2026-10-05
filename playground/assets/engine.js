/**
 * WristReply AI — browser mirror of the headless Kotlin engine.
 *
 * Every export below is a 1:1 port of a class in
 * `android/core-engine/src/main/kotlin/com/wristreply/core/`:
 *
 *   LANGUAGE_BANKS / resolveFallback  →  nlp/LanguageReplyBanks.kt, nlp/FallbackReplyEngine.kt
 *   resolveLocationPill               →  nlp/LocationPillResolver.kt
 *   scanAndExtract                    →  filters/SmartTokenExtractor.kt
 *   containsAbusiveContent            →  filters/ProfanityGuardEngine.kt (+ DefaultBlockedWords.kt)
 *   contextualEnhance                 →  context/ContextualReplyEnhancer.kt
 *   createDebounceBuffer              →  guard/MessageDebounceBuffer.kt
 *
 * The banks and the blocklist are generated from the Kotlin sources so the
 * playground can never drift away from what actually ships on the device.
 * Nothing in this file touches the network — the whole point of WristReply is
 * that inference happens on the device that received the message.
 */

/* ------------------------------------------------------------------ *
 * Language reply banks — mirrors nlp/LanguageReplyBanks.kt
 * ------------------------------------------------------------------ */
export const LANGUAGE_BANKS = {
    "ENGLISH_CASUAL": [
      "Sounds good!",
      "On my way!",
      "Can't talk now, text later."
    ],
    "ENGLISH_PRO": [
      "Understood, looking into it.",
      "I will update you shortly.",
      "Noted with thanks."
    ],
    "ENGLISH_LATE_NIGHT": [
      "Asleep, talk tomorrow",
      "Can it wait till morning?",
      "Good night"
    ],
    "SPANISH_CASUAL": [
      "¡Dale, suena bien!",
      "¡Voy en camino!",
      "No puedo hablar ahora, te escribo."
    ],
    "SPANISH_PRO": [
      "Entendido, lo reviso ahora.",
      "Te confirmo en un momento.",
      "Quedo al pendiente."
    ],
    "SPANISH_LATE_NIGHT": [
      "Ya estoy durmiendo, hablamos mañana",
      "¿Puede esperar a mañana?",
      "Buenas noches"
    ],
    "GERMAN_CASUAL": [
      "Alles klar!",
      "Bin unterwegs!",
      "Kann gerade nicht, melde mich später."
    ],
    "GERMAN_PRO": [
      "Verstanden, ich prüfe das.",
      "Ich gebe Ihnen gleich Bescheid.",
      "Vielen Dank."
    ],
    "GERMAN_LATE_NIGHT": [
      "Schlafe schon, melde mich morgen",
      "Kann das bis morgen warten?",
      "Gute Nacht"
    ],
    "PORTUGUESE_CASUAL": [
      "Beleza, combinado!",
      "Estou a caminho!",
      "Não posso falar agora, te ligo já."
    ],
    "PORTUGUESE_PRO": [
      "Entendido, já estou verificando.",
      "Retorno em breve.",
      "Muito obrigado."
    ],
    "PORTUGUESE_LATE_NIGHT": [
      "Dormindo já, falo amanhã",
      "Pode esperar até amanhã?",
      "Boa noite"
    ],
    "FRENCH_CASUAL": [
      "Ça marche !",
      "Je suis en route !",
      "Occupé pour le moment, je te rappelle."
    ],
    "FRENCH_PRO": [
      "C'est bien noté, je m'en occupe.",
      "Je reviens vers vous rapidement.",
      "Merci bien."
    ],
    "FRENCH_LATE_NIGHT": [
      "Je dors déjà, on se parle demain",
      "Ça peut attendre demain matin ?",
      "Bonne nuit"
    ],
    "ARABIC_CASUAL": [
      "تمام، إن شاء الله!",
      "أنا في الطريق!",
      "مشغول الآن، بكلمك بعدين."
    ],
    "ARABIC_PRO": [
      "تم الاستلام، سأوافيك بالتفاصيل قريباً.",
      "شكراً جزيلاً.",
      "سأتواصل معك في أقرب وقت."
    ],
    "ARABIC_LATE_NIGHT": [
      "نائم الآن، نتحدث غداً",
      "ممكن تنتظر للصباح؟",
      "تصبح على خير"
    ],
    "HINDI_CASUAL": [
      "Theek hai, badhiya!",
      "Raste me hu!",
      "Abhi thoda busy hu, baad me call karta hu."
    ],
    "HINDI_DEVANAGARI": [
      "हाँ, बिल्कुल!",
      "रास्ते में हूँ!",
      "थोड़ी देर में बात करता हूँ।"
    ],
    "HINDI_LATE_NIGHT": [
      "So raha hu, subah baat karte hai",
      "Kal subah baat karein?",
      "Shubh ratri"
    ],
    "BENGALI_SCRIPT": [
      "হ্যাঁ, ঠিক আছে!",
      "আমি রাস্তায় আছি!",
      "একটু পর কথা বলছি।"
    ],
    "BANGLISH_CASUAL": [
      "Astechi 5 min e",
      "Ekhon ektu busy achi",
      "Call dao ektu por"
    ],
    "BENGALI_LATE_NIGHT": [
      "Ghumacche, shokale kotha boli",
      "Shokale bolte parbo?",
      "Shubh ratri"
    ]
};

/* ------------------------------------------------------------------ *
 * Default profanity/fraud dictionary — mirrors filters/DefaultBlockedWords.kt
 * ------------------------------------------------------------------ */
export const BLOCKED_WORDS = new Set([
  "scam",
    "fraud",
    "phishing",
    "fake",
    "stolen",
    "hacked",
    "winner",
    "jackpot",
    "lottery",
    "urgent wire",
    "bastard",
    "idiot",
    "asshole",
    "bullshit",
    "bitch",
    "wtf",
    "scammer",
    "kill yourself",
    "estafa",
    "fraude",
    "mierda",
    "puta",
    "puto",
    "idiota",
    "imbecil",
    "pendejo",
    "cabron",
    "hijo de puta",
    "estafador",
    "coño",
    "culiao",
    "betrug",
    "scheisse",
    "arschloch",
    "schlampe",
    "hurensohn",
    "wichser",
    "idiot",
    "miststueck",
    "verpiss dich",
    "golpe",
    "fraude",
    "merda",
    "puta",
    "caralho",
    "porra",
    "filho da puta",
    "otario",
    "babaca",
    "estelionato",
    "corno",
    "nasb",
    "ehteyal",
    "kelb",
    "khara",
    "sharmouta",
    "ahbal",
    "kazzab",
    "harami",
    "kamina",
    "kutta",
    "chutiya",
    "madarchod",
    "bhenchod",
    "gand",
    "bokachoda",
    "chup",
    "shala",
    "gali",
    "chor",
    "dhoka"
]);

/* ------------------------------------------------------------------ *
 * Script + keyword detection — mirrors nlp/FallbackReplyEngine.kt
 * ------------------------------------------------------------------ */
const ARABIC_REGEX = /[\u0600-\u06FF]/;
const DEVANAGARI_REGEX = /[\u0900-\u097F]/;
const BENGALI_REGEX = /[\u0980-\u09FF]/;

const SPANISH_PATTERN = /\b(donde|d\u00F3nde|como|c\u00F3mo|hola|gracias|qu\u00E9 tal|amigo|vamos|puedes|claro)\b/i;
const GERMAN_PATTERN = /\b(wo|wie|hallo|danke|bitte|unterwegs|zeit|sp\u00E4ter|alles gut|bist du)\b/i;
const PORTUGUESE_PATTERN = /\b(onde|ol\u00E1|obrigado|valeu|beleza|tudo bem|a caminho|cad\u00EA|liga)\b/i;
const FRENCH_PATTERN = /\b(o\u00F9|comment|\u00E7a va|salut|merci|en route|dispo|tu peux)\b/i;
const HINGLISH_PATTERN = /\b(kahan|kidhar|kaise|kya hal|raste|a raha|bhai|phone karo)\b/i;
const BANGLISH_PATTERN = /\b(kothay|koi|kemon|aschis|hobe|ki obostha|call dao|astechi)\b/i;

/** Human-readable locale label for the metrics ledger. */
export function detectLocale(text) {
  if (ARABIC_REGEX.test(text)) return 'ar-MENA';
  if (DEVANAGARI_REGEX.test(text)) return 'hi-IN';
  if (BENGALI_REGEX.test(text)) return 'bn-BD';
  if (SPANISH_PATTERN.test(text)) return 'es-ES';
  if (GERMAN_PATTERN.test(text)) return 'de-DE';
  if (PORTUGUESE_PATTERN.test(text)) return 'pt-BR';
  if (FRENCH_PATTERN.test(text)) return 'fr-FR';
  if (HINGLISH_PATTERN.test(text)) return 'hi-IN-Latin';
  if (BANGLISH_PATTERN.test(text)) return 'bn-BD-Banglish';
  return 'en-US';
}

/**
 * Multi-tier deterministic fallback generator.
 *
 * Priority order is identical to the Kotlin implementation:
 *   1. user custom pills   2. late-night chrono bias   3. script detection
 *   4. Latin-script keyword match                     5. English default
 *
 * @param {object} input
 * @param {string} input.incomingText
 * @param {string[]} [input.userCustomPills]
 * @param {'casual'|'professional'} [input.tone]
 * @param {boolean} [input.applyChronoBias]
 * @param {number} [input.hour] Wall-clock hour, injectable so tests stay deterministic.
 */
export function resolveFallback({
  incomingText,
  userCustomPills = [],
  tone = 'casual',
  applyChronoBias = true,
  hour = new Date().getHours(),
} = {}) {
  const text = incomingText || '';

  // 1. User overrides always win.
  if (userCustomPills.length > 0) {
    return { pills: userCustomPills.slice(0, 3), rule: 'UserCustomOverride', bank: null };
  }

  // 2. Late-night chrono bias (23:00 - 06:59 local).
  if (applyChronoBias && (hour >= 23 || hour <= 6)) {
    const lateNight = [
      [SPANISH_PATTERN, 'SPANISH_LATE_NIGHT'],
      [GERMAN_PATTERN, 'GERMAN_LATE_NIGHT'],
      [PORTUGUESE_PATTERN, 'PORTUGUESE_LATE_NIGHT'],
      [FRENCH_PATTERN, 'FRENCH_LATE_NIGHT'],
      [ARABIC_REGEX, 'ARABIC_LATE_NIGHT'],
      [null, null], // placeholder keeps the ordering readable below
    ];
    for (const [pattern, bank] of lateNight) {
      if (pattern && pattern.test(text)) {
        return { pills: [...LANGUAGE_BANKS[bank]], rule: 'ChronoBias:' + bank, bank };
      }
    }
    if (DEVANAGARI_REGEX.test(text) || HINGLISH_PATTERN.test(text)) {
      return { pills: [...LANGUAGE_BANKS.HINDI_LATE_NIGHT], rule: 'ChronoBias:HINDI_LATE_NIGHT', bank: 'HINDI_LATE_NIGHT' };
    }
    if (BENGALI_REGEX.test(text) || BANGLISH_PATTERN.test(text)) {
      return { pills: [...LANGUAGE_BANKS.BENGALI_LATE_NIGHT], rule: 'ChronoBias:BENGALI_LATE_NIGHT', bank: 'BENGALI_LATE_NIGHT' };
    }
    return { pills: [...LANGUAGE_BANKS.ENGLISH_LATE_NIGHT], rule: 'ChronoBias:ENGLISH_LATE_NIGHT', bank: 'ENGLISH_LATE_NIGHT' };
  }

  // 3. Non-Latin script detection.
  if (ARABIC_REGEX.test(text)) return bank('ARABIC_CASUAL', 'ScriptMatch:Arabic');
  if (DEVANAGARI_REGEX.test(text)) return bank('HINDI_DEVANAGARI', 'ScriptMatch:Devanagari');
  if (BENGALI_REGEX.test(text)) return bank('BENGALI_SCRIPT', 'ScriptMatch:Bengali');

  // 4. Latin-script keyword inspection.
  if (SPANISH_PATTERN.test(text)) {
    return tone === 'professional' ? bank('SPANISH_PRO', 'KeywordMatch:Spanish:pro') : bank('SPANISH_CASUAL', 'KeywordMatch:Spanish');
  }
  if (GERMAN_PATTERN.test(text)) {
    return tone === 'professional' ? bank('GERMAN_PRO', 'KeywordMatch:German:pro') : bank('GERMAN_CASUAL', 'KeywordMatch:German');
  }
  if (PORTUGUESE_PATTERN.test(text)) {
    return tone === 'professional' ? bank('PORTUGUESE_PRO', 'KeywordMatch:Portuguese:pro') : bank('PORTUGUESE_CASUAL', 'KeywordMatch:Portuguese');
  }
  if (FRENCH_PATTERN.test(text)) {
    return tone === 'professional' ? bank('FRENCH_PRO', 'KeywordMatch:French:pro') : bank('FRENCH_CASUAL', 'KeywordMatch:French');
  }
  if (HINGLISH_PATTERN.test(text)) return bank('HINDI_CASUAL', 'KeywordMatch:Hinglish');
  if (BANGLISH_PATTERN.test(text)) return bank('BANGLISH_CASUAL', 'KeywordMatch:Banglish');

  // 5. English default.
  return tone === 'professional' ? bank('ENGLISH_PRO', 'Fallback:English:pro') : bank('ENGLISH_CASUAL', 'Fallback:English');
}

function bank(name, rule) {
  return { pills: [...LANGUAGE_BANKS[name]], rule, bank: name };
}

/* ------------------------------------------------------------------ *
 * Location pill resolver — mirrors nlp/LocationPillResolver.kt
 * ------------------------------------------------------------------ */
const SPANISH_QUERY = /(^|[\s\p{P}\p{S}])(d[o\u00F3]nde|ubicaci[o\u00F3]n|d[o\u00F3]nde est[a\u00E1]s|donde estas|d[o\u00F3]nde andas)($|[\s\p{P}\p{S}])/iu;
const GERMAN_QUERY = /(^|[\s\p{P}\p{S}])(wo|standort|wo bist du|wo bist)($|[\s\p{P}\p{S}])/iu;
const PORTUGUESE_QUERY = /(^|[\s\p{P}\p{S}])(onde|localiza[c\u00E7][a\u00E3]o|onde voc[e\u00EA] est[a\u00E1]|onde c[e\u00EA] t[a\u00E1])($|[\s\p{P}\p{S}])/iu;
const FRENCH_QUERY = /(^|[\s\p{P}\p{S}])(o[u\u00F9]|position|o[u\u00F9] es-tu|t'es o[u\u00F9]|tu es o[u\u00F9])($|[\s\p{P}\p{S}])/iu;
const ARABIC_QUERY = /([\u0623\u0627]\u064A\u0646|\u0648\u064A\u0646|\u0641\u064A\u0646|\u0648\u064A\u0646\u0643|\u0641\u064A\u0646\u0643|\u0645\u0648\u0642\u0639\u0643|\u0645\u0648\u0642\u0639)/i;
const HINDI_LATIN_QUERY = /\b(kahan|kidhar|kahan ho|kidhar ho)\b/i;
const BANGLISH_QUERY = /\b(kothay|koi|kothay acho|koi aso)\b/i;
const ENGLISH_QUERY = /\b(where|location|where are you|where r u|where you at|loc)\b/i;

const HINDI_DEVANAGARI = ['\u0915\u0939\u093E\u0901', '\u0915\u093F\u0927\u0930'];
const BENGALI_SCRIPT_WORDS = ['\u0995\u09CB\u09A5\u09BE\u09AF\u09BC', '\u0995\u0987'];

/** Returns the localized `[\u{1F4CD} …]` pill, or null when nothing asks for a location. */
export function resolveLocationPill(text) {
  const raw = text || '';
  const lower = raw.toLowerCase();

  if (BENGALI_SCRIPT_WORDS.some((w) => raw.includes(w))) return '[\u{1F4CD} \u09B2\u09CB\u0995\u09C7\u09B6\u09A8]';
  if (HINDI_DEVANAGARI.some((w) => raw.includes(w))) return '[\u{1F4CD} \u0932\u094B\u0915\u0947\u0936\u0928]';
  if (ARABIC_QUERY.test(raw)) return '[\u{1F4CD} \u0645\u0648\u0642\u0639\u064A]';

  if (SPANISH_QUERY.test(lower)) return '[\u{1F4CD} Ubicaci\u00F3n]';
  if (GERMAN_QUERY.test(lower)) return '[\u{1F4CD} Standort]';
  if (PORTUGUESE_QUERY.test(lower)) return '[\u{1F4CD} Localiza\u00E7\u00E3o]';
  if (FRENCH_QUERY.test(lower)) return '[\u{1F4CD} Position]';
  if (HINDI_LATIN_QUERY.test(lower)) return '[\u{1F4CD} Location]';
  if (BANGLISH_QUERY.test(lower)) return '[\u{1F4CD} Location]';
  if (ENGLISH_QUERY.test(lower)) return '[\u{1F4CD} Location]';
  return null;
}

/* ------------------------------------------------------------------ *
 * OTP / transaction extractor — mirrors filters/SmartTokenExtractor.kt
 * ------------------------------------------------------------------ */
const TRX_PATTERNS = [
  /\b((?:ch_|pi_|py_|in_)[a-zA-Z0-9]{20,30})\b/i,
  /\b(?:txid|transaction\s*hash)[:\s#]+(0x[a-fA-F0-9]{10,64})\b/i,
  /\b(?:upi\s*(?:ref|rrn)?\s*(?:no|id)?|utr\s*(?:no)?|txn\s*(?:id|ref))[:\s#]+([A-Za-z0-9]{10,22})\b/i,
  /\b(?:id\s*da\s*transa[c\u00E7][a\u00E3]o|autentica[c\u00E7][a\u00E3]o)[:\s#]+([A-Za-z0-9]{9,35})\b/i,
  /\b(?:kenmerk|betalingskenmerk|referentie)[:\s#]+([A-Za-z0-9]{8,25})\b/i,
  /\b(?:trxid|txid|tran(?:saction)?\s*id|ref(?:erence)?(?:\s*no)?|order\s*id|session\s*id|folio|opera\u00E7\u00E3o)[:\s#]+([A-Za-z0-9_\-]{6,32})\b/i,
];

const OTP_PATTERNS = [
  /\b(?:otp|verification(?:\s*code)?|security\s*code|auth\s*code|c\u00F3digo(?:\s*de\s*verificaci\u00F3n)?|best\u00E4tigungscode|sicherheitscode|code(?:\s*de\s*confirmation)?|clave|pin|passcode|\u0631\u0645\u0632(?:\s*\u0627\u0644\u062A\u062D\u0642\u0642)?|\u0643\u0648\u062F|\u0995\u09CB\u09A1|\u0993\u099F\u09BF\u09AA|\u0915\u094B\u0921)(?:\s*(?:is|es|ist|est|lautet|:|#|=|-|\.))*\s*[:#=\s-]*(\d{4,8})\b/i,
  /\b(\d{4,8})\s+(?:is\s+your|es\s+tu|ist\s+(?:ihr|dein)|est\s+votre|c'est\s+votre)\b/i,
];

function cleanToken(raw) {
  return raw.trim().replace(/[.,;:!?)\]]+$/, '');
}

/** Returns `{ type: 'TRANSACTION_ID' | 'OTP', value }` or null. */
export function scanAndExtract(text, { autoCopyTrx = true, autoCopyOtp = true } = {}) {
  const source = text || '';
  if (autoCopyTrx) {
    for (const pattern of TRX_PATTERNS) {
      const match = pattern.exec(source);
      if (match && match[1]) {
        const token = cleanToken(match[1]);
        if (token) return { type: 'TRANSACTION_ID', value: token };
      }
    }
  }
  if (autoCopyOtp) {
    for (const pattern of OTP_PATTERNS) {
      const match = pattern.exec(source);
      if (match && match[1]) {
        const token = cleanToken(match[1]);
        if (token) return { type: 'OTP', value: token };
      }
    }
  }
  return null;
}

/* ------------------------------------------------------------------ *
 * Profanity shield — mirrors filters/ProfanityGuardEngine.kt
 * ------------------------------------------------------------------ */
const NORMALIZE = /[^a-zA-Z0-9\u0980-\u09FF\u0600-\u06FF\u0900-\u097F\s]/g;

/** Returns `{ abusive: boolean, token: string | null }`. */
export function containsAbusiveContent(text, { customWords = [], enabled = true } = {}) {
  if (!enabled) return { abusive: false, token: null };
  const dictionary = new Set([...BLOCKED_WORDS, ...customWords]);
  const normalized = (text || '').toLowerCase().replace(NORMALIZE, ' ');
  for (const token of normalized.split(/\s+/)) {
    if (token && dictionary.has(token)) return { abusive: true, token };
  }
  return { abusive: false, token: null };
}

/* ------------------------------------------------------------------ *
 * Context enhancer — mirrors context/ContextualReplyEnhancer.kt
 * ------------------------------------------------------------------ */
const CONTEXT_PATTERNS = [
  [SPANISH_PATTERN, { driving: '[\u{1F697} Manejando]', meeting: (t) => `[\u{1F4C5} En reuni\u00F3n hasta ${t}]`,
    meetingFull: (t) => `En una reuni\u00F3n hasta las ${t}, te respondo luego.` }],
  [GERMAN_PATTERN, { driving: '[\u{1F697} Am Fahren]', meeting: (t) => `[\u{1F4C5} Im Meeting bis ${t}]`,
    meetingFull: (t) => `Im Meeting bis ${t} Uhr, melde mich danach.` }],
  [PORTUGUESE_PATTERN, { driving: '[\u{1F697} Dirigindo]', meeting: (t) => `[\u{1F4C5} Em reuni\u00E3o at\u00E9 ${t}]`,
    meetingFull: (t) => `Em reuni\u00E3o at\u00E9 ${t}, respondo em breve.` }],
  [FRENCH_PATTERN, { driving: '[\u{1F697} Au volant]', meeting: (t) => `[\u{1F4C5} En r\u00E9union jusqu'\u00E0 ${t}]`,
    meetingFull: (t) => `En r\u00E9union jusqu'\u00E0 ${t}, je reviens vers toi.` }],
  [ARABIC_REGEX, { driving: '[\u{1F697} \u0623\u0642\u0648\u062F \u0627\u0644\u0633\u064A\u0627\u0631\u0629]', meeting: (t) => `[\u{1F4C5} \u0641\u064A \u0627\u062C\u062A\u0645\u0627\u0639 \u062D\u062A\u0649 ${t}]`,
    meetingFull: (t) => `\u0641\u064A \u0627\u062C\u062A\u0645\u0627\u0639 \u062D\u062A\u0649 ${t}\u060C \u0633\u0623\u062A\u0648\u0627\u0635\u0644 \u0645\u0639\u0643 \u0644\u0627\u062D\u0642\u0627\u064B.` }],
];

function contextTemplates(text) {
  for (const [pattern, templates] of CONTEXT_PATTERNS) {
    if (pattern.test(text || '')) return templates;
  }
  return {
    driving: '[\u{1F697} Driving]',
    meeting: (t) => `[\u{1F4C5} Meeting until ${t}]`,
    meetingFull: (t) => `In a meeting until ${t}, will get back to you.`,
  };
}

/**
 * Prepends driving / meeting pills exactly like ContextualReplyEnhancer.
 * @param {object} input
 * @param {string[]} input.baseSuggestions
 * @param {boolean} [input.driving]
 * @param {string|null} [input.meetingUntil] Formatted end time, e.g. "3:30 PM".
 * @param {string} [input.incomingText]
 * @param {string} [input.drivingTemplate]
 */
export function contextualEnhance({ baseSuggestions, driving = false, meetingUntil = null, incomingText = '', drivingTemplate = 'Driving now, talk soon' }) {
  const enhanced = [...baseSuggestions];
  const templates = contextTemplates(incomingText);

  if (driving) {
    enhanced.unshift(templates.driving);
    enhanced.unshift(drivingTemplate);
    return [...new Set(enhanced)];
  }
  if (meetingUntil) {
    enhanced.unshift(templates.meeting(meetingUntil));
    enhanced.unshift(templates.meetingFull(meetingUntil));
    return [...new Set(enhanced)];
  }
  return enhanced;
}

/* ------------------------------------------------------------------ *
 * Burst debounce buffer — mirrors guard/MessageDebounceBuffer.kt
 * ------------------------------------------------------------------ */
/**
 * Collapses rapid-fire messages from one sender into a single prompt.
 * The Kotlin buffer waits DEBOUNCE_DELAY_MS = 1500ms after the *last*
 * segment before emitting.
 */
export function createDebounceBuffer(windowMs = 1500, maxSegments = 5) {
  const jobs = new Map();
  const windows = new Map();

  return {
    enqueue(senderId, text, onBatchReady) {
      const segments = windows.get(senderId) || [];
      segments.push(text);
      while (segments.length > maxSegments) segments.shift();
      windows.set(senderId, segments);

      const existing = jobs.get(senderId);
      if (existing) clearTimeout(existing);

      const timer = setTimeout(() => {
        jobs.delete(senderId);
        const combined = (windows.get(senderId) || []).join(' ');
        if (combined) onBatchReady(combined);
      }, windowMs);
      jobs.set(senderId, timer);
    },
    clear(senderId) {
      const existing = jobs.get(senderId);
      if (existing) clearTimeout(existing);
      jobs.delete(senderId);
      windows.delete(senderId);
    },
    activeSenderCount: () => jobs.size,
  };
}

/* ------------------------------------------------------------------ *
 * Full pipeline trace used by the UI
 * ------------------------------------------------------------------ */
/**
 * Runs the whole notification pipeline for one message and returns a trace the
 * UI can animate stage by stage.
 *
 * @returns {{trace: object[], pills: string[], metrics: object, blocked: boolean, token: object|null}}
 */
export function runPipeline({ text, options = {} } = {}) {
  const startedAt = performance.now();
  const {
    localeOverride = 'auto',
    tone = 'casual',
    applyChronoBias = false,
    drivingMode = false,
    meetingUntil = null,
    pillsPerMessage = 3,
    shieldEnabled = true,
    customPills = [],
    customBlockedWords = [],
    locationPinEnabled = true,
    hour = new Date().getHours(),
  } = options;

  const incoming = (text || '').trim();
  const trace = [];
  const push = (stage, status, detail) => trace.push({ stage, status, detail });

  push('notification', incoming ? 'ok' : 'skip', incoming ? 'MessagingStyle payload captured' : 'No EXTRA_TEXT payload');

  // --- Gate -------------------------------------------------------
  const gateOk = incoming.length > 0;
  push('gate', gateOk ? 'ok' : 'skip', gateOk ? 'Not ongoing, not a group summary, text present' : 'Rejected before any NLP compute');

  // --- Profanity shield -------------------------------------------
  const abuse = containsAbusiveContent(incoming, { enabled: shieldEnabled, customWords: customBlockedWords });
  if (abuse.abusive) {
    push('profanity', 'blocked', 'Blocked token: "' + abuse.token + '"');
    push('nlp', 'blocked', 'Pipeline halted — no cheerful auto-reply');
    push('publish', 'blocked', 'Abuse warning posted instead');
    return finish(trace, [], { rule: 'ProfanityGuardFilter', locale: 'en-US', bank: null, blocked: true, token: null, startedAt });
  }
  push('profanity', shieldEnabled ? 'ok' : 'off', shieldEnabled ? 'Clean — 68 default tokens + user blocklist' : 'Shield disabled by user');

  // --- Token extraction -------------------------------------------
  const token = scanAndExtract(incoming);
  push('token', token ? 'ok' : 'skip', token ? token.type + ' → ' + token.value : 'No OTP / transaction ID found');

  // --- Debounce -----------------------------------------------------
  push('debounce', 'ok', '1.5s window, bursts collapse into one prompt');

  // --- NLP / fallback -----------------------------------------------
  const locale = localeOverride === 'auto' ? detectLocale(incoming) : localeOverride;
  let pills;
  let rule;
  let bankName = null;
  if (customPills.length > 0) {
    pills = customPills.slice(0, 3);
    rule = 'UserCustomOverride';
  } else {
    const resolved = resolveFallback({ incomingText: incoming, tone, applyChronoBias, hour });
    pills = resolved.pills;
    rule = resolved.rule;
    bankName = resolved.bank;
  }
  push('nlp', 'ok', rule + (localeOverride === 'auto' ? ' (' + locale + ')' : ' (locale pinned to ' + locale + ')'));

  // --- Context enhancement -----------------------------------------
  pills = contextualEnhance({ baseSuggestions: pills, driving: drivingMode, meetingUntil, incomingText: incoming });
  if (drivingMode) {
    push('context', 'ok', 'Bluetooth car audio detected — driving pills injected');
  } else if (meetingUntil) {
    push('context', 'ok', 'Calendar busy until ' + meetingUntil + ' — meeting pills injected');
  } else {
    push('context', 'skip', 'No driving / meeting context');
  }

  // --- Location pill -------------------------------------------------
  let locationPill = null;
  if (locationPinEnabled) {
    locationPill = resolveLocationPill(incoming);
    if (locationPill) pills = [...pills, locationPill];
  }
  push('location', locationPill ? 'ok' : 'skip', locationPill ? 'Appended ' + locationPill : 'Not a location query');

  // --- Publish --------------------------------------------------------
  const capped = pills.slice(0, Math.max(1, Math.min(5, pillsPerMessage)) + (locationPill ? 1 : 0));
  push('publish', 'ok', capped.length + ' pills in a silent IMPORTANCE_LOW companion');
  push('dispatch', 'ok', 'RemoteInput → messaging app PendingIntent (no unlock)');

  return finish(trace, capped, { rule, locale, bank: bankName, blocked: false, token, startedAt });
}

function finish(trace, pills, meta) {
  const latency = Math.max(0.04, performance.now() - meta.startedAt);
  return {
    trace,
    pills,
    blocked: meta.blocked,
    token: meta.token,
    metrics: {
      latencyMs: latency,
      locale: meta.locale,
      rule: meta.rule,
      bank: meta.bank,
      pillCount: pills.length,
    },
  };
}
