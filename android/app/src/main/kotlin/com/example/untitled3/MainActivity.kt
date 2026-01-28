package com.example.untitled3

import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        var rfidPlugin: RfidPlugin? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Ensure the plugin is only added once
        if (rfidPlugin == null) {
            rfidPlugin = RfidPlugin()
            flutterEngine.plugins.add(rfidPlugin!!)
        }
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        rfidPlugin?.handleKeyDownEvent(keyCode, event)
        return super.onKeyDown(keyCode, event)
    }

    override fun onKeyUp(keyCode: Int, event: KeyEvent?): Boolean {
        rfidPlugin?.handleKeyUpEvent(keyCode, event)
        return super.onKeyUp(keyCode, event)
    }
}
