package com.wristreply.core.context

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationManager
import androidx.core.content.ContextCompat

/**
 * Resolves location-pin action payloads using on-device location sensors.
 * Produces standard Google Maps links when location permission is granted.
 */
object LocationProviderHelper {

    fun resolveDispatchText(context: Context, replyText: String): String {
        if (!replyText.startsWith("[📍")) return replyText

        if (!hasLocationPermission(context)) {
            return "📍 On my way, sharing location shortly."
        }

        val location = getLastKnownLocation(context)
        return if (location != null) {
            "📍 https://maps.google.com/?q=${location.latitude},${location.longitude}"
        } else {
            "📍 On my way, sharing location shortly."
        }
    }

    private fun hasLocationPermission(context: Context): Boolean {
        val fine = ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION)
        val coarse = ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION)
        return fine == PackageManager.PERMISSION_GRANTED || coarse == PackageManager.PERMISSION_GRANTED
    }

    private fun getLastKnownLocation(context: Context): Location? {
        val manager = context.getSystemService(Context.LOCATION_SERVICE) as? LocationManager ?: return null
        val providers = listOf(
            LocationManager.PASSIVE_PROVIDER,
            LocationManager.NETWORK_PROVIDER,
            LocationManager.GPS_PROVIDER
        )

        for (provider in providers) {
            try {
                val loc = manager.getLastKnownLocation(provider)
                if (loc != null) return loc
            } catch (_: SecurityException) {}
        }
        return null
    }
}
