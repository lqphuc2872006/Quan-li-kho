package com.example.untitled3

import android.util.Log
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
    private var mInventoryCallback: ((String, Int) -> Unit)? = null
    private var mInventoryEndCallback: (() -> Unit)? = null
    private var mErrorCallback: ((String) -> Unit)? = null
    private var isScanning = false

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
            mErrorCallback?.invoke("Connect error: ${e.message}")
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
     * Start inventory scan
     */
    fun startInventory(
        onTagScanned: (String, Int) -> Unit,
        onScanEnd: () -> Unit,
        onError: (String) -> Unit
    ) {
        if (isScanning) {
            Log.w(TAG, "Already scanning")
            return
        }

        if (!isConnected()) {
            onError("Not connected to reader")
            return
        }

        mInventoryCallback = onTagScanned
        mInventoryEndCallback = onScanEnd
        mErrorCallback = onError

        try {
            // Create inventory parameters
            val inventoryParam = InventoryParam().apply {
                setAntennaCount(AntennaCount.SINGLE_CHANNEL)
                setSession(Session.S0)
                setTarget(Target.B)
                setFastSwitch(false)
                setLoopCount(-1) // Continuous scan
            }

            // Create inventory config
            val config = InventoryConfig.Builder()
                .setInventoryParam(inventoryParam)
                .setInventory(inventoryParam.getInventory())
                .setOnInventoryTagSuccess(Consumer { tag ->
                    try {
                        val epc = tag.epc?.replace(" ", "") ?: ""
                        val rssi = tag.rssi
                        Log.d(TAG, "Tag scanned: EPC=$epc, RSSI=$rssi")
                        mInventoryCallback?.invoke(epc, rssi)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error processing tag", e)
                    }
                })
                .setOnInventoryTagEndSuccess(Consumer { end ->
                    try {
                        if (end.isFinished) {
                            Log.d(TAG, "Inventory finished")
                            isScanning = false
                            mInventoryEndCallback?.invoke()
                        } else {
                            // Continue scanning only if still in scanning state
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
                        if (!isScanning) {
                            return@setOnFailure
                        }
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
                            mErrorCallback?.invoke("Scan error: $errorMsg")
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Error processing failure", e)
                        isScanning = false
                    }
                }
                .build()

            mReader?.setInventoryConfig(config)
            mReader?.startInventory(false)
            isScanning = true
            Log.d(TAG, "Inventory started")
        } catch (e: Exception) {
            Log.e(TAG, "Start inventory error", e)
            isScanning = false
            onError("Start scan error: ${e.message}")
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

    /**
     * Release resources
     */
    fun release() {
        stopInventory()
        disconnect()
        mReader = null
        instance = null
    }
}
