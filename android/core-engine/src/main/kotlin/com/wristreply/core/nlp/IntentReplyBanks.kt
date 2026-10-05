package com.wristreply.core.nlp

/**
 * Curated offline quick reply banks for recognized conversational intents:
 * Greetings, Well-being checks, Gratitude, Scheduling/Calls, and Questions.
 * Operates with 0 network calls and < 1ms execution time.
 */
object IntentReplyBanks {

    val GREETING_CASUAL = listOf("Hey! What's up?", "Hello! How can I help?", "Hey there, good to hear from you!")
    val GREETING_PRO = listOf("Hello! How can I assist you today?", "Good day! Thanks for reaching out.", "Greetings! Glad to connect.")

    val WELLBEING_CASUAL = listOf("Doing great, thanks! You?", "All good on my side!", "Pretty good, keeping busy!")
    val WELLBEING_PRO = listOf("Doing well, thank you. How are things with you?", "All is progressing smoothly, thank you.", "Very well, thank you.")

    val GRATITUDE_CASUAL = listOf("You're welcome! 😊", "Anytime! Glad to help.", "No problem at all! 👍")
    val GRATITUDE_PRO = listOf("You are very welcome!", "Glad I could be of assistance.", "It was my pleasure.")

    val SCHEDULE_CASUAL = listOf("Sure thing, shoot over an invite!", "Sounds good! What time works?", "Down for a quick chat. When are you free?")
    val SCHEDULE_PRO = listOf("I would be glad to meet. Please send an invite.", "That works. What time window suits your schedule best?", "Let's sync up. Feel free to share your calendar.")

    val QUESTION_CASUAL = listOf("Yes, sounds good!", "Let me check and get back to you.", "Not sure, will let you know shortly.")
    val QUESTION_PRO = listOf("Yes, that aligns with our plans.", "I will verify and update you shortly.", "Let me review and follow up.")
}
