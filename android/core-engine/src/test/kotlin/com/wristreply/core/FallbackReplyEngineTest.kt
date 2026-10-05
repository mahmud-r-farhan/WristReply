package com.wristreply.core

import com.wristreply.core.nlp.FallbackReplyEngine
import com.wristreply.core.nlp.LanguageReplyBanks
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class FallbackReplyEngineTest {

    @Test
    fun `user custom pills take precedence over locale detection`() {
        val custom = listOf("Custom 1", "Custom 2", "Custom 3")
        val result = FallbackReplyEngine.resolveFallback(
            incomingText = "Hey where are you?",
            userCustomPills = custom
        )
        assertEquals(3, result.size)
        assertEquals("Custom 1", result[0])
    }

    @Test
    fun `Spanish pattern triggers Spanish fallback`() {
        val result = FallbackReplyEngine.resolveFallback(
            incomingText = "Hola amigo, donde estas?",
            applyChronoBias = false,
        )
        assertTrue(result.isNotEmpty())
        assertTrue(
            "Expected Spanish tokens in $result",
            result.any { it.contains("camino", ignoreCase = true) || it.contains("bien", ignoreCase = true) },
        )
    }

    @Test
    fun `German pattern triggers German fallback`() {
        val result = FallbackReplyEngine.resolveFallback(
            incomingText = "Hallo, wo bist du?",
            applyChronoBias = false,
        )
        assertTrue(result.isNotEmpty())
        assertTrue(
            "Expected German tokens in $result",
            result.any { it.contains("unterwegs", ignoreCase = true) || it.contains("klar", ignoreCase = true) },
        )
    }

    @Test
    fun `Arabic script triggers Arabic fallback`() {
        val result = FallbackReplyEngine.resolveFallback(
            incomingText = "وينك يا غالي؟",
            applyChronoBias = false,
        )
        assertTrue(result.isNotEmpty())
        assertTrue(
            "Expected Arabic tokens in $result",
            result.any { it.contains("الطريق") || it.contains("تمام") },
        )
    }

    @Test
    fun `Bengali script triggers Bengali fallback`() {
        val result = FallbackReplyEngine.resolveFallback(
            incomingText = "কেমন আছো?",
            applyChronoBias = false,
        )
        assertTrue(result.isNotEmpty())
        assertTrue(
            "Expected Bengali tokens in $result",
            result.any { it.contains("হ্যাঁ") || it.contains("কথা বলছি") },
        )
    }

    @Test
    fun `professional tone swaps casual banks for pro banks`() {
        val casual = FallbackReplyEngine.resolveFallback("Hola amigo", tone = "casual", applyChronoBias = false)
        val pro = FallbackReplyEngine.resolveFallback("Hola amigo", tone = "professional", applyChronoBias = false)
        assertTrue(casual.isNotEmpty() && pro.isNotEmpty())
        assertTrue("Casual vs professional should produce different lists", casual != pro)
    }

    @Test
    fun `empty user pills fall through to engine`() {
        val result = FallbackReplyEngine.resolveFallback(
            incomingText = "Unknown language text",
            userCustomPills = emptyList(),
            applyChronoBias = false,
        )
        assertTrue(result.isNotEmpty())
    }

    @Test
    fun `chrono bias off always reaches the daytime locale banks`() {
        // Regression guard: the late-night bias reads the wall clock, so every
        // locale assertion above pins applyChronoBias = false. Without that the
        // suite silently switched banks between 23:00 and 06:59 and went red.
        val daytime = FallbackReplyEngine.resolveFallback(
            incomingText = "Hola amigo, donde estas?",
            applyChronoBias = false,
        )
        assertEquals(LanguageReplyBanks.SPANISH_CASUAL, daytime)
    }

    @Test
    fun `greeting intent triggers greeting replies`() {
        val casual = FallbackReplyEngine.resolveFallback("Hey there!", applyChronoBias = false)
        assertEquals(com.wristreply.core.nlp.IntentReplyBanks.GREETING_CASUAL, casual)

        val pro = FallbackReplyEngine.resolveFallback("Good morning team", tone = "professional", applyChronoBias = false)
        assertEquals(com.wristreply.core.nlp.IntentReplyBanks.GREETING_PRO, pro)
    }

    @Test
    fun `well-being intent triggers wellbeing replies`() {
        val casual = FallbackReplyEngine.resolveFallback("How are you doing today?", applyChronoBias = false)
        assertEquals(com.wristreply.core.nlp.IntentReplyBanks.WELLBEING_CASUAL, casual)
    }

    @Test
    fun `gratitude intent triggers gratitude replies`() {
        val casual = FallbackReplyEngine.resolveFallback("Thank you so much!", applyChronoBias = false)
        assertEquals(com.wristreply.core.nlp.IntentReplyBanks.GRATITUDE_CASUAL, casual)
    }

    @Test
    fun `schedule intent triggers schedule replies`() {
        val casual = FallbackReplyEngine.resolveFallback("Can we schedule a call later?", applyChronoBias = false)
        assertEquals(com.wristreply.core.nlp.IntentReplyBanks.SCHEDULE_CASUAL, casual)
    }

    @Test
    fun `question mark triggers question replies`() {
        val casual = FallbackReplyEngine.resolveFallback("Are you ready for the deployment?", applyChronoBias = false)
        assertEquals(com.wristreply.core.nlp.IntentReplyBanks.QUESTION_CASUAL, casual)
    }

    @Test
    fun `forced language tone override triggers corresponding bank`() {
        val spanish = FallbackReplyEngine.resolveFallback("Some neutral message", tone = "spanish", applyChronoBias = false)
        assertEquals(LanguageReplyBanks.SPANISH_CASUAL, spanish)

        val german = FallbackReplyEngine.resolveFallback("Some neutral message", tone = "german", applyChronoBias = false)
        assertEquals(LanguageReplyBanks.GERMAN_CASUAL, german)
    }
}

