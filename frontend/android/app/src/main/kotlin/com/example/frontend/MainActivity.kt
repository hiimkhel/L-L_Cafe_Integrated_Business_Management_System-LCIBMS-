package com.example.frontend

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity : FlutterActivity() {

    private val CHANNEL = "lcibms/printer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Log.d("LCIBMS", "MainActivity loaded successfully")

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                when (call.method) {
                    "printTest" -> {
                        Log.d("LCIBMS", "printTest triggered")
                        result.success("OK from Android")
                    }
                    else -> result.notImplemented()
                }
            }
    }
}