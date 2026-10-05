/**
 * WristReply AI — Offline Smart Reply Engine in Vanilla JavaScript
 * Zero-cloud, client-side inference engine matching Kotlin & Dart fallbacks.
 */

class VanillaSmartReplyEngine {
    static BANGLISH_KEYWORDS = [
        'kemon', 'kothay', 'hobe', 'kobe', 'koi', 'dhaka', 'chittagong',
        'sylhet', 'khulna', 'bhai', 'thik', 'bhalo', 'khobor', 'aschi',
        'shuno', 'bolo', 'valobasi', 'ke', 'keno', 'khabar', 'tumi'
    ];

    static PROFANITY_SET = new Set([
        'badword', 'spam', 'scam', 'abuse'
    ]);

    static resolve(text, options = {}) {
        const startTime = performance.now();
        const rawText = (text || '').trim();
        const lowerText = rawText.toLowerCase();

        const forcedLocale = options.locale || 'auto';
        const drivingMode = !!options.drivingMode;

        // Check profanity guard
        const containsProfanity = Array.from(this.PROFANITY_SET).some(w => lowerText.includes(w));
        if (containsProfanity) {
            return {
                locale: 'en-US',
                ruleName: 'ProfanityGuardFilter',
                replies: ['[Filtered Message]'],
                latencyMs: (performance.now() - startTime).toFixed(2)
            };
        }

        // Driving Mode Override
        if (drivingMode) {
            return {
                locale: 'en-US',
                ruleName: 'DrivingModeOverride',
                replies: ['Driving now 🚗', 'Will call back later', 'Can\'t talk right now'],
                latencyMs: (performance.now() - startTime).toFixed(2)
            };
        }

        // 1. OTP / Security Code Extractor
        const otpMatch = rawText.match(/\b(\d{4,8})\b/);
        if (otpMatch && (lowerText.includes('code') || lowerText.includes('otp') || lowerText.includes('pin') || lowerText.includes('verification'))) {
            return {
                locale: 'en-US',
                ruleName: 'OtpTokenExtractor',
                replies: [`Copy Code (${otpMatch[1]}) 📋`, 'Auto-Fill', 'Got it 👍'],
                latencyMs: (performance.now() - startTime).toFixed(2)
            };
        }

        // 2. Payment / Financial Link Extractor
        if (lowerText.includes('bkash') || lowerText.includes('nagad') || lowerText.includes('upi') || lowerText.includes('sent tk') || lowerText.includes('paid')) {
            return {
                locale: 'bn-BD',
                ruleName: 'PaymentPillResolver',
                replies: ['Taka peyechi 💵', 'Check korchi 🔍', 'Dhonnobad! 🙏'],
                latencyMs: (performance.now() - startTime).toFixed(2)
            };
        }

        // 3. Location / Waypoint Resolver
        if (rawText.includes('📍') || lowerText.includes('where are you') || lowerText.includes('kothay') || lowerText.includes('location') || lowerText.includes('address')) {
            return {
                locale: lowerText.includes('kothay') ? 'bn-BD' : 'en-US',
                ruleName: 'LocationPillResolver',
                replies: ['Send Location 📍', 'On my way 🏃', 'Near home 🏡', '5 mins away ⏱️'],
                latencyMs: (performance.now() - startTime).toFixed(2)
            };
        }

        // 4. Forced Locale Handling or Auto-detection
        let detectedLocale = forcedLocale;
        if (forcedLocale === 'auto') {
            if (/[\u0980-\u09FF]/.test(rawText)) {
                detectedLocale = 'bn-BD';
            } else if (/[\u0600-\u06FF]/.test(rawText)) {
                detectedLocale = 'ar-MENA';
            } else if (/\b(hola|cómo|donde|gracias|amigo|bien)\b/i.test(rawText)) {
                detectedLocale = 'es-ES';
            } else if (/\b(hallo|wie|danke|bitte|wo|tschüss)\b/i.test(rawText)) {
                detectedLocale = 'de-DE';
            } else if (this.BANGLISH_KEYWORDS.some(k => lowerText.includes(k))) {
                detectedLocale = 'bn-BD-Banglish';
            } else {
                detectedLocale = 'en-US';
            }
        }

        // 5. Generate Replies based on Locale / Banglish
        let replies = [];
        let ruleName = `LanguageBank:${detectedLocale}`;

        switch (detectedLocale) {
            case 'bn-BD':
                if (lowerText.includes('কেমন') || lowerText.includes('আছো')) {
                    replies = ['হ্যাঁ, ভালো আছি! 😊', 'তুমি কেমন আছো?', 'মোটামুটি চলছে।'];
                } else if (lowerText.includes('কখন') || lowerText.includes('আসো')) {
                    replies = ['আমি আসছি 🏃', 'কিছুক্ষণের মধ্যে।', 'একটু পর কথা বলছি।'];
                } else {
                    replies = ['হ্যাঁ, ঠিক আছে 👍', 'পরে কথা বলছি 📞', 'ধন্যবাদ! 🙏', 'কোথায় তুমি? 📍'];
                }
                break;

            case 'bn-BD-Banglish':
                ruleName = 'BanglishRuleMatcher';
                if (lowerText.includes('kemon')) {
                    replies = ['Thik achi, tumi?', 'Valo achi! 😊', 'Khobor ki?'];
                } else if (lowerText.includes('kothay') || lowerText.includes('koi')) {
                    replies = ['Rastay achi 🏃', 'Basay achi 🏡', 'Aschi 5 min e!'];
                } else if (lowerText.includes('hobe')) {
                    replies = ['Ha, hobe 👍', 'Na, hobe na', 'Dekhi kobe kora jay'];
                } else {
                    replies = ['Ha thik ache 👍', 'Pore kotha bolchi 📞', 'Dhonnobad! 🙏'];
                }
                break;

            case 'es-ES':
                replies = ['¡Vale, perfecto! 👍', 'Estoy en camino 🏃', 'Hablamos luego 📞', '¿Dónde estás? 📍'];
                break;

            case 'de-DE':
                replies = ['Klingt gut! 👍', 'Bin unterwegs 🏃', 'Ich melde mich später 📞', 'Bis gleich!'];
                break;

            case 'ar-MENA':
                replies = ['تمام، ممتاز! 👍', 'أنا في الطريق 🏃', 'نتكلم لاحقاً 📞', 'شكراً جزيلاً! 🙏'];
                break;

            case 'en-US':
            default:
                if (lowerText.includes('how are you') || lowerText.includes('how\'s it going')) {
                    replies = ['Doing great! 😊', 'All good, you?', 'Not bad at all!'];
                } else if (lowerText.includes('when') || lowerText.includes('time')) {
                    replies = ['In 10 minutes ⏱️', 'On my way! 🏃', 'Let me check!'];
                } else if (lowerText.includes('meeting') || lowerText.includes('call')) {
                    replies = ['Joining now! 💻', 'Can\'t make it, sorry', 'Will call in 5 mins'];
                } else {
                    replies = ['Sounds good! 👍', 'On my way! 🏃', 'Busy, text you later ⏳', 'Thanks! 🙏'];
                }
                break;
        }

        return {
            locale: detectedLocale,
            ruleName: ruleName,
            replies: replies,
            latencyMs: (performance.now() - startTime).toFixed(2)
        };
    }
}

// UI Controller logic
document.addEventListener('DOMContentLoaded', () => {
    const messageInput = document.getElementById('messageInput');
    const localeSelect = document.getElementById('localeSelect');
    const drivingToggle = document.getElementById('drivingToggle');
    const pillsContainer = document.getElementById('pillsContainer');
    const toast = document.getElementById('toast');

    const latencyMetric = document.getElementById('latencyMetric');
    const localeMetric = document.getElementById('localeMetric');
    const ruleMetric = document.getElementById('ruleMetric');
    const countMetric = document.getElementById('countMetric');

    function updatePills() {
        const text = messageInput.value;
        const options = {
            locale: localeSelect.value,
            drivingMode: drivingToggle.checked
        };

        const result = VanillaSmartReplyEngine.resolve(text, options);

        // Render Pill Buttons
        pillsContainer.innerHTML = '';
        if (!result.replies || result.replies.length === 0) {
            pillsContainer.innerHTML = '<span style="color: var(--text-muted); font-size: 13px;">No suggestions generated</span>';
        } else {
            result.replies.forEach(reply => {
                const btn = document.createElement('button');
                btn.className = 'pill-chip';
                btn.textContent = reply;
                btn.addEventListener('click', () => showToast(`Dispatched to smartwatch: "${reply}"`));
                pillsContainer.appendChild(btn);
            });
        }

        // Update Metrics Ledger
        if (latencyMetric) latencyMetric.textContent = `${result.latencyMs} ms`;
        if (localeMetric) localeMetric.textContent = result.locale;
        if (ruleMetric) ruleMetric.textContent = result.ruleName;
        if (countMetric) countMetric.textContent = `${result.replies.length} pills`;
    }

    function showToast(msg) {
        toast.textContent = msg;
        toast.style.display = 'block';
        setTimeout(() => {
            toast.style.display = 'none';
        }, 3000);
    }

    // Attach Event Listeners
    if (messageInput) messageInput.addEventListener('input', updatePills);
    if (localeSelect) localeSelect.addEventListener('change', updatePills);
    if (drivingToggle) drivingToggle.addEventListener('change', updatePills);

    // Attach Preset Buttons
    document.querySelectorAll('.preset-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const presetText = btn.getAttribute('data-text');
            if (presetText && messageInput) {
                messageInput.value = presetText;
                updatePills();
            }
        });
    });

    // Initial render
    updatePills();
});
