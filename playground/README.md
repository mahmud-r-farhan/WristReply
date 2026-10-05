# WristReply AI Playground 🌐

A **zero-build, zero-dependency** static page that runs the WristReply reply engine in the browser.
It exists so a reviewer can answer three questions in about a minute: *what does WristReply do,
how does it decide, and why is it designed this way.*

```
playground/
├── index.html            # the page: hero, live sandbox, phone + watch mockups, docs sections
├── assets/
│   ├── engine.js         # JavaScript port of the Kotlin core engine (ESM, no dependencies)
│   ├── app.js            # UI controller: form → engine → pills, mockups, device log
│   └── styles.css        # design tokens + component styles + CDN fallbacks
└── test/
    ├── engine.test.mjs   # 41 parity assertions against the Kotlin expectations
    └── markup.test.mjs   # HTML/JS wiring assertions
```

---

## 1. Run it

No package manager, no bundler, no Flutter SDK.

```bash
cd playground
python3 -m http.server 8080
# → http://localhost:8080
```

Any static host works (GitHub Pages, Netlify, `npx serve`, `nginx`).

**Double-clicking `index.html` will not work.** The controller is loaded as
`<script type="module">` and imports `./engine.js`; module scripts are always fetched under CORS, and a
`file://` document has an opaque origin, so the browser blocks both the script and its import. The page
still renders — HTML, CSS and the CDN styles are unaffected — but the sandbox stays inert. Serve it over
HTTP.

---

## 2. What the page contains

| Section | Purpose |
| --- | --- |
| Live playground | Paste a notification, watch all eight stages run, get reply pills |
| Phone mockup | Full Android notification card with up to five pills and a copy-token chip |
| Watch mockups | Round (Wear OS) and square (Zepp OS / RTOS) companions with three pills |
| How it works | One card per pipeline stage, naming the Kotlin class that implements it |
| Privacy | The zero-cloud argument, including the missing `INTERNET` permission |
| Languages | The ten supported locales, their detection rule and their bank counts |
| Architecture | Module boundaries, memory budget and the Flutter/Kotlin split |
| FAQ | Six questions about cost, latency, permissions and extensibility |

Twelve presets cover the interesting cases: a WhatsApp message, an English/Spanish/Arabic/Hindi/Bengali
sample, a bank OTP with an OTP token, a Stripe transaction ID, a late-night message, a meeting invite
and a message that the profanity guard refuses.

---

## 3. How the engine stays honest

`assets/engine.js` is a **port**, not a mock. The behaviour and the data were taken from the Kotlin
sources so the browser and the daemon agree:

| JavaScript | Kotlin source of truth |
| --- | --- |
| `LANGUAGE_BANKS` (24 banks × 3 pills) | `nlp/LanguageReplyBanks.kt` |
| `BLOCKED_WORDS` (68 unique tokens) | `filters/DefaultBlockedWords.kt` |
| `resolveFallback`, `detectLocale` | `nlp/FallbackReplyEngine.kt` |
| `resolveLocationPill` | `nlp/LocationPillResolver.kt` |
| `scanAndExtract` | `filters/SmartTokenExtractor.kt` |
| `containsAbusiveContent` | `filters/ProfanityGuardEngine.kt` |
| `contextualEnhance` | `nlp/ContextualReplyEnhancer.kt` |
| `createDebounceBuffer` | `guard/MessageDebounceBuffer.kt` |
| `runPipeline` | `service/NotificationProcessorService.kt` |

Two notes worth keeping in mind:

- `DefaultBlockedWords.kt` lists 71 literals but only **68 unique** tokens — `idiot`, `fraude` and `puta`
  each appear in two language sections. Kotlin's `setOf` and a JavaScript `Set` both collapse them, so
  68 is the correct number everywhere.
- The port is deterministic. The Kotlin daemon can additionally consult ML Kit; the playground does not
  ship a model, so the fallback path is always the one you see — which is exactly the path that runs on
  any device where ML Kit returns nothing.

---

## 4. Tests

Both suites use Node's built-in `node:test` runner — no `npm install` required.

```bash
node --test playground/test/engine.test.mjs playground/test/markup.test.mjs
```

- `engine.test.mjs` — 41 assertions covering fallback banks per locale, locale detection, OTP and
  transaction extraction, the profanity guard, contextual pills, debounce timing and `runPipeline`.
- `markup.test.mjs` — asserts that every `getElementById` target exists in the markup, that navigation
  anchors resolve to real sections, that the CDN references and their fallback rules are present, that
  every local asset resolves on disk, and that `app.js` imports nothing the engine does not export.

`flutter.yml` runs both suites on every pull request, so a Kotlin-side change that the port has not
followed will fail CI rather than silently drift.

---

## 5. CDN policy

The page loads three third-party assets:

- **Tailwind CSS** from `cdn.tailwindcss.com` (utility classes).
- **AOS** from `cdnjs.cloudflare.com` (scroll-reveal animations).
- **Google Fonts** for Space Grotesk (display), Inter (body) and JetBrains Mono (code).

`assets/styles.css` contains a full fallback: `html:not(.tw-ready)` supplies layout, colour and spacing
for every Tailwind utility the page uses, and `html:not(.aos-ready) [data-aos]` forces all animated
elements visible. The `tw-ready` class is added by an inline guard in `index.html` as soon as
`window.tailwind` exists, and `aos-ready` is added by `app.js` only when `window.AOS` is defined.
Result: on a blocked or offline network the page looks plainer but stays fully readable and interactive,
and the CDN status strip at the bottom of the playground reports which one is active.

No network request ever carries message content — the engine runs entirely in the browser.

---

## 6. Design tokens

`assets/styles.css` `:root` mirrors `lib/core/constants/app_colors.dart` and `engineering.md` §5 exactly:
canvas `#0B0E14`, raised `#131823`, interactive `#1C2333`, borders `#222B3D` / `#2D3A54`, accent
`#00F2FE`, mint `#38EF7D`, warning `#FFB020`, danger `#FF4C4C`, text `#F1F5F9` / `#94A3B8` / `#475569`.
Touch targets stay at 48 dp on the phone mockup and 44 dp on the watch mockups.
