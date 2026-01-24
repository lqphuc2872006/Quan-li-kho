import 'package:flutter/material.dart';
import 'dart:async';

import '../../../services/rfid_service.dart';
import '../widgets/inventory_settings.dart';
import '../widgets/inventory_action_row.dart';
import '../widgets/time_picker_sheet.dart';
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
  // ================= UI STATE =================
  bool _showSettings = false;
  bool _isScanning = false;

  // ================= TIMER =================
  Timer? _stopScanTimer;
  Timer? _uiUpdateTimer;

  // ================= DATA =================
  final Map<String, InventoryRow> _tagMap = {};
  List<InventoryRow> get _rows =>
      _tagMap.values.toList()..sort((a, b) => a.no.compareTo(b.no));

  // ================= STATS =================
  DateTime? _scanStartTime;
  int _totalTagsFound = 0;
  int _scanSpeed = 0;
  int _execTime = 0;

  // ================= STREAM =================
  StreamSubscription<Map<dynamic, dynamic>>? _tagSubscription;

  // ================= TIME CONFIG =================
  int _timeValue = 5;
  String _timeUnit = 'seconds';

  // ================= LIFECYCLE =================
  @override
  void initState() {
    super.initState();
    _initTagListener();
    _checkConnection();
  }

  @override
  void dispose() {
    _tagSubscription?.cancel();
    _stopScanTimer?.cancel();
    _uiUpdateTimer?.cancel();

    if (_isScanning) {
      RfidService.stopInventory();
    }
    super.dispose();
  }

  // ================= INIT STREAM =================
  void _initTagListener() {
    _tagSubscription = RfidService.tagStream.listen(
      _onTagScanned,
      onError: (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi RFID stream: $e'),
            backgroundColor: Colors.red,
          ),
        );
        _handleScanStop();
      },
    );

    // KHỞI ĐẦU PAUSE – chỉ resume khi Start
    _tagSubscription?.pause();
  }

  Future<void> _checkConnection() async {
    final ok = await RfidService.isConnected();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thiết bị RFID chưa kết nối'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // ================= TAG HANDLER =================
  void _onTagScanned(Map<dynamic, dynamic> raw) {
    final map = Map<String, dynamic>.from(raw);
    final tag = RfidTag.fromMap(map);
    final now = DateTime.now();

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

  // ================= START SCAN =================
  Future<void> _handleScanStart() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _scanStartTime = DateTime.now();
      _execTime = 0;
      _scanSpeed = 0;
      // ❌ KHÔNG clear _tagMap
      // ❌ KHÔNG reset _totalTagsFound
    });

    try {
      final ok = await RfidService.startInventory();
      if (!ok) throw Exception('startInventory = false');

      _tagSubscription?.resume();

      int seconds;
      switch (_timeUnit) {
        case 'minutes':
          seconds = _timeValue * 60;
          break;
        case 'hours':
          seconds = _timeValue * 3600;
          break;
        default:
          seconds = _timeValue;
      }

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
          content: Text('Lỗi bắt đầu quét: $e'),
          backgroundColor: Colors.red,
        ),
      );
      _handleScanStop();
    }
  }

  // ================= STOP SCAN =================
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

  // ================= TIME DISPLAY =================
  String get _timeDisplay {
    switch (_timeUnit) {
      case 'minutes':
        return '$_timeValue min';
      case 'hours':
        return '$_timeValue h';
      default:
        return '$_timeValue s';
    }
  }

  // ================= UI =================
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
          timeDisplay: _timeDisplay,
          isScanning: _isScanning,
          onPickTime: () {
            if (_isScanning) return;
            showTimePickerSheet(
              context: context,
              value: _timeValue,
              unit: _timeUnit,
              onApply: (v, u) {
                setState(() {
                  _timeValue = v;
                  _timeUnit = u;
                });
              },
            );
          },
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
