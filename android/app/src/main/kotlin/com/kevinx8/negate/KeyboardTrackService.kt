package com.kevinx8.negate

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import io.flutter.Log
import io.flutter.plugin.common.EventChannel

class KeyboardTrackService : AccessibilityService(), EventChannel.StreamHandler {
    @Volatile
    private var instance: KeyboardTrackService? = null
    private var eventSink: EventChannel.EventSink? = null
    private var mainActivity: MainActivity? = null
    private var sentence: String = ""
    private var fgAppName: String = ""

    init {
        instance = this
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null || event.eventType != AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED) return
        val textNow = event.text[0]
        val textBefore = event.beforeText
        if (textBefore.isNullOrBlank()) {
            Log.d(TAG, "Sentence done: $sentence from $fgAppName")
            if (mainActivity == null) {
                Log.d(TAG, "Activity is null oop")
            }
            mainActivity?.runOnUiThread {
                eventSink?.success("$sentence<|>$fgAppName")
            }
        }
        sentence = textNow.toString()
        fgAppName = event.packageName.toString()
        Log.d(TAG, "Keyboard input: now: $textNow before: $textBefore from: $fgAppName")

    }

    override fun onServiceConnected() {
        Log.d(TAG, "service connected")
    }

    override fun onInterrupt() {
        Log.d(TAG, "Service stopped")
    }

    companion object {
        const val TAG = "keytracker"
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        this.stopSelf()
    }

    fun getInstance(): KeyboardTrackService? {
        if (instance == null) {
            synchronized(this) {
                if (instance == null) {
                    instance = KeyboardTrackService()
                }
            }
        }
        return instance
    }

    fun setMain(main: MainActivity) {
        mainActivity = main
    }

}