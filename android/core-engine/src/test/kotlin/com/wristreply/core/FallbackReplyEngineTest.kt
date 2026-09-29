package com.wristreply.core

import com.wristreply.core.nlp.FallbackReplyEngine
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class FallbackReplyEngineTest {

    @Test
    fun testUserCustomPillsTakePrecedence() {
        val custom = listOf("Custom 1", "Custom 2", "Custom 3")
        val result = FallbackReplyEngine.resolveFallback(
            incomingText = "Hey where are you?",
            userCustomPills = custom
        )
        assertEquals(3, result.size)
        assertEquals("Custom 1", result[0])
    }

    @Test
    fun testSpanishPatternDetection() {
        val result = FallbackReplyEngine.resolveFallback(incomingText = "Hola amigo, donde estas?")
        assertTrue(result.isNotEmpty())
        assertTrue(result.any { it.contains("camino", ignoreCase = true) || it.contains("bien", ignoreCase = true) })
    }

    @Test
    fun testGermanPatternDetection() {
        val result = FallbackReplyEngine.resolveFallback(incomingText = "Hallo, wo bist du?")
        assertTrue(result.isNotEmpty())
        assertTrue(result.any { it.contains("unterwegs", ignoreCase = true) || it.contains("klar", ignoreCase = true) })
    }

    @Test
    fun testArabicScriptDetection() {
        val result = FallbackReplyEngine.resolveFallback(incomingText = "وينك يا غالي؟")
        assertTrue(result.isNotEmpty())
        assertTrue(result.any { it.contains("الطريق") || it.contains("تمام") })
    }

    @Test
    fun testBengaliScriptDetection() {
        val result = FallbackReplyEngine.resolveFallback(incomingText = "কেমন আছো?")
        assertTrue(result.isNotEmpty())
        assertTrue(result.any { it.contains("হ্যাঁ") || it.contains("কথা বলছি") })
    }
}
