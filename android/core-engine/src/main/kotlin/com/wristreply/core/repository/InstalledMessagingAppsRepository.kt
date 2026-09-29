package com.wristreply.core.repository

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import com.wristreply.core.model.DiscoveredAppInfo
import com.wristreply.core.model.PrefKeys
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Discovers installed communication and messaging clients dynamically
 * and maintains per-application whitelist toggles.
 */
class InstalledMessagingAppsRepository(private val context: Context) {

    private val prefs = context.getSharedPreferences(PrefKeys.PREFS_WHITELIST, Context.MODE_PRIVATE)

    suspend fun getInstalledMessagingClients(): List<DiscoveredAppInfo> = withContext(Dispatchers.IO) {
        val pm = context.packageManager
        val discoveredList = mutableListOf<DiscoveredAppInfo>()

        val smsIntent = Intent(Intent.ACTION_SENDTO).apply {
            data = Uri.parse("smsto:")
        }
        val resolveInfos = pm.queryIntentActivities(smsIntent, PackageManager.MATCH_DEFAULT_ONLY)
        val candidatePackages = resolveInfos.map { it.activityInfo.packageName }.toMutableSet()

        candidatePackages.addAll(listOf(
            "com.whatsapp",
            "com.whatsapp.w4b",
            "org.telegram.messenger",
            "org.telegram.plus",
            "com.facebook.orca",
            "com.google.android.apps.messaging",
            "org.thoughtcrime.securesms",
            "com.discord",
            "com.slack"
        ))

        for (pkg in candidatePackages) {
            try {
                val appInfo = pm.getApplicationInfo(pkg, 0)
                val label = pm.getApplicationLabel(appInfo).toString()
                val isWhitelisted = prefs.getBoolean(pkg, true)
                discoveredList.add(DiscoveredAppInfo(pkg, label, isWhitelisted))
            } catch (_: PackageManager.NameNotFoundException) {}
        }

        discoveredList.distinctBy { it.packageName }.sortedBy { it.appName }
    }

    fun isAppWhitelisted(packageName: String): Boolean = prefs.getBoolean(packageName, true)

    fun setAppWhitelisted(packageName: String, enabled: Boolean) {
        prefs.edit().putBoolean(packageName, enabled).apply()
    }
}
