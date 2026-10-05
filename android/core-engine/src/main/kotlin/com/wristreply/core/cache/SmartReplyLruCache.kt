package com.wristreply.core.cache

/** One cached reply bundle plus the wall-clock time it was stored. */
data class CachedReplies(
    val suggestions: List<String>,
    val timestamp: Long = System.currentTimeMillis()
)

/**
 * High-efficiency ephemeral RAM-only LRU cache for deduplicating message bursts.
 *
 * Zero disk persistence; entries auto-expire after 5 minutes.
 *
 * The cache is deliberately implemented on top of [LinkedHashMap] in
 * access-order mode instead of `android.util.LruCache`. Two reasons:
 *  1. It keeps this class pure JVM, so the engine's caching behaviour can be
 *     covered by plain JUnit tests (`:core-engine:testDebugUnitTest`) without
 *     a Robolectric runtime or an instrumented device.
 *  2. It removes a framework dependency from a class that has no business
 *     touching the Android runtime, which keeps `:core-engine` embeddable.
 *
 * Every public entry point is [Synchronized] because access-ordered
 * [LinkedHashMap] mutates internal state on reads as well as writes.
 */
object SmartReplyLruCache {

    private const val MAX_ENTRIES = 30
    private const val TTL_MILLIS = 5 * 60 * 1000L

    private val cache = object : LinkedHashMap<String, CachedReplies>(16, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, CachedReplies>): Boolean =
            size > MAX_ENTRIES
    }

    /** Returns the cached suggestions for [message], or null on miss / expiry. */
    @Synchronized
    fun get(message: String): List<String>? {
        val key = normalizeKey(message)
        val entry = cache[key] ?: return null

        if (System.currentTimeMillis() - entry.timestamp > TTL_MILLIS) {
            cache.remove(key)
            return null
        }
        return entry.suggestions
    }

    /** Stores [suggestions] for [message]. Empty suggestion lists are ignored. */
    @Synchronized
    fun put(message: String, suggestions: List<String>) {
        if (suggestions.isEmpty()) return
        val key = normalizeKey(message)
        cache[key] = CachedReplies(suggestions)
    }

    /** Drops every cached entry. Used by tests and by the "reset engine" action. */
    @Synchronized
    fun clear() {
        cache.clear()
    }

    /** Number of entries currently held in memory. Exposed for diagnostics/tests. */
    @Synchronized
    fun size(): Int = cache.size

    private fun normalizeKey(rawText: String): String {
        return rawText.trim().lowercase().replace("\\s+".toRegex(), " ")
    }
}
