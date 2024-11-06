package com.example.eventorchestr8

import android.os.Bundle
import android.content.Intent
import android.content.IntentFilter
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity(){
    private val CHANNEL = "com.example.eventorchestr8/secure_screen"
    private lateinit var receiver: ScreenshotReceiver

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setupMethodChannel(flutterEngine!!.dartExecutor.binaryMessenger)

        // Register the BroadcastReceiver
        val filter = IntentFilter(Intent.ACTION_USER_PRESENT)
        registerReceiver(ScreenshotReceiver(), filter)
    }

    private fun setupMethodChannel(messenger: BinaryMessenger) { 
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result -> 
            when (call.method) { 
                "enableSecureScreen" -> { 
                    window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE) 
                    result.success(null) 
                } 
                "disableSecureScreen" -> { 
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE) 
                    result.success(null) 
                } else -> result.notImplemented() 
            }
        }
    }

    override fun onDestroy() { 
        super.onDestroy() 
        unregisterReceiver(receiver)
    }
}
