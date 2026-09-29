package com.wristreply.core.nlp

import android.content.Context
import com.wristreply.core.cache.SmartReplyLruCache
import com.wristreply.core.cache.UserPreferencesHotCache
import com.wristreply.core.context.ContextualReplyEnhancer
import com.wristreply.core.metrics.MetricsLedger

/**
 * Resolves smart replies via LRU cache, on-device ML Kit, or multi-lingual fallbacks,
 * and enhances with real-time driving / meeting context.
 */
object SmartReplyResolver {

    suspend fun resolve(
        context: Context,
        contextText: String,
        senderName: String,
        prefsCache: UserPreferencesHotCache
    ): List<String> {
        val startTime = System.currentTimeMillis()
        val cached = SmartReplyLruCache.get(contextText)
        val baseReplies = if (cached != null) {
            MetricsLedger.recordInference(System.currentTimeMillis() - startTime, isCacheHit = true)
            cached
        } else {
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
            resolved
        }

        return ContextualReplyEnhancer.enhanceSuggestions(context, baseReplies, prefsCache, contextText)
    }
}
