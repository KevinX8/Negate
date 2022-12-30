package com.kevinx8.negate

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity: FlutterActivity() {
    private val networkEventChannel = "platform_channel_events/logger"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val logger = KeyboardTrackService().getInstance()
        logger?.setMain(this)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, networkEventChannel)
                .setStreamHandler(logger)
        }
}
