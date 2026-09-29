package com.wristreply.core.service

import android.content.ComponentName
import android.os.Build
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import com.wristreply.core.cache.SmartReplyLruCache
import com.wristreply.core.cache.UserPreferencesHotCache
import com.wristreply.core.filters.ProfanityGuardEngine
import com.wristreply.core.filters.SmartTokenExtractor
import com.wristreply.core.guard.MessageDebounceBuffer
import com.wristreply.core.guard.ReadActionResolver
import com.wristreply.core.guard.SleepWindowGate
import com.wristreply.core.inspector.DynamicNotificationInspector
import com.wristreply.core.inspector.NotificationGate
import com.wristreply.core.metrics.MetricsLedger
import com.wristreply.core.nlp.EphemeralMLKitEngine
import com.wristreply.core.nlp.FallbackReplyEngine
import com.wristreply.core.publisher.NotificationAlertHelper
import com.wristreply.core.publisher.NotificationPublisher
import com.wristreply.core.wear.WearSyncService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

/**
 * Pure headless Kotlin daemon running as an isolated NotificationListenerService.
 * Operates at 15MB-25MB RAM with 0% idle CPU and zero Flutter background overhead.
 */
class NotificationProcessorService : NotificationListenerService() {

    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private lateinit var prefsCache: UserPreferencesHotCache

    override fun onCreate() {
        super.onCreate()
        prefsCache = UserPreferencesHotCache(applicationContext)
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        val activeSbn = sbn ?: return

        if (!NotificationGate.shouldProcess(activeSbn)) return
        if (!prefsCache.isMasterEnabled()) return
        if (SleepWindowGate.shouldSuppressProcessing(applicationContext)) return
        if (!prefsCache.isAppWhitelisted(activeSbn.packageName)) return

        val text = activeSbn.notification.extras.getCharSequence(android.app.Notification.EXTRA_TEXT)?.toString() ?: return
        val sender = activeSbn.notification.extras.getCharSequence(android.app.Notification.EXTRA_TITLE)?.toString() ?: "User"

        // 1. LPTE Profanity Filter
        val (isAbusive, matchedToken) = ProfanityGuardEngine.containsAbusiveContent(
            context = applicationContext,
            text = text,
            isShieldEnabled = prefsCache.isProfanityShieldEnabled()
        )
        if (isAbusive) {
            NotificationAlertHelper.postAbuseWarning(applicationContext, sender, matchedToken ?: "")
            return
        }

        // 2. Financial Token & OTP Auto-Copy
        val token = SmartTokenExtractor.scanAndExtract(text, prefsCache.isAutoCopyTrx(), prefsCache.isAutoCopyOtp())
        if (token != null) {
            SmartTokenExtractor.copyToClipboard(applicationContext, token)
            NotificationAlertHelper.postCopyConfirmation(applicationContext, token.type, token.value)
        }

        // 3. Dynamic Inline-Reply Extraction
        val replyTarget = DynamicNotificationInspector.resolveReplyTarget(activeSbn) ?: return
        val readAction = ReadActionResolver.extractMarkAsReadAction(activeSbn.notification)

        // 4. Debounced burst ingestion
        MessageDebounceBuffer.enqueueMessage(serviceScope, replyTarget.senderName, replyTarget.messageText) { combinedContext ->
            serviceScope.launch {
                processAndPublish(activeSbn, replyTarget, combinedContext, readAction)
            }
        }
    }

    private suspend fun processAndPublish(
        sbn: StatusBarNotification,
        target: com.wristreply.core.model.DynamicReplyTarget,
        contextText: String,
        readAction: android.app.Notification.Action?
    ) {
        val startTime = System.currentTimeMillis()
        val cached = SmartReplyLruCache.get(contextText)
        val suggestions = if (cached != null) {
            MetricsLedger.recordInference(System.currentTimeMillis() - startTime, isCacheHit = true)
            cached
        } else {
            val fresh = EphemeralMLKitEngine.suggestReplies(contextText, target.senderName)
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

        if (suggestions.isEmpty()) return

        // 5. Replace Mode vs Silent Companion Mode
        if (prefsCache.isReplaceMode()) {
            try { cancelNotification(sbn.key) } catch (_: Exception) {}
        }

        NotificationPublisher.publishPills(
            context = applicationContext,
            notificationId = sbn.id,
            target = target,
            suggestions = suggestions.take(prefsCache.getPillsPerMessage()),
            readAction = readAction,
            isPrivacyMode = prefsCache.isPrivacyMode(),
            appendLocationPin = prefsCache.isLocationPinEnabled()
        )

        WearSyncService.broadcastToWatch(applicationContext, suggestions, sbn.id)
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        super.onNotificationRemoved(sbn)
        sbn?.let {
            NotificationPublisher.cancelCompanion(applicationContext, it.id)
            val sender = it.notification?.extras?.getCharSequence(android.app.Notification.EXTRA_TITLE)?.toString()
            if (sender != null) MessageDebounceBuffer.clearBuffer(sender)
        }
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            requestRebind(ComponentName(this, NotificationProcessorService::class.java))
        }
    }
}
