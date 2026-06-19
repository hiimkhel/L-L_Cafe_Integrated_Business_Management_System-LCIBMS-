package com.example.lcibms

import io.flutter.enbedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

classMainActivity : FlutterActivity(){
    private val CHANNEL = 'lcibms/printer'

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine){
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method){
                "printTest" -> {
                    results.success("received")
                }

                else -> result.notImplemented()
            }

        }
    }    
}
