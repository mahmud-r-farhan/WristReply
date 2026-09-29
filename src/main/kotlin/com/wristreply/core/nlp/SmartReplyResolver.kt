package com.wristreply.core.nlp

import com.wristreply.core.cache.SmartReplyLruCache
import com.wristreply.core.cache.UserPreferencesHotCache
import com.wristreply.core.metrics.MetricsLedger

/**
 * Resolves smart replies via LRU cache, on-device ML Kit, or multi-lingual fallbacks.
 */
object SmartReplyResolver {

    suspend fun resolve(
        contextText: String,
        senderName: String,
        prefsCache: UserPreferencesHotCache
    ): List<String> {
        val startTime = System.currentTimeMillis()
        val cached = SmartReplyLruCache.get(contextText)
        if (cached != null) {
            MetricsLedger.recordInference(System.currentTimeMillis() - startTime, isCacheHit = true)
            return cached
        }

        val fresh = EphemeralMLKitEngine.suggestReplies(contextText, senderName)
        val resolved = if (fresh.isNotEmpty()) fresh else {
            FallbackReplyEngine.resolveFallback(
                incomingText = contextText,
                userCustomPills = prefsCache.getCustomFallbackPills(),
                tone = prefsCache.getConversationTone(),
                applyChronoBias = prefsCache.isChronoBiasEnabled()
            )
        }
        SmartReplyLruCache.put(contextText, resolved)
        MetricsLedger.recordInference(System.currentTimeMillis() - startTime, isCacheHit = false)
        return resolved
    }
}
