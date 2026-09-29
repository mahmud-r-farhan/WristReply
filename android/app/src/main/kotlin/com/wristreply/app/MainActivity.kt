package com.wristreply.app

import androidx.lifecycle.lifecycleScope
import com.wristreply.app.bridge.NativeBridgeHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Host Activity for Flutter presentation layer.
 * Instantiated ONLY when user interacts with the app; destroyed on app exit
 * so Flutter never runs in the background.
 */
class MainActivity : FlutterActivity() {

    private val channelName = "com.wristreply.app/engine"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel.setMethodCallHandler(NativeBridgeHandler(applicationContext, lifecycleScope))
    }
}
