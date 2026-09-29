package com.wristreply.core.nlp

/**
 * Curated quick reply banks for dominant smartwatch markets:
 * English, Spanish, German, Portuguese, French, Arabic, Hindi, and Bengali.
 */
object LanguageReplyBanks {

    // English (Global / Primary)
    val ENGLISH_CASUAL = listOf("Sounds good!", "On my way!", "Can't talk now, text later.")
    val ENGLISH_PRO = listOf("Understood, looking into it.", "I will update you shortly.", "Noted with thanks.")
    val ENGLISH_LATE_NIGHT = listOf("Asleep, talk tomorrow", "Can it wait till morning?", "Good night")

    // Spanish (LatAm & Spain)
    val SPANISH_CASUAL = listOf("¡Dale, suena bien!", "¡Voy en camino!", "No puedo hablar ahora, te escribo.")
    val SPANISH_PRO = listOf("Entendido, lo reviso ahora.", "Te confirmo en un momento.", "Quedo al pendiente.")
    val SPANISH_LATE_NIGHT = listOf("Ya estoy durmiendo, hablamos mañana", "¿Puede esperar a mañana?", "Buenas noches")

    // German (DACH)
    val GERMAN_CASUAL = listOf("Alles klar!", "Bin unterwegs!", "Kann gerade nicht, melde mich später.")
    val GERMAN_PRO = listOf("Verstanden, ich prüfe das.", "Ich gebe Ihnen gleich Bescheid.", "Vielen Dank.")

    // Portuguese (Brazil & Portugal)
    val PORTUGUESE_CASUAL = listOf("Beleza, combinado!", "Estou a caminho!", "Não posso falar agora, te ligo já.")
    val PORTUGUESE_PRO = listOf("Entendido, já estou verificando.", "Retorno em breve.", "Muito obrigado.")

    // French (France & Canada)
    val FRENCH_CASUAL = listOf("Ça marche !", "Je suis en route !", "Occupé pour le moment, je te rappelle.")
    val FRENCH_PRO = listOf("C'est bien noté, je m'en occupe.", "Je reviens vers vous rapidement.", "Merci bien.")

    // Arabic (Gulf & MENA)
    val ARABIC_CASUAL = listOf("تمام، إن شاء الله!", "أنا في الطريق!", "مشغول الآن، بكلمك بعدين.")
    val ARABIC_PRO = listOf("تم الاستلام، سأوافيك بالتفاصيل قريباً.", "شكراً جزيلاً.", "سأتواصل معك في أقرب وقت.")

    // Indic (Hindi & Hinglish)
    val HINDI_CASUAL = listOf("Theek hai, badhiya!", "Raste me hu!", "Abhi thoda busy hu, baad me call karta hu.")
    val HINDI_DEVANAGARI = listOf("हाँ, बिल्कुल!", "रास्ते में हूँ!", "थोड़ी देर में बात करता हूँ।")

    // Bengali & Banglish
    val BENGALI_SCRIPT = listOf("হ্যাঁ, ঠিক আছে!", "আমি রাস্তায় আছি!", "একটু পর কথা বলছি।")
    val BANGLISH_CASUAL = listOf("Astechi 5 min e", "Ekhon ektu busy achi", "Call dao ektu por")
}
