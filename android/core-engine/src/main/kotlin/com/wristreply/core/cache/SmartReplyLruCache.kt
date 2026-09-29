package com.wristreply.core.cache

import android.util.LruCache

data class CachedReplies(
    val suggestions: List<String>,
    val timestamp: Long = System.currentTimeMillis()
)

/**
 * High-efficiency ephemeral RAM-only LRU cache for deduplicating message bursts.
 * Zero disk persistence; entries auto-expire after 5 minutes.
 */
object SmartReplyLruCache {

    private const val MAX_ENTRIES = 30
    private const val TTL_MILLIS = 5 * 60 * 1000L

    private val cache = object : LruCache<String, CachedReplies>(MAX_ENTRIES) {
        override fun sizeOf(key: String, value: CachedReplies): Int = 1
    }

    @Synchronized
    fun get(message: String): List<String>? {
        val key = normalizeKey(message)
        val entry = cache.get(key) ?: return null

        if (System.currentTimeMillis() - entry.timestamp > TTL_MILLIS) {
            cache.remove(key)
            return null
        }
        return entry.suggestions
    }

    @Synchronized
    fun put(message: String, suggestions: List<String>) {
        if (suggestions.isEmpty()) return
        val key = normalizeKey(message)
        cache.put(key, CachedReplies(suggestions))
    }

    @Synchronized
    fun clear() {
        cache.evictAll()
    }

    private fun normalizeKey(rawText: String): String {
        return rawText.trim().lowercase().replace("\\s+".toRegex(), " ")
    }
}
