package com.wristreply.core.nlp

/**
 * Multi-lingual location query detector and localized action pill resolver.
 * Detects location inquiries across major smartwatch markets: English, Spanish,
 * German, Portuguese, French, Arabic, Hindi, and Bengali.
 */
object LocationPillResolver {

    private val SPANISH_QUERY = Regex("(?i)(^|[\\s\\p{P}\\p{S}])(d[oó]nde|ubicaci[oó]n|d[oó]nde est[aá]s|donde estas|d[oó]nde andas)($|[\\s\\p{P}\\p{S}])")
    private val GERMAN_QUERY = Regex("(?i)(^|[\\s\\p{P}\\p{S}])(wo|standort|wo bist du|wo bist)($|[\\s\\p{P}\\p{S}])")
    private val PORTUGUESE_QUERY = Regex("(?i)(^|[\\s\\p{P}\\p{S}])(onde|localiza[cç][aã]o|onde voc[eê] est[aá]|onde c[eê] t[aá])($|[\\s\\p{P}\\p{S}])")
    private val FRENCH_QUERY = Regex("(?i)(^|[\\s\\p{P}\\p{S}])(o[uù]|position|o[uù] es-tu|t'es o[uù]|tu es o[uù])($|[\\s\\p{P}\\p{S}])")
    private val ARABIC_QUERY = Regex("(?i)([أا]ين|وين|فين|وينك|فينك|موقعك|موقع)")

    private val HINDI_LATIN_QUERY = Regex("(?i)\\b(kahan|kidhar|kahan ho|kidhar ho)\\b")
    private val BANGLISH_QUERY = Regex("(?i)\\b(kothay|koi|kothay acho|koi aso)\\b")
    private val ENGLISH_QUERY = Regex("(?i)\\b(where|location|where are you|where r u|where you at|loc)\\b")

    private val HINDI_DEVANAGARI = listOf("कहाँ", "किधर")
    private val BENGALI_SCRIPT_WORDS = listOf("কোথায়", "কই")

    /**
     * Resolves the localized location pill if incoming text asks for location.
     * Returns null if no location query is found.
     */
    fun resolveLocationPill(text: String): String? {
        val lower = text.lowercase()

        // 1. Script-specific fast checks
        if (BENGALI_SCRIPT_WORDS.any { text.contains(it) }) return "[📍 লোকেশন]"
        if (HINDI_DEVANAGARI.any { text.contains(it) }) return "[📍 लोकेशन]"
        if (ARABIC_QUERY.containsMatchIn(text)) return "[📍 موقعي]"

        // 2. Latin-script regional queries
        return when {
            SPANISH_QUERY.containsMatchIn(lower) -> "[📍 Ubicación]"
            GERMAN_QUERY.containsMatchIn(lower) -> "[📍 Standort]"
            PORTUGUESE_QUERY.containsMatchIn(lower) -> "[📍 Localização]"
            FRENCH_QUERY.containsMatchIn(lower) -> "[📍 Position]"
            HINDI_LATIN_QUERY.containsMatchIn(lower) -> "[📍 Location]"
            BANGLISH_QUERY.containsMatchIn(lower) -> "[📍 Location]"
            ENGLISH_QUERY.containsMatchIn(lower) -> "[📍 Location]"
            else -> null
        }
    }
}
