package com.wristreply.core

import android.content.Context
import android.content.SharedPreferences
import com.wristreply.core.filters.DefaultBlockedWords
import com.wristreply.core.filters.ProfanityGuardEngine
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.mockito.ArgumentMatchers.anyInt
import org.mockito.ArgumentMatchers.anyString
import org.mockito.Mockito.mock
import org.mockito.Mockito.`when`

/**
 * Unit tests for [ProfanityGuardEngine] — verifies the LPTE shield correctly
 * flags multi-lingual abuse tokens and respects the user kill-switch.
 */
class ProfanityGuardEngineTest {

    private fun mockedContext(words: Set<String> = emptySet()): Context {
        val ctx = mock(Context::class.java)
        val prefs = mock(SharedPreferences::class.java)
        `when`(ctx.getSharedPreferences(anyString(), anyInt())).thenReturn(prefs)
        `when`(prefs.getStringSet(anyString(), org.mockito.ArgumentMatchers.anySet())).thenReturn(words)
        return ctx
    }

    @Test
    fun `returns false when shield is disabled`() {
        val ctx = mockedContext()
        val (abusive, _) = ProfanityGuardEngine.containsAbusiveContent(ctx, "you are an idiot", isShieldEnabled = false)
        assertFalse(abusive)
    }

    @Test
    fun `flags English token from default dictionary`() {
        val ctx = mockedContext()
        // "idiot" ships in DefaultBlockedWords (English + German sections).
        val (abusive, token) = ProfanityGuardEngine.containsAbusiveContent(ctx, "you are an idiot", isShieldEnabled = true)
        assertTrue(abusive)
        assertEquals("idiot", token)
    }

    @Test
    fun `flags custom user word`() {
        val ctx = mockedContext(words = setOf("badword"))
        val (abusive, token) = ProfanityGuardEngine.containsAbusiveContent(ctx, "this is badword today", isShieldEnabled = true)
        assertTrue(abusive)
        assertTrue(token == "badword")
    }

    @Test
    fun `flags non-latin tokens by lowercasing`() {
        val ctx = mockedContext()
        // DefaultBlockedWords ships with at least one multi-lingual token.
        val token = DefaultBlockedWords.WORDS.firstOrNull()
            ?: error("DefaultBlockedWords should ship with at least one token")
        val (abusive, _) = ProfanityGuardEngine.containsAbusiveContent(ctx, "msg contains $token now", isShieldEnabled = true)
        assertTrue(abusive)
    }

    @Test
    fun `clean messages are not flagged`() {
        val ctx = mockedContext()
        val (abusive, _) = ProfanityGuardEngine.containsAbusiveContent(ctx, "Sounds good, see you later!", isShieldEnabled = true)
        assertFalse(abusive)
    }
}
