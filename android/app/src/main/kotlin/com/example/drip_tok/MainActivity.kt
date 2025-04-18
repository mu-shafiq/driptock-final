package com.driptock.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import android.util.Log

class MainActivity : FlutterActivity() {
    private var deviceOrientationReceiver: BroadcastReceiver? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Register a custom BroadcastReceiver to listen for orientation changes
        deviceOrientationReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                // Handle orientation changes here
                Log.d("DeviceOrientation", "Device orientation has changed.")
            }
        }

        val filter = IntentFilter("android.intent.action.CONFIGURATION_CHANGED")
        registerReceiver(deviceOrientationReceiver, filter)
    }

    override fun onDestroy() {
        super.onDestroy()

        // Unregister the receiver to avoid memory leaks
        deviceOrientationReceiver?.let {
            unregisterReceiver(it)
            Log.d("DeviceOrientation", "BroadcastReceiver unregistered.")
        }
    }
}
