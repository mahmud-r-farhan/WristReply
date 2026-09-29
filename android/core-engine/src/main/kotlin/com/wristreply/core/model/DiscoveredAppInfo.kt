package com.wristreply.core.model

/**
 * Representation of a discovered messaging application on the device.
 */
data class DiscoveredAppInfo(
    val packageName: String,
    val appName: String,
    val isEnabled: Boolean
)
