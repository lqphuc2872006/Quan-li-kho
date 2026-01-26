package com.example.untitled3

import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.EventChannel

import com.payne.reader.Reader
import com.payne.reader.base.Consumer
import com.payne.reader.bean.config.AntennaCount
import com.payne.reader.bean.config.ResultCode
import com.payne.reader.bean.config.Session
import com.payne.reader.bean.config.Target
import com.payne.reader.bean.receive.Failure
import com.payne.reader.bean.receive.InventoryTag
import com.payne.reader.bean.receive.InventoryTagEnd
import com.payne.reader.bean.receive.Success
import com.payne.reader.bean.send.InventoryConfig
import com.payne.reader.bean.send.InventoryParam
import com.payne.reader.communication.ConnectHandle
import com.payne.reader.process.ReaderImpl

class RfidHelper {
    private var mReader: Reader? = null
    private var mConnectHandle: ConnectHandle? = null
    private var mTagEventSink: EventChannel.EventSink? = null
    private var isScanning = false
    private val mainHandler = Handler(Looper.getMainLooper())

    companion object {
        private const val TAG = "RfidHelper"
        @Volatile
        private var instance: RfidHelper? = null

        fun getInstance(): RfidHelper {
            return instance ?: synchronized(this) {
                instance ?: RfidHelper().also { instance = it }
            }
        }
    }

    init {
        mReader = ReaderImpl.create(AntennaCount.SINGLE_CHANNEL)
    }

    /**
     * Connect to RFID reader via ConnectHandle
     */
    fun connect(connectHandle: ConnectHandle): Boolean {
        return try {
            mConnectHandle = connectHandle
            val connected = mReader?.connect(connectHandle) ?: false
            Log.d(TAG, "Connect result: $connected")
            connected
        } catch (e: Exception) {
            Log.e(TAG, "Connect error", e)
            false
        }
    }

    /**
     * Disconnect from RFID reader
     */
    fun disconnect() {
        try {
            stopInventory()
            mReader?.disconnect()
            mConnectHandle?.release()
            mConnectHandle = null
            Log.d(TAG, "Disconnected")
        } catch (e: Exception) {
            Log.e(TAG, "Disconnect error", e)
        }
    }

    /**
     * Check if connected
     */
    fun isConnected(): Boolean {
        return mReader?.isConnected() ?: false
    }

    /**
     * Set event sink for streaming tags
     */
    fun setTagEventSink(sink: EventChannel.EventSink?) {
        mTagEventSink = sink
    }

    /**
     * Start inventory scan
     * Follows the exact pattern from the demo project:
     * 1. Set power level
     * 2. Set inventory config
     * 3. Set work antenna
     * 4. Start inventory in antenna callback
     */
    fun startInventory() {
        if (isScanning) {
            Log.w(TAG, "Already scanning")
            return
        }

        if (!isConnected()) {
            Log.e(TAG, "Not connected to reader")
            return
        }

        try {
            // Step 1: Set power level (increased to 25 for better tag detection)
            val powerLevel: Byte = 25
            Log.d(TAG, "Setting power level to: $powerLevel")
            
            mReader?.setOutputPowerUniformly(powerLevel, true,
                Consumer { success ->
                    Log.d(TAG, "Power set successfully")
                    // Step 2: Set inventory config FIRST (before setting antenna)
                    setInventoryConfig()
                    // Step 3: Set work antenna, then start in callback
                    setWorkAntennaAndStart()
                },
                Consumer { failure ->
                    Log.e(TAG, "Failed to set power: ${ResultCode.getNameForResultCode(failure.errorCode)}")
                    // Try to continue anyway
                    setInventoryConfig()
                    setWorkAntennaAndStart()
                }
            )
            
        } catch (e: Exception) {
            Log.e(TAG, "Start inventory error", e)
            isScanning = false
            mainHandler.post {
                mTagEventSink?.error("INVENTORY_ERROR", "Start scan error: ${e.message}", null)
            }
        }
    }
    
    /**
     * Set inventory configuration (must be called before setting work antenna)
     */
    private fun setInventoryConfig() {
        try {
            // Create inventory parameters - using Target.A (more common for most tags)
            val inventoryParam = InventoryParam().apply {
                setAntennaCount(AntennaCount.SINGLE_CHANNEL)
                setSession(Session.S0)  // Session S0 is most common
                setTarget(Target.A)     // Changed from Target.B to Target.A (more compatible)
                setFastSwitch(false)
                setLoopCount(-1) // Continuous scan
            }
            Log.d(TAG, "Inventory param: Session=${inventoryParam.getSession()}, Target=${inventoryParam.getTarget()}")

            // IMPORTANT: Switch antenna count BEFORE setting inventory config (matching demo project)
            mReader?.switchAntennaCount(inventoryParam.getAntennaCount())
            Log.d(TAG, "Antenna count switched to: ${inventoryParam.getAntennaCount()}")

            val config = InventoryConfig.Builder()
                .setInventoryParam(inventoryParam)
                .setInventory(inventoryParam.getInventory())
                .setOnInventoryTagSuccess(Consumer { tag ->
                    try {
                        val epc = tag.epc?.replace(" ", "") ?: ""
                        val rssi = tag.rssi
                        Log.d(TAG, "Tag scanned: EPC=$epc, RSSI=$rssi")
                        
                        // Post to main thread - EventChannel requires main thread
                        mainHandler.post {
                            if (isScanning && mTagEventSink != null) {
                                try {
                                    mTagEventSink?.success(mapOf(
                                        "epc" to epc,
                                        "rssi" to "$rssi dBm",
                                        "timestamp" to System.currentTimeMillis().toString()
                                    ))
                                } catch (e: Exception) {
                                    Log.e(TAG, "Error sending tag", e)
                                }
                            }
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Error processing tag", e)
                    }
                })
                .setOnInventoryTagEndSuccess(Consumer { end ->
                    try {
                        Log.d(TAG, "Inventory end: isFinished=${end.isFinished}, totalRead=${end.totalRead}, readRate=${end.readRate}")
                        if (end.isFinished) {
                            Log.d(TAG, "Inventory finished - stopping scan")
                            isScanning = false
                        } else {
                            // Continue scanning if still in scanning state
                            Log.d(TAG, "Inventory not finished, continuing scan...")
                            if (isScanning) {
                                mReader?.startInventory(false)
                            }
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Error processing inventory end", e)
                        isScanning = false
                    }
                })
                .setOnFailure { failure ->
                    try {
                        if (!isScanning) return@setOnFailure
                        val errorMsg = ResultCode.getNameForResultCode(failure.errorCode)
                        Log.e(TAG, "Inventory failure: $errorMsg")
                        // Only stop if it's a critical error, otherwise retry
                        if (failure.errorCode == ResultCode.REQUEST_TIMEOUT) {
                            // On timeout, continue scanning
                            if (isScanning) {
                                mReader?.startInventory(false)
                            }
                        } else {
                            isScanning = false
                            mainHandler.post {
                                mTagEventSink?.error("INVENTORY_ERROR", "Scan error: $errorMsg", null)
                            }
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Error processing failure", e)
                        isScanning = false
                    }
                }
                .build()

            mReader?.setInventoryConfig(config)
            Log.d(TAG, "Inventory config set successfully")
            
        } catch (e: Exception) {
            Log.e(TAG, "Set inventory config error", e)
        }
    }
    
    /**
     * Set work antenna and start inventory in callback (matching demo project pattern)
     */
    private fun setWorkAntennaAndStart() {
        try {
            // Set work antenna (antenna 0 for SINGLE_CHANNEL - antenna ID starts from 0)
            mReader?.setWorkAntenna(0,
                Consumer { antSuccess ->
                    // Success callback - start inventory here (matching demo project)
                    Log.d(TAG, "Work antenna set successfully, starting inventory")
                    if (!isScanning) {
                        isScanning = true
                        mReader?.startInventory(false)
                        Log.d(TAG, "Inventory started (REAL RFID)")
                    }
                },
                Consumer { antFailure ->
                    Log.e(TAG, "Failed to set work antenna: ${ResultCode.getNameForResultCode(antFailure.errorCode)}")
                    // Try to start anyway
                    if (!isScanning) {
                        isScanning = true
                        mReader?.startInventory(false)
                        Log.d(TAG, "Inventory started despite antenna error")
                    }
                }
            )
        } catch (e: Exception) {
            Log.e(TAG, "Set work antenna error", e)
            isScanning = false
            mainHandler.post {
                mTagEventSink?.error("INVENTORY_ERROR", "Set antenna error: ${e.message}", null)
            }
        }
    }

    /**
     * Stop inventory scan
     */
    fun stopInventory() {
        if (!isScanning) {
            return
        }

        try {
            mReader?.stopInventory(false)
            isScanning = false
            Log.d(TAG, "Inventory stopped")
        } catch (e: Exception) {
            Log.e(TAG, "Stop inventory error", e)
        }
    }

    /**
     * Check if scanning
     */
    fun isScanning(): Boolean {
        return isScanning
    }
}
