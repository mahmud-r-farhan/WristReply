package com.wristreply.core.repository

import android.annotation.SuppressLint
import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings

/**
 * Handles OEM-specific autostart settings and Doze battery exemption requests.
 *
 * Each manufacturer we know about exposes a different autostart-management
 * activity. We attempt them in priority order — first match wins — and fall
 * back to the standard Doze exemption screen if none are present.
 */
object OemKeepAliveManager {

    /**
     * The list of known OEM autostart components.
     * Ordered roughly by global market share so the most common devices
     * succeed on the first try.
     */
    private val OEM_COMPONENTS: List<ComponentName> = listOf(
        // Xiaomi / MIUI / HyperOS
        ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"),
        // Huawei / Honor
        ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity"),
        // Oppo / Realme / ColorOS
        ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity"),
        ComponentName("com.oppo.safe", "com.oppo.safe.permission.startup.StartupAppListActivity"),
        // Vivo / Funtouch / iQOO
        ComponentName("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity"),
        ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"),
        // Transsion (Tecno / Infinix / itel)
        ComponentName("com.transsion.phonemaster", "com.transsion.phonemaster.MainActivity"),
        // Samsung (legacy)
        ComponentName("com.samsung.android.lool", "com.samsung.android.sm.ui.battery.BatteryActivity"),
        // Letv
        ComponentName("com.letv.android.letvsafe", "com.letv.android.letvsafe.AutobootManageActivity"),
        // ASUS
        ComponentName("com.asus.mobilemanager", "com.asus.mobilemanager.entry.FunctionActivity")
    )

    fun isIgnoringBatteryOptimizations(context: Context): Boolean {
        val pm = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
        return pm?.isIgnoringBatteryOptimizations(context.packageName) ?: false
    }

    @SuppressLint("BatteryLife")
    fun requestIgnoreBatteryOptimizations(context: Context) {
        try {
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = Uri.parse("package:${context.packageName}")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            return
        } catch (_: Exception) {
            // fall through to generic screen
        }
        try {
            val fallbackIntent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(fallbackIntent)
        } catch (_: Exception) {
            // Surface as no-op; user can still enable via system Settings manually.
        }
    }

    /**
     * Attempts to open the OEM-specific autostart screen. Returns `true` if
     * one of the known activities could be launched, `false` otherwise.
     */
    fun openOemAutostartSettings(context: Context): Boolean {
        val pm = context.packageManager
        for (component in OEM_COMPONENTS) {
            if (!isComponentAvailable(pm, component)) continue
            val intent = Intent().apply {
                // `this.` is required: inside `apply` a bare `component` on the
                // left resolves to the loop variable (locals shadow implicit
                // receiver members), which is a val and cannot be reassigned.
                this.component = component
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            try {
                context.startActivity(intent)
                return true
            } catch (_: ActivityNotFoundException) {
                // continue to next candidate
            } catch (_: SecurityException) {
                // component is exported but blocks us — skip
            } catch (_: Exception) {
                // generic failure — try the next OEM
            }
        }
        return false
    }

    private fun isComponentAvailable(pm: PackageManager, component: ComponentName): Boolean {
        val intent = Intent().apply { this.component = component }
        return intent.resolveActivity(pm) != null
    }
}
