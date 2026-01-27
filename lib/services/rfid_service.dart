import 'package:flutter/services.dart';
import 'dart:async';

class RfidService {
  static const MethodChannel _channel =
  MethodChannel('com.example.untitled3/rfid');

  static const EventChannel _eventChannel =
  EventChannel('com.example.untitled3/rfid/tags');

  static Stream<Map<String, dynamic>>? _tagStream;
  static StreamSubscription? _nativeSubscription;

  // ============================
  // CONNECT
  // ============================
  static Future<bool> connect(String port, int baudRate) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'connect',
        {
          'port': port,
          'baudRate': baudRate,
        },
      );
      return result ?? false;
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  static Future<bool> disconnect() async {
    try {
      await stopInventory();
      await _nativeSubscription?.cancel();
      _tagStream = null;

      final result = await _channel.invokeMethod<bool>('disconnect');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  // ============================
  // INVENTORY
  // ============================
  static Future<bool> startInventory() async {
    try {
      final result =
      await _channel.invokeMethod<bool>('startInventory');
      return result ?? false;
    } catch (e) {
      throw Exception('Lỗi bắt đầu quét: $e');
    }
  }

  static Future<bool> stopInventory() async {
    try {
      final result =
      await _channel.invokeMethod<bool>('stopInventory');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  // ============================
  // STATUS
  // ============================
  static Future<bool> isConnected() async {
    try {
      final result = await _channel.invokeMethod<bool>('isConnected');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<List<String>> getAvailablePorts() async {
    try {
      final result =
      await _channel.invokeMethod<List<dynamic>>('getAvailablePorts');
      return result?.map((e) => e.toString()).toList() ?? [];
    } catch (_) {
      return [];
    }
  }

  static Future<bool> requestPermissions(String devicePath) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'requestPermissions',
        {'devicePath': devicePath},
      );
      return result ?? false;
    } catch (e) {
      throw Exception('Lỗi yêu cầu quyền truy cập: $e');
    }
  }

  // ============================
  // TAG STREAM (FIXED)
  // ============================
  static Stream<Map<String, dynamic>> get tagStream {
    _tagStream ??= _eventChannel
        .receiveBroadcastStream()
        .map<Map<String, dynamic>>((event) {
      if (event is Map) {
        return Map<String, dynamic>.from(event);
      }
      return {};
    }).asBroadcastStream();

    return _tagStream!;
  }
}

/// ============================
/// MODEL TAG
/// ============================
class RfidTag {
  final String epc;
  final String rssi;
  final String timestamp;
  final int count;

  RfidTag({
    required this.epc,
    required this.rssi,
    required this.timestamp,
    this.count = 1,
  });

  factory RfidTag.fromMap(Map<String, dynamic> map) {
    String time;

    if (map['timestamp'] is int) {
      time = DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          .toString()
          .substring(11, 19);
    } else {
      time = map['timestamp']?.toString() ??
          DateTime.now().toString().substring(11, 19);
    }

    return RfidTag(
      epc: map['epc']?.toString() ?? '',
      rssi: map['rssi']?.toString() ?? '',
      timestamp: time,
      count: map['count'] ?? 1,
    );
  }
}
