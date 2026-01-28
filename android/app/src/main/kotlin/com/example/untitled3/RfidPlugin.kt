package com.example.untitled3

import android.util.Log
import android.view.KeyEvent // Import KeyEvent
import com.payne.connect.port.SerialPortHandle
import com.payne.reader.communication.ConnectHandle
import com.naz.serial.port.SerialPortFinder
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class RfidPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var physicalButtonEventChannel: EventChannel // New EventChannel for physical button
    private val rfidHelper = RfidHelper.getInstance()
    private var eventSink: EventChannel.EventSink? = null
    private var physicalButtonEventSink: EventChannel.EventSink? = null // EventSink for physical button
    private var isPhysicalButtonPressed = false // Track physical button state

    // Define the keycode for the physical RFID scan button
    // This often varies by device. Common options: KEYCODE_F1, KEYCODE_BUTTON_R1, KEYCODE_CAMERA, KEYCODE_SCAN
    private val RFID_SCAN_KEYCODE = 134 // Updated with the user's provided keycode

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.example.untitled3/rfid")
        channel.setMethodCallHandler(this)
        
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "com.example.untitled3/rfid/tags")
        eventChannel.setStreamHandler(this)

        physicalButtonEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "com.example.untitled3/rfid/physicalButton")
        physicalButtonEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                physicalButtonEventSink = events
            }

            override fun onCancel(arguments: Any?) {
                physicalButtonEventSink = null
            }
        })

        // Set the static instance in MainActivity so it can pass key events
        MainActivity.rfidPlugin = this
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "connect" -> {
                val port = call.argument<String>("port") ?: ""
                val baudRate = call.argument<Int>("baudRate") ?: 115200
                connect(port, baudRate, result)
            }
            "disconnect" -> {
                disconnect(result)
            }
            "startInventory" -> {
                startInventory(result)
            }
            "stopInventory" -> {
                stopInventory(result)
            }
            "getAvailablePorts" -> {
                getAvailablePorts(result)
            }
            "isConnected" -> {
                result.success(rfidHelper.isConnected())
            }
            "requestPermissions" -> {
                val devicePath = call.argument<String>("devicePath")
                if (devicePath != null) {
                    requestPermissions(devicePath, result)
                } else {
                    result.error("INVALID_ARGUMENT", "devicePath cannot be null", null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    // New methods to handle key events from MainActivity
    fun handleKeyDownEvent(keyCode: Int, event: KeyEvent?) {
        Log.d("RfidPlugin", "Key Down: $keyCode")
        if (keyCode == RFID_SCAN_KEYCODE && event?.repeatCount == 0) {
            if (!isPhysicalButtonPressed) {
                isPhysicalButtonPressed = true
                physicalButtonEventSink?.success(true) // Notify Flutter button is pressed
                startInventory(object : io.flutter.plugin.common.MethodChannel.Result { // Corrected
                    override fun success(result: Any?) {}
                    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {}
                    override fun notImplemented() {}
                })
            }
        }
    }

    fun handleKeyUpEvent(keyCode: Int, event: KeyEvent?) {
        Log.d("RfidPlugin", "Key Up: $keyCode")
        if (keyCode == RFID_SCAN_KEYCODE) {
            if (isPhysicalButtonPressed) {
                isPhysicalButtonPressed = false
                physicalButtonEventSink?.success(false) // Notify Flutter button is released
                stopInventory(object : io.flutter.plugin.common.MethodChannel.Result { // Corrected
                    override fun success(result: Any?) {}
                    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {}
                    override fun notImplemented() {}
                })
            }
        }
    }

    private fun requestPermissions(devicePath: String, result: MethodChannel.Result) {
        try {
            Log.d("RfidPlugin", "Requesting permissions for device: $devicePath")
            val process = Runtime.getRuntime().exec(arrayOf("su", "-c", "chmod 666 $devicePath"))
            val exitCode = process.waitFor()

            if (exitCode == 0) {
                Log.d("RfidPlugin", "Permissions granted for $devicePath")
                result.success(true)
            } else {
                val errorStream = process.errorStream.bufferedReader().readText()
                Log.e("RfidPlugin", "Failed to grant permissions for $devicePath. Exit code: $exitCode, Error: $errorStream")
                result.error("PERMISSION_ERROR", "Failed to grant permissions: $errorStream", null)
            }
        } catch (e: Exception) {
            Log.e("RfidPlugin", "Error requesting permissions: ${e.message}", e)
            result.error("PERMISSION_ERROR", "Error requesting permissions: ${e.message}", null)
        }
    }

    private fun connect(port: String, baudRate: Int, result: MethodChannel.Result) {
        try {
            Log.d("RfidPlugin", "Connecting to port: $port, baudRate: $baudRate")
            
            // Real SDK connection - SerialPortHandle constructor takes (String, Int)
            val connectHandle: ConnectHandle = SerialPortHandle(port, baudRate)
            val connected = rfidHelper.connect(connectHandle)
            
            if (connected) {
                result.success(true)
            }
            else {
                result.error("CONNECTION_ERROR", "Failed to connect to device", null)
            }
        } catch (e: Exception) {
            Log.e("RfidPlugin", "Connection error: ${e.message}", e)
            result.error("CONNECTION_ERROR", e.message, null)
        }
    }

    private fun disconnect(result: MethodChannel.Result) {
        try {
            Log.d("RfidPlugin", "Disconnecting")
            rfidHelper.disconnect()
            result.success(true)
        } catch (e: Exception) {
            Log.e("RfidPlugin", "Disconnection error: ${e.message}", e)
            result.error("DISCONNECTION_ERROR", e.message, null)
        }
    }

    private fun startInventory(result: MethodChannel.Result) {
        try {
            if (!rfidHelper.isConnected()) {
                result.error("NOT_CONNECTED", "Device not connected", null)
                return
            }
            
            Log.d("RfidPlugin", "Starting inventory")
            rfidHelper.startInventory()
            result.success(true)
        } catch (e: Exception) {
            Log.e("RfidPlugin", "Start inventory error: ${e.message}", e)
            result.error("INVENTORY_ERROR", e.message, null)
        }
    }

    private fun stopInventory(result: MethodChannel.Result) {
        try {
            Log.d("RfidPlugin", "Stopping inventory")
            rfidHelper.stopInventory()
            result.success(true)
        } catch (e: Exception) {
            Log.e("RfidPlugin", "Stop inventory error: ${e.message}", e)
            result.error("INVENTORY_ERROR", e.message, null)
        }
    }

    private fun getAvailablePorts(result: MethodChannel.Result) {
        try {
            Log.d("RfidPlugin", "Getting available ports")
            
            // Real SDK port finder
            val portFinder = SerialPortFinder()
            val devicesPath = portFinder.allDevicesPath
            
            val ports = mutableListOf<String>()
            ports.addAll(devicesPath.toList())
            
            // Add common port if empty (for testing)
            if (ports.isEmpty()) {
                ports.add("/dev/ttyAS3")
            }
            
            result.success(ports)
        } catch (e: Exception) {
            Log.e("RfidPlugin", "Get ports error: ${e.message}", e)
            result.error("PORTS_ERROR", e.message, null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        physicalButtonEventChannel.setStreamHandler(null) // Cleanup new EventChannel
        MainActivity.rfidPlugin = null // Clear static reference
        rfidHelper.disconnect()
    }

    // EventChannel.StreamHandler implementation for tagStream
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        rfidHelper.setTagEventSink(events)
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        rfidHelper.setTagEventSink(null)
    }
}
