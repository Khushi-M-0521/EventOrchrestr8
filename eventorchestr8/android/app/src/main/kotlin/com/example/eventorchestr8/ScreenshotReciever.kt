package com.example.eventorchestr8

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler 
import android.os.Looper
import android.widget.Toast

class ScreenshotReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Handler(Looper.getMainLooper()).post { 
            Toast.makeText(context, "Screenshots are not allowed.", Toast.LENGTH_LONG).show() 
        }
    }
}
