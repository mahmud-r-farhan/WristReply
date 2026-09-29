package com.wristreply.core.filters

/**
 * Global dictionary of baseline toxic, fraudulent, and abusive keywords across
 * major smartwatch adoption markets: English, Spanish, German, Portuguese,
 * Arabic, Hindi, and Bengali.
 */
object DefaultBlockedWords {

    val WORDS: Set<String> = setOf(
        // English (Global / Primary)
        "scam", "fraud", "phishing", "fake", "stolen", "hacked", "winner",
        "jackpot", "lottery", "urgent wire", "bastard", "idiot", "asshole",
        "bullshit", "bitch", "wtf", "scammer", "kill yourself",

        // Spanish (LatAm & Spain)
        "estafa", "fraude", "mierda", "puta", "puto", "idiota", "imbecil",
        "pendejo", "cabron", "hijo de puta", "estafador", "coño", "culiao",

        // German (DACH region)
        "betrug", "scheisse", "arschloch", "schlampe", "hurensohn",
        "wichser", "idiot", "miststueck", "verpiss dich",

        // Portuguese (Brazil & Portugal)
        "golpe", "fraude", "merda", "puta", "caralho", "porra", "filho da puta",
        "otario", "babaca", "estelionato", "corno",

        // Arabic (Arabizi & Transliterated)
        "nasb", "ehteyal", "kelb", "khara", "sharmouta", "ahbal", "kazzab",

        // Indic (Hindi & Bengali)
        "harami", "kamina", "kutta", "chutiya", "madarchod", "bhenchod",
        "gand", "bokachoda", "chup", "shala", "gali", "chor", "dhoka"
    )
}
