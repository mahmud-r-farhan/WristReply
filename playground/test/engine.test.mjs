/**
 * Parity tests for the playground engine.
 *
 * Every expectation here is copied from the corresponding JUnit test in
 * `android/core-engine/src/test/kotlin/com/wristreply/core/`, so if the browser
 * mirror drifts away from the Kotlin engine this suite goes red.
 *
 * Run with: node --test playground/test/
 */
import assert from 'node:assert/strict';
import { describe, it } from 'node:test';

import {
  BLOCKED_WORDS,
  LANGUAGE_BANKS,
  containsAbusiveContent,
  contextualEnhance,
  createDebounceBuffer,
  detectLocale,
  resolveFallback,
  resolveLocationPill,
  runPipeline,
  scanAndExtract,
} from '../assets/engine.js';

// FallbackReplyEngineTest.kt ------------------------------------------------------------
describe('FallbackReplyEngine parity', () => {
  it('user custom pills take precedence over locale detection', () => {
    const custom = ['Custom 1', 'Custom 2', 'Custom 3'];
    const result = resolveFallback({ incomingText: 'Hey where are you?', userCustomPills: custom });
    assert.equal(result.pills.length, 3);
    assert.equal(result.pills[0], 'Custom 1');
  });

  it('Spanish pattern triggers Spanish fallback', () => {
    const { pills } = resolveFallback({ incomingText: 'Hola amigo, donde estas?', applyChronoBias: false });
    assert.ok(pills.some((p) => /camino|bien/i.test(p)), `Expected Spanish tokens in ${pills}`);
  });

  it('German pattern triggers German fallback', () => {
    const { pills } = resolveFallback({ incomingText: 'Hallo, wo bist du?', applyChronoBias: false });
    assert.ok(pills.some((p) => /unterwegs|klar/i.test(p)), `Expected German tokens in ${pills}`);
  });

  it('Arabic script triggers Arabic fallback', () => {
    const { pills } = resolveFallback({ incomingText: 'وينك يا غالي؟', applyChronoBias: false });
    assert.ok(pills.some((p) => p.includes('الطريق') || p.includes('تمام')), `Expected Arabic tokens in ${pills}`);
  });

  it('Bengali script triggers Bengali fallback', () => {
    const { pills } = resolveFallback({ incomingText: 'কেমন আছো?', applyChronoBias: false });
    assert.ok(pills.some((p) => p.includes('হ্যাঁ') || p.includes('কথা বলছি')), `Expected Bengali tokens in ${pills}`);
  });

  it('professional tone swaps casual banks for pro banks', () => {
    const casual = resolveFallback({ incomingText: 'Hola amigo', tone: 'casual', applyChronoBias: false });
    const pro = resolveFallback({ incomingText: 'Hola amigo', tone: 'professional', applyChronoBias: false });
    assert.notDeepEqual(casual.pills, pro.pills);
  });

  it('chrono bias off always reaches the daytime locale banks', () => {
    const daytime = resolveFallback({ incomingText: 'Hola amigo, donde estas?', applyChronoBias: false });
    assert.deepEqual(daytime.pills, LANGUAGE_BANKS.SPANISH_CASUAL);
  });

  it('chrono bias switches to the late-night banks after 23:00', () => {
    const night = resolveFallback({ incomingText: 'Hola amigo, donde estas?', applyChronoBias: true, hour: 23 });
    assert.deepEqual(night.pills, LANGUAGE_BANKS.SPANISH_LATE_NIGHT);
    const day = resolveFallback({ incomingText: 'Hola amigo, donde estas?', applyChronoBias: true, hour: 14 });
    assert.deepEqual(day.pills, LANGUAGE_BANKS.SPANISH_CASUAL);
  });

  it('empty user pills fall through to the engine', () => {
    const { pills } = resolveFallback({ incomingText: 'Unknown language text', userCustomPills: [], applyChronoBias: false });
    assert.ok(pills.length > 0);
  });

  it('exposes every bank the Kotlin object ships', () => {
    assert.equal(Object.keys(LANGUAGE_BANKS).length, 24);
    for (const [name, pills] of Object.entries(LANGUAGE_BANKS)) {
      assert.equal(pills.length, 3, `${name} should ship 3 pills`);
    }
  });
});

// LocationPillResolverTest.kt -----------------------------------------------------------
describe('LocationPillResolver parity', () => {
  it('resolves English queries', () => {
    assert.equal(resolveLocationPill('Hey where are you?'), '[📍 Location]');
    assert.equal(resolveLocationPill('Can you send your location?'), '[📍 Location]');
  });

  it('resolves Spanish queries', () => {
    assert.equal(resolveLocationPill('Hola amigo, ¿dónde estás?'), '[📍 Ubicación]');
    assert.equal(resolveLocationPill('Pasa tu ubicacion'), '[📍 Ubicación]');
  });

  it('resolves German queries', () => {
    assert.equal(resolveLocationPill('Hallo, wo bist du?'), '[📍 Standort]');
    assert.equal(resolveLocationPill('Bitte teile deinen Standort'), '[📍 Standort]');
  });

  it('resolves Portuguese queries', () => {
    assert.equal(resolveLocationPill('Onde você está?'), '[📍 Localização]');
    assert.equal(resolveLocationPill('Manda sua localizacao'), '[📍 Localização]');
  });

  it('resolves French queries', () => {
    assert.equal(resolveLocationPill('Tu es où ?'), '[📍 Position]');
    assert.equal(resolveLocationPill('Envoie ta position'), '[📍 Position]');
  });

  it('resolves Arabic queries', () => {
    assert.equal(resolveLocationPill('وينك يا غالي؟'), '[📍 موقعي]');
    assert.equal(resolveLocationPill('أين أنت الآن؟'), '[📍 موقعي]');
  });

  it('resolves Hindi queries', () => {
    assert.equal(resolveLocationPill('Bhai kahan ho?'), '[📍 Location]');
    assert.equal(resolveLocationPill('कहाँ हो?'), '[📍 लोकेशन]');
  });

  it('resolves Bengali queries', () => {
    assert.equal(resolveLocationPill('Kothay acho?'), '[📍 Location]');
    assert.equal(resolveLocationPill('কোথায় আছো?'), '[📍 লোকেশন]');
  });

  it('returns null for non-location queries', () => {
    assert.equal(resolveLocationPill('How are you doing today?'), null);
    assert.equal(resolveLocationPill('Sounds good, see you tomorrow!'), null);
    assert.equal(resolveLocationPill('¡Muchas gracias por todo!'), null);
  });
});

// SmartTokenExtractorTest.kt ------------------------------------------------------------
describe('SmartTokenExtractor parity', () => {
  it('extracts global payment system IDs', () => {
    assert.equal(scanAndExtract('You sent $50.00 to Alex. Transaction ID: 9XX8372648.')?.value, '9XX8372648');
    assert.equal(scanAndExtract('Payment succeeded. Charge ID: ch_3MtwL2LkdIwHu7ix28a3tqPa.')?.value, 'ch_3MtwL2LkdIwHu7ix28a3tqPa');
    assert.equal(scanAndExtract('Payment to Store via Apple Pay. Ref: AP-88392019.')?.value, 'AP-88392019');
    assert.equal(scanAndExtract('Alert: USD 120.50 debited from A/C 4029. Ref No: REF89372109.')?.value, 'REF89372109');
    assert.equal(scanAndExtract('[Binance] Withdrawal of 0.5 ETH successful. TxID: 0x4f8a92b3c4d5.')?.value, '0x4f8a92b3c4d5');
  });

  it('extracts regional payment system IDs', () => {
    assert.equal(scanAndExtract('Pix enviado com sucesso. ID da transação: E00038166202609291234.')?.value, 'E00038166202609291234');
    assert.equal(scanAndExtract('iDEAL betaling geslaagd. Kenmerk: NL93INGB0001234567.')?.value, 'NL93INGB0001234567');
    assert.equal(scanAndExtract('Paid Rs. 1500 to Merchant. UPI Ref: 329482718293.')?.value, '329482718293');
    assert.equal(scanAndExtract('GrabPay transfer completed. Transaction ID: GP-98327492.')?.value, 'GP-98327492');
    assert.equal(scanAndExtract('You have received Tk 500.00. TrxID 9K34DAX891 at 29/09/2026.')?.value, '9K34DAX891');
  });

  it('extracts multi-lingual OTP codes', () => {
    assert.equal(scanAndExtract('Your WristReply verification code: 849201. Valid for 5 min.')?.value, '849201');
    assert.equal(scanAndExtract('Tu código de verificación es 492018 para confirmar tu compra.')?.value, '492018');
    assert.equal(scanAndExtract('Ihr Bestätigungscode lautet 839201.')?.value, '839201');
    assert.equal(scanAndExtract('Votre code de confirmation est 294819.')?.value, '294819');
  });

  it('labels OTPs and transaction IDs differently', () => {
    assert.equal(scanAndExtract('Your verification code: 849201')?.type, 'OTP');
    assert.equal(scanAndExtract('UPI Ref: 329482718293')?.type, 'TRANSACTION_ID');
  });

  it('returns null for ordinary conversation', () => {
    assert.equal(scanAndExtract('Hey, are you free for a quick call?'), null);
  });
});

// ProfanityGuardEngineTest.kt -----------------------------------------------------------
describe('ProfanityGuardEngine parity', () => {
  it('returns false when the shield is disabled', () => {
    assert.equal(containsAbusiveContent('you are an idiot', { enabled: false }).abusive, false);
  });

  it('flags an English token from the default dictionary', () => {
    const { abusive, token } = containsAbusiveContent('you are an idiot', { enabled: true });
    assert.equal(abusive, true);
    assert.equal(token, 'idiot');
  });

  it('flags a custom user word', () => {
    const { abusive, token } = containsAbusiveContent('this is badword today', { customWords: ['badword'] });
    assert.equal(abusive, true);
    assert.equal(token, 'badword');
  });

  it('flags non-latin tokens by lowercasing', () => {
    const token = [...BLOCKED_WORDS][0];
    assert.equal(containsAbusiveContent(`msg contains ${token} now`).abusive, true);
  });

  it('does not flag clean messages', () => {
    assert.equal(containsAbusiveContent('Sounds good, see you later!').abusive, false);
  });

  it('ships the same dictionary size as DefaultBlockedWords.kt', () => {
    // DefaultBlockedWords.kt lists 71 literals, three of which repeat across
    // language sections ("idiot", "fraude", "puta"). Kotlin's setOf() and the
    // JS Set both collapse them, so both sides hold 68 unique tokens.
    assert.equal(BLOCKED_WORDS.size, 68);
  });
});

// ContextualReplyEnhancer.kt ------------------------------------------------------------
describe('ContextualReplyEnhancer parity', () => {
  it('prepends a driving template and localized pill', () => {
    const pills = contextualEnhance({ baseSuggestions: ['Sounds good!'], driving: true, incomingText: 'Hola amigo' });
    assert.equal(pills[1], '[🚗 Manejando]');
  });

  it('prepends a meeting message and pill in English by default', () => {
    const pills = contextualEnhance({ baseSuggestions: ['Sounds good!'], meetingUntil: '3:30 PM', incomingText: 'Can we talk?' });
    assert.equal(pills[0], 'In a meeting until 3:30 PM, will get back to you.');
    assert.equal(pills[1], '[📅 Meeting until 3:30 PM]');
  });

  it('leaves the list untouched without context', () => {
    assert.deepEqual(contextualEnhance({ baseSuggestions: ['A', 'B'] }), ['A', 'B']);
  });
});

// MessageDebounceBuffer.kt --------------------------------------------------------------
describe('MessageDebounceBuffer parity', () => {
  it('emits a single message after the debounce window', async () => {
    const buffer = createDebounceBuffer(60);
    const emitted = await new Promise((resolve) => buffer.enqueue('Alice', 'hello', resolve));
    assert.equal(emitted, 'hello');
  });

  it('collapses a burst into one aggregated prompt', async () => {
    const buffer = createDebounceBuffer(80);
    const emitted = await new Promise((resolve) => {
      buffer.enqueue('Bob', 'first', () => {});
      setTimeout(() => buffer.enqueue('Bob', 'second', () => {}), 20);
      setTimeout(() => buffer.enqueue('Bob', 'third', resolve), 40);
    });
    assert.equal(emitted, 'first second third');
  });

  it('clear() cancels the pending emission', async () => {
    const buffer = createDebounceBuffer(40);
    let fired = 0;
    buffer.enqueue('Charlie', 'hi', () => { fired += 1; });
    await new Promise((r) => setTimeout(r, 10));
    buffer.clear('Charlie');
    await new Promise((r) => setTimeout(r, 90));
    assert.equal(fired, 0);
    assert.equal(buffer.activeSenderCount(), 0);
  });
});

// End-to-end pipeline -------------------------------------------------------------------
describe('runPipeline', () => {
  it('produces a full trace and metrics for a plain message', () => {
    const result = runPipeline({ text: 'Hey, are you free for a quick call right now?' });
    assert.ok(result.pills.length > 0);
    assert.equal(result.metrics.locale, 'en-US');
    assert.ok(result.trace.length >= 9);
    assert.ok(result.trace.every((step) => ['ok', 'skip', 'blocked', 'off'].includes(step.status)));
  });

  it('stops at the profanity gate and emits no pills', () => {
    const result = runPipeline({ text: 'you are an idiot' });
    assert.equal(result.blocked, true);
    assert.equal(result.pills.length, 0);
    assert.equal(result.metrics.rule, 'ProfanityGuardFilter');
  });

  it('appends a localized location pill when asked', () => {
    const result = runPipeline({ text: 'Hola amigo, ¿dónde estás?' });
    assert.ok(result.pills.includes('[📍 Ubicación]'));
  });

  it('respects the pills-per-message cap', () => {
    const result = runPipeline({ text: 'Hello there', options: { pillsPerMessage: 1 } });
    assert.ok(result.pills.length <= 2);
  });

  it('detects the expected locale per script', () => {
    assert.equal(detectLocale('কেমন আছো?'), 'bn-BD');
    assert.equal(detectLocale('وينك'), 'ar-MENA');
    assert.equal(detectLocale('कहाँ हो?'), 'hi-IN');
    assert.equal(detectLocale('Kothay acho?'), 'bn-BD-Banglish');
    assert.equal(detectLocale('Where are you?'), 'en-US');
  });
});
