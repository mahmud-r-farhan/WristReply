package com.wristreply.core

import android.content.Context
import com.wristreply.core.cache.UserPreferencesHotCache
import com.wristreply.core.metrics.MetricsLedger
import com.wristreply.core.model.EngineMetrics
import com.wristreply.core.repository.InstalledMessagingAppsRepository

/**
 * Public 5-line entry point for any Android app that wants to embed the
 * WristReply headless engine without depending on the Flutter runtime.
 *
 * Example:
 * ```
 * // In your Application.onCreate
 * EngineBootstrap.initialize(this)
 * // That's it — notifications will start receiving reply pills.
 * ```
 *
 * The bootstrap is idempotent and safe to call from multiple processes.
 */
object EngineBootstrap {

    @Volatile
    private var initialized: Boolean = false

    /**
     * Initializes the in-memory preference cache and metric ledger.
     *
     * The notification listener service is registered declaratively via the
     * manifest — there is nothing to start at runtime.
     */
    @Synchronized
    fun initialize(context: Context) {
        if (initialized) return
        // Warm the cache so the first notification doesn't pay the disk-read cost.
        UserPreferencesHotCache(context.applicationContext)
        initialized = true
    }

    /**
     * Convenience helper for native library consumers who want to query the
     * engine's current metrics without going through the Flutter MethodChannel.
     */
    fun metrics(): EngineMetrics = MetricsLedger.getMetrics()

    /**
     * Reset all in-memory metrics. Useful for QA sessions.
     */
    fun resetMetrics() = MetricsLedger.reset()

    /**
     * Returns the list of installed messaging clients visible to the
     * NotificationListenerService. Equivalent to
     * `NativeBridge.getDiscoveredApps()` on the Flutter side.
     */
    suspend fun discoveredApps(context: Context): List<com.wristreply.core.model.DiscoveredAppInfo> =
        InstalledMessagingAppsRepository(context.applicationContext).getInstalledMessagingClients()
}
