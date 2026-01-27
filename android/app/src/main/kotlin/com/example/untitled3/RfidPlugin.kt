package com.example.untitled3

import android.util.Log
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
    private val rfidHelper = RfidHelper.getInstance()
    private var eventSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.example.untitled3/rfid")
        channel.setMethodCallHandler(this)
        
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "com.example.untitled3/rfid/tags")
        eventChannel.setStreamHandler(this)
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
            } else {
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
        rfidHelper.disconnect()
    }

    // EventChannel.StreamHandler implementation
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        rfidHelper.setTagEventSink(events)
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        rfidHelper.setTagEventSink(null)
    }
}
