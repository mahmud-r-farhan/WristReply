package com.wristreply.app.bridge

import android.content.Context
import android.content.Intent
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import com.wristreply.core.metrics.MetricsLedger
import com.wristreply.core.nlp.EphemeralMLKitEngine
import com.wristreply.core.nlp.FallbackReplyEngine
import com.wristreply.core.repository.InstalledMessagingAppsRepository
import com.wristreply.core.repository.OemKeepAliveManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/**
 * Handles MethodChannel requests from the Flutter UI and bridges them
 * to the headless Core Engine and Android SharedPreferences.
 */
class NativeBridgeHandler(private val context: Context, private val scope: CoroutineScope) : MethodChannel.MethodCallHandler {

    private val prefRepo = PreferenceRepository(context)
    private val appsRepo = InstalledMessagingAppsRepository(context)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isListenerRunning" -> {
                val enabled = NotificationManagerCompat.getEnabledListenerPackages(context).contains(context.packageName)
                result.success(enabled)
            }
            "requestListenerPermission" -> {
                val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                context.startActivity(intent)
                result.success(true)
            }
            "isBatteryOptimizationIgnored" -> {
                result.success(OemKeepAliveManager.isIgnoringBatteryOptimizations(context))
            }
            "requestBatteryExemption" -> {
                OemKeepAliveManager.requestIgnoreBatteryOptimizations(context)
                result.success(true)
            }
            "openOemAutostart" -> {
                result.success(OemKeepAliveManager.openOemAutostartSettings(context))
            }
            "getDiscoveredApps" -> {
                scope.launch(Dispatchers.Main) {
                    val apps = appsRepo.getInstalledMessagingClients().map {
                        mapOf("packageName" to it.packageName, "appName" to it.appName, "isEnabled" to it.isEnabled)
                    }
                    result.success(apps)
                }
            }
            "setAppWhitelisted" -> {
                val pkg = call.argument<String>("packageName") ?: ""
                val enabled = call.argument<Boolean>("enabled") ?: true
                appsRepo.setAppWhitelisted(pkg, enabled)
                result.success(true)
            }
            "getEngineMetrics" -> {
                val m = MetricsLedger.getMetrics()
                result.success(mapOf(
                    "repliesDispatched" to m.repliesDispatched,
                    "avgLatencyMs" to m.avgLatencyMs,
                    "cacheHits" to m.cacheHits,
                    "isActive" to m.isActive
                ))
            }
            "resetEngineMetrics" -> {
                MetricsLedger.reset()
                result.success(true)
            }
            "simulateSmartReply" -> {
                val text = call.argument<String>("messageText") ?: ""
                scope.launch(Dispatchers.Main) {
                    val mlReplies = EphemeralMLKitEngine.suggestReplies(text, "Tester")
                    val replies = if (mlReplies.isNotEmpty()) mlReplies else {
                        FallbackReplyEngine.resolveFallback(text)
                    }
                    result.success(replies)
                }
            }
            "getPreferences" -> result.success(prefRepo.getAllPreferences())
            "updatePreference" -> {
                val key = call.argument<String>("key") ?: ""
                val value = call.argument<Any>("value")
                when (value) {
                    is Boolean -> prefRepo.updateBoolean(key, value)
                    is String -> prefRepo.updateString(key, value)
                    is Int -> prefRepo.updateInt(key, value)
                    is List<*> -> @Suppress("UNCHECKED_CAST") prefRepo.updateStringList(key, value as List<String>)
                }
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }
}
