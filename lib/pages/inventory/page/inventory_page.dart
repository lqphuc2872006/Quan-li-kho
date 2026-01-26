import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

import '../../../services/rfid_service.dart';
import '../widgets/inventory_settings.dart';
import '../widgets/inventory_action_row.dart';
import '../widgets/inventory_info_bar.dart';
import '../../../widgets/app_data_table.dart';

class InventoryRow {
  final int no;
  final String tagId;
  final String rssi;
  final String time;
  final int count;

  InventoryRow({
    required this.no,
    required this.tagId,
    required this.rssi,
    required this.time,
    required this.count,
  });
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  bool _showSettings = false;
  bool _isScanning = false;

  final AudioPlayer _beepPlayer = AudioPlayer();

  Timer? _stopScanTimer;
  Timer? _uiUpdateTimer;

  final Map<String, InventoryRow> _tagMap = {};
  List<InventoryRow> get _rows =>
      _tagMap.values.toList()..sort((a, b) => a.no.compareTo(b.no));

  DateTime? _scanStartTime;
  int _totalTagsFound = 0;
  int _scanSpeed = 0;
  int _execTime = 0;

  StreamSubscription<Map<dynamic, dynamic>>? _tagSubscription;

  int _timeValue = 5;
  String _timeUnit = 'seconds';

  @override
  void initState() {
    super.initState();

    _beepPlayer.setReleaseMode(ReleaseMode.stop);

    _initTagListener();
    _checkConnection();
  }

  @override
  void dispose() {
    _tagSubscription?.cancel();
    _stopScanTimer?.cancel();
    _uiUpdateTimer?.cancel();
    _beepPlayer.dispose();

    if (_isScanning) {
      RfidService.stopInventory();
    }
    super.dispose();
  }

  void _initTagListener() {
    _tagSubscription = RfidService.tagStream.listen(
      _onTagScanned,
      onError: (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('RFID error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        _handleScanStop();
      },
    );

    _tagSubscription?.pause();
  }

  Future<void> _checkConnection() async {
    final ok = await RfidService.isConnected();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('RFID chưa kết nối'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// =====================
  /// TAG EVENT (MỖI EVENT = 1 BÍP)
  /// =====================
  void _onTagScanned(Map<dynamic, dynamic> raw) {
    final map = Map<String, dynamic>.from(raw);
    final tag = RfidTag.fromMap(map);
    final now = DateTime.now();

    // 🔊 MỖI EVENT → 1 tiếng
    _beepPlayer.play(AssetSource('sounds/beep.mp3'));

    setState(() {
      final old = _tagMap[tag.epc];
      if (old != null) {
        _tagMap[tag.epc] = InventoryRow(
          no: old.no,
          tagId: tag.epc,
          rssi: tag.rssi,
          time: tag.timestamp,
          count: old.count + 1,
        );
      } else {
        _tagMap[tag.epc] = InventoryRow(
          no: _tagMap.length + 1,
          tagId: tag.epc,
          rssi: tag.rssi,
          time: tag.timestamp,
          count: 1,
        );
      }

      _totalTagsFound = _tagMap.length;

      if (_scanStartTime != null) {
        _execTime = now.difference(_scanStartTime!).inSeconds;
        if (_execTime > 0) {
          _scanSpeed = (_totalTagsFound / _execTime).round();
        }
      }
    });
  }

  /// =====================
  /// START SCAN
  /// =====================
  Future<void> _handleScanStart() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _scanStartTime = DateTime.now();
      _execTime = 0;
      _scanSpeed = 0;
    });

    try {
      await RfidService.stopInventory();
      await Future.delayed(const Duration(milliseconds: 200));

      final ok = await RfidService.startInventory();
      if (!ok) throw Exception("RFID start failed");

      _tagSubscription?.resume();

      int seconds = _timeUnit == 'minutes'
          ? _timeValue * 60
          : _timeUnit == 'hours'
          ? _timeValue * 3600
          : _timeValue;

      _stopScanTimer =
          Timer(Duration(seconds: seconds), _handleScanStop);

      _uiUpdateTimer =
          Timer.periodic(const Duration(seconds: 1), (_) {
            if (!_isScanning || _scanStartTime == null) return;
            setState(() {
              _execTime =
                  DateTime.now().difference(_scanStartTime!).inSeconds;
            });
          });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Start scan lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
      _handleScanStop();
    }
  }

  /// =====================
  /// STOP SCAN
  /// =====================
  Future<void> _handleScanStop() async {
    if (!_isScanning) return;

    await RfidService.stopInventory();
    _tagSubscription?.pause();
    _stopScanTimer?.cancel();
    _uiUpdateTimer?.cancel();

    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  /// =====================
  /// UI
  /// =====================
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InventorySettings(
          expanded: _showSettings,
          onToggle: () {
            setState(() => _showSettings = !_showSettings);
          },
        ),
        InventoryActionRow(
          timeDisplay: '$_timeValue $_timeUnit',
          isScanning: _isScanning,
          onPickTime: () {},
          onStart: _isScanning ? _handleScanStop : _handleScanStart,
          onClear: () {
            if (_isScanning) return;
            setState(() {
              _tagMap.clear();
              _totalTagsFound = 0;
            });
          },
        ),
        const SizedBox(height: 8),
        InventoryInfoBar(
          tags: _rows.length,
          speed: _scanSpeed,
          total: _totalTagsFound,
          execTime: _execTime,
        ),
        const SizedBox(height: 8),
        AppDataTable(
          headers: const ['No', 'Tag ID', 'Count', 'RSSI', 'Time'],
          rows: _rows.map((r) {
            return [
              Text(r.no.toString()),
              Text(r.tagId),
              Text(
                r.count.toString(),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(r.rssi),
              Text(r.time),
            ];
          }).toList(),
        ),
      ],
    );
  }
}
