import 'package:flutter/services.dart';

/// RFID Plugin for Flutter
/// Provides methods to connect, scan, and manage RFID reader
class RfidPlugin {
  static const MethodChannel _channel = MethodChannel('com.example.untitled3/rfid');

  /// Callback for when a tag is scanned
  Function(String epc, int rssi)? onTagScanned;

  /// Callback for when scanning ends
  Function()? onScanEnd;

  /// Callback for errors
  Function(String error)? onError;

  RfidPlugin() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  /// Handle method calls from native platform
  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onTagScanned':
        final Map<dynamic, dynamic>? arguments = call.arguments as Map<dynamic, dynamic>?;
        if (arguments != null) {
          final String epc = arguments['epc'] as String? ?? '';
          final int rssi = arguments['rssi'] as int? ?? 0;
          onTagScanned?.call(epc, rssi);
        }
        break;
      case 'onScanEnd':
        onScanEnd?.call();
        break;
      case 'onError':
        final Map<dynamic, dynamic>? arguments = call.arguments as Map<dynamic, dynamic>?;
        if (arguments != null) {
          final String error = arguments['error'] as String? ?? 'Unknown error';
          onError?.call(error);
        }
        break;
    }
  }

  /// Connect to RFID reader via Serial Port
  ///
  /// [devicePath] - Serial port device path (e.g., "/dev/ttyAS3")
  /// [baudRate] - Baud rate (default: 115200)
  ///
  /// Returns true if connection successful, throws exception on error
  Future<bool> connectSerialPort({
    required String devicePath,
    int baudRate = 115200,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'connectSerialPort',
        {
          'devicePath': devicePath,
          'baudRate': baudRate,
        },
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to connect: ${e.message}');
    }
  }

  /// Disconnect from RFID reader
  Future<bool> disconnect() async {
    try {
      final result = await _channel.invokeMethod<bool>('disconnect');
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to disconnect: ${e.message}');
    }
  }

  /// Check if connected to RFID reader
  Future<bool> isConnected() async {
    try {
      final result = await _channel.invokeMethod<bool>('isConnected');
      return result ?? false;
    } on PlatformException catch (e) {
      return false;
    }
  }

  /// Start RFID inventory scan
  ///
  /// Tags will be received via [onTagScanned] callback
  Future<bool> startInventory() async {
    try {
      final result = await _channel.invokeMethod<bool>('startInventory');
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to start scan: ${e.message}');
    }
  }

  /// Stop RFID inventory scan
  Future<bool> stopInventory() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopInventory');
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to stop scan: ${e.message}');
    }
  }

  /// Check if currently scanning
  Future<bool> isScanning() async {
    try {
      final result = await _channel.invokeMethod<bool>('isScanning');
      return result ?? false;
    } on PlatformException catch (e) {
      return false;
    }
  }

  /// Request permissions to access the serial port
  ///
  /// This will execute `su -c "chmod 666 <devicePath>"`
  ///
  /// [devicePath] - Serial port device path (e.g., "/dev/ttyAS3")
  Future<bool> requestPermissions({
    required String devicePath,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'requestPermissions',
        {'devicePath': devicePath},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to request permissions: ${e.message}');
    }
  }
}
