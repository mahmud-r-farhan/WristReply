package com.wristreply.core.service

import android.content.ComponentName
import android.os.Build
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import com.wristreply.core.automation.DelayedReplyScheduler
import com.wristreply.core.cache.UserPreferencesHotCache
import com.wristreply.core.filters.ProfanityGuardEngine
import com.wristreply.core.filters.SmartTokenExtractor
import com.wristreply.core.guard.MessageDebounceBuffer
import com.wristreply.core.guard.ReadActionResolver
import com.wristreply.core.guard.SleepWindowGate
import com.wristreply.core.inspector.DynamicNotificationInspector
import com.wristreply.core.inspector.NotificationGate
import com.wristreply.core.metrics.MetricsLedger
import com.wristreply.core.nlp.SmartReplyResolver
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
 *
 * Responsibilities:
 *  1. Validate incoming notifications (NotificationGate).
 *  2. Run abuse interception (LPTE).
 *  3. Extract and auto-copy OTPs / transaction IDs.
 *  4. Debounce rapid-fire message bursts into a single contextual prompt.
 *  5. Schedule delayed auto-replies (AlarmManager-based).
 *  6. Invoke the SmartReplyResolver to compute pills.
 *  7. Publish a silent companion notification containing the pills.
 *  8. Mirror to Wear OS / Zepp OS via local broadcast.
 *
 * The service also ensures the smart-reply channel exists at least once on
 * startup so the very first notification is rendered correctly.
 */
class NotificationProcessorService : NotificationListenerService() {

    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private lateinit var prefsCache: UserPreferencesHotCache

    override fun onCreate() {
        super.onCreate()
        prefsCache = UserPreferencesHotCache(applicationContext)
        // Pre-create channels so the first notification isn't dropped.
        NotificationPublisher.ensureChannel(applicationContext)
        NotificationAlertHelper.ensureAlertChannel(applicationContext)
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        val activeSbn = sbn ?: return

        if (!NotificationGate.shouldProcess(activeSbn)) return
        if (!prefsCache.isMasterEnabled()) return
        if (SleepWindowGate.shouldSuppressProcessing(applicationContext)) return
        if (!prefsCache.isAppWhitelisted(activeSbn.packageName)) return

        val text = activeSbn.notification.extras
            .getCharSequence(android.app.Notification.EXTRA_TEXT)
            ?.toString()
            ?: return
        val sender = activeSbn.notification.extras
            .getCharSequence(android.app.Notification.EXTRA_TITLE)
            ?.toString()
            ?: "User"

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
        val token = SmartTokenExtractor.scanAndExtract(
            text = text,
            autoCopyTrx = prefsCache.isAutoCopyTrx(),
            autoCopyOtp = prefsCache.isAutoCopyOtp()
        )
        if (token != null) {
            SmartTokenExtractor.copyToClipboard(applicationContext, token)
            NotificationAlertHelper.postCopyConfirmation(applicationContext, token.type, token.value)
        }

        // 3. Dynamic Inline-Reply Extraction
        val replyTarget = DynamicNotificationInspector.resolveReplyTarget(activeSbn) ?: return
        val readAction = ReadActionResolver.extractMarkAsReadAction(activeSbn.notification)

        // 4. Automated Delayed Reply Scheduling (if enabled)
        if (prefsCache.isDelayedReplyEnabled()) {
            DelayedReplyScheduler.scheduleReply(
                context = applicationContext,
                senderId = replyTarget.senderName,
                replyText = prefsCache.getDelayedReplyTemplate(),
                originalPendingIntent = replyTarget.pendingIntent,
                resultKey = replyTarget.resultKey,
                delayMinutes = prefsCache.getDelayedReplyMinutes()
            )
        }

        // 5. Debounced burst ingestion
        MessageDebounceBuffer.enqueueMessage(
            scope = serviceScope,
            senderId = replyTarget.senderName,
            messageText = replyTarget.messageText,
            onBatchReady = { combinedContext ->
                serviceScope.launch {
                    processAndPublish(activeSbn, replyTarget, combinedContext, readAction)
                }
            }
        )
    }

    private suspend fun processAndPublish(
        sbn: StatusBarNotification,
        target: com.wristreply.core.model.DynamicReplyTarget,
        contextText: String,
        readAction: android.app.Notification.Action?
    ) {
        val suggestions = SmartReplyResolver.resolve(applicationContext, contextText, target.senderName, prefsCache)
        if (suggestions.isEmpty()) {
            // Flush any pending burst so future notifications can rebuild context.
            MessageDebounceBuffer.clearBuffer(target.senderName)
            return
        }

        // 6. Replace Mode vs Silent Companion Mode
        if (prefsCache.isReplaceMode()) {
            try {
                cancelNotification(sbn.key)
            } catch (_: Exception) {
                // cancelNotification can throw SecurityException on some Android 13+
                // builds when the original app has revoked our binder access.
            }
        }

        NotificationPublisher.publishPills(
            context = applicationContext,
            notificationId = sbn.id,
            target = target,
            suggestions = suggestions,
            readAction = readAction,
            isPrivacyMode = prefsCache.isPrivacyMode(),
            appendLocationPin = prefsCache.isLocationPinEnabled()
        )

        WearSyncService.broadcastToWatch(applicationContext, suggestions, sbn.id)
        MetricsLedger.recordDispatch()
        MessageDebounceBuffer.clearBuffer(target.senderName)
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        super.onNotificationRemoved(sbn)
        sbn?.let {
            NotificationPublisher.cancelCompanion(applicationContext, it.id)
            val sender = it.notification?.extras?.getCharSequence(android.app.Notification.EXTRA_TITLE)?.toString()
            if (sender != null) {
                MessageDebounceBuffer.clearBuffer(sender)
                DelayedReplyScheduler.cancelScheduledReply(applicationContext, sender)
            }
        }
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            requestRebind(ComponentName(this, NotificationProcessorService::class.java))
        }
    }

    override fun onDestroy() {
        serviceScope.coroutineContext[kotlinx.coroutines.Job]?.cancel()
        super.onDestroy()
    }
}
