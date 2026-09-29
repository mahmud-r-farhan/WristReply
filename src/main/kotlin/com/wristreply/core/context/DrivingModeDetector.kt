package com.wristreply.core.context

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.content.Context
import android.os.Build

/**
 * Detects if the device is connected to a Bluetooth car audio or headset profile (A2DP / HEADSET)
 * to provide context-aware driving auto-replies.
 */
object DrivingModeDetector {

    fun isConnectedToCarOrAudio(context: Context): Boolean {
        return try {
            val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
            @Suppress("DEPRECATION")
            val adapter = bluetoothManager?.adapter ?: BluetoothAdapter.getDefaultAdapter() ?: return false
            if (!adapter.isEnabled) return false

            val a2dpState = adapter.getProfileConnectionState(BluetoothProfile.A2DP)
            val headsetState = adapter.getProfileConnectionState(BluetoothProfile.HEADSET)

            a2dpState == BluetoothProfile.STATE_CONNECTED || headsetState == BluetoothProfile.STATE_CONNECTED
        } catch (_: SecurityException) {
            // Android 12+ BLUETOOTH_CONNECT runtime permission not granted
            false
        } catch (_: Exception) {
            false
        }
    }
}
