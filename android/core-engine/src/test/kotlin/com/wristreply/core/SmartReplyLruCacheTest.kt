package com.wristreply.core

import com.wristreply.core.cache.SmartReplyLruCache
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

/** Unit tests for the ephemeral LRU cache used to deduplicate message bursts. */
class SmartReplyLruCacheTest {

    @After
    fun tearDown() {
        SmartReplyLruCache.clear()
    }

    @Test
    fun `cache hit returns stored suggestions`() {
        SmartReplyLruCache.put("Hello there!", listOf("Hi!", "Hello!"))
        val cached = SmartReplyLruCache.get("Hello there!")
        assertEquals(listOf("Hi!", "Hello!"), cached)
    }

    @Test
    fun `cache miss returns null`() {
        assertNull(SmartReplyLruCache.get("nothing here"))
    }

    @Test
    fun `cache key is case insensitive`() {
        SmartReplyLruCache.put("Hello World", listOf("Hi!"))
        assertEquals(listOf("Hi!"), SmartReplyLruCache.get("hello world"))
    }

    @Test
    fun `empty suggestions are not stored`() {
        SmartReplyLruCache.put("Ignored", emptyList())
        assertNull(SmartReplyLruCache.get("Ignored"))
    }

    @Test
    fun `whitespace is normalized in key`() {
        SmartReplyLruCache.put("hello    world", listOf("ok"))
        assertEquals(listOf("ok"), SmartReplyLruCache.get("  hello world  "))
    }
}