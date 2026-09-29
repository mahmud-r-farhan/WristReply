package com.wristreply.core.nlp

import java.util.Calendar

/**
 * Multi-tier deterministic fallback reply generator supporting high-adoption
 * global smartwatch languages: English, Spanish, German, Portuguese, French,
 * Arabic, Hindi, and Bengali.
 */
object FallbackReplyEngine {

    private val ARABIC_REGEX = Regex("[\u0600-\u06FF]")
    private val DEVANAGARI_REGEX = Regex("[\u0900-\u097F]")
    private val BENGALI_REGEX = Regex("[\u0980-\u09FF]")

    private val SPANISH_PATTERN = Regex("(?i)\\b(donde|d\u00F3nde|como|c\u00F3mo|hola|gracias|qu\u00E9 tal|amigo|vamos|puedes|claro)\\b")
    private val GERMAN_PATTERN = Regex("(?i)\\b(wo|wie|hallo|danke|bitte|unterwegs|zeit|sp\u00E4ter|alles gut|bist du)\\b")
    private val PORTUGUESE_PATTERN = Regex("(?i)\\b(onde|ol\u00E1|obrigado|valeu|beleza|tudo bem|a caminho|cad\u00EA|liga)\\b")
    private val FRENCH_PATTERN = Regex("(?i)\\b(o\u00F9|comment|\u00E7a va|salut|merci|en route|dispo|tu peux)\\b")
    private val HINGLISH_PATTERN = Regex("(?i)\\b(kahan|kidhar|kaise|kya hal|raste|a raha|bhai|phone karo)\\b")
    private val BANGLISH_PATTERN = Regex("(?i)\\b(kothay|koi|kemon|aschis|hobe|ki obostha|call dao|astechi)\\b")

    fun resolveFallback(
        incomingText: String,
        userCustomPills: List<String> = emptyList(),
        tone: String = "casual",
        applyChronoBias: Boolean = true
    ): List<String> {
        // Priority 1: User custom overrides
        if (userCustomPills.isNotEmpty()) return userCustomPills.take(3)

        // Priority 2: Chrono late-night bias (23:00 - 06:00)
        if (applyChronoBias) {
            val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
            if (hour >= 23 || hour <= 6) {
                if (SPANISH_PATTERN.containsMatchIn(incomingText)) return LanguageReplyBanks.SPANISH_LATE_NIGHT
                return LanguageReplyBanks.ENGLISH_LATE_NIGHT
            }
        }

        // Priority 3: Non-Latin script detection
        if (ARABIC_REGEX.containsMatchIn(incomingText)) return LanguageReplyBanks.ARABIC_CASUAL
        if (DEVANAGARI_REGEX.containsMatchIn(incomingText)) return LanguageReplyBanks.HINDI_DEVANAGARI
        if (BENGALI_REGEX.containsMatchIn(incomingText)) return LanguageReplyBanks.BENGALI_SCRIPT

        // Priority 4: Dynamic keyword inspection for Latin-script languages
        if (SPANISH_PATTERN.containsMatchIn(incomingText)) {
            return if (tone == "professional") LanguageReplyBanks.SPANISH_PRO else LanguageReplyBanks.SPANISH_CASUAL
        }
        if (GERMAN_PATTERN.containsMatchIn(incomingText)) {
            return if (tone == "professional") LanguageReplyBanks.GERMAN_PRO else LanguageReplyBanks.GERMAN_CASUAL
        }
        if (PORTUGUESE_PATTERN.containsMatchIn(incomingText)) {
            return if (tone == "professional") LanguageReplyBanks.PORTUGUESE_PRO else LanguageReplyBanks.PORTUGUESE_CASUAL
        }
        if (FRENCH_PATTERN.containsMatchIn(incomingText)) {
            return if (tone == "professional") LanguageReplyBanks.FRENCH_PRO else LanguageReplyBanks.FRENCH_CASUAL
        }
        if (HINGLISH_PATTERN.containsMatchIn(incomingText)) return LanguageReplyBanks.HINDI_CASUAL
        if (BANGLISH_PATTERN.containsMatchIn(incomingText)) return LanguageReplyBanks.BANGLISH_CASUAL

        // Priority 5: Fall back to English
        return if (tone == "professional") LanguageReplyBanks.ENGLISH_PRO else LanguageReplyBanks.ENGLISH_CASUAL
    }
}
