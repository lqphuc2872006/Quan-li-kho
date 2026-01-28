import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

import '../page/store/inventory_store.dart';
import '../../../services/rfid_service.dart';
import '../../../services/models/inventory_tag.dart';
import '../widgets/inventory_settings.dart';
import '../widgets/inventory_action_row.dart';
import '../widgets/inventory_info_bar.dart';
import '../../../widgets/app_data_table.dart';

class InventoryRow {
  final int no;
  final String tagId;
  final String rssi;
  final int time; // 👈 số lần quét

  InventoryRow({
    required this.no,
    required this.tagId,
    required this.rssi,
    required this.time,
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

  // AUDIO
  final AudioPlayer _beepPlayer = AudioPlayer();
  DateTime _lastBeep = DateTime.fromMillisecondsSinceEpoch(0);

  // TIMERS
  Timer? _stopScanTimer;
  Timer? _uiRefreshTimer;

  DateTime? _scanStartTime;
  int _totalTagsFound = 0;
  int _scanSpeed = 0;
  int _execTime = 0;

  StreamSubscription<Map<dynamic, dynamic>>? _tagSubscription;

  int _timeValue = 5;
  String _timeUnit = 'seconds';

  // DERIVE TABLE FROM STORE
  List<InventoryRow> get _rows {
    int index = 1;
    return InventoryStore.all.map((tag) {
      return InventoryRow(
        no: index++,
        tagId: tag.epc,
        rssi: tag.rssi,
        time: tag.count, // 🔥 time = số lần quét
      );
    }).toList();
  }


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
    _uiRefreshTimer?.cancel();
    _beepPlayer.dispose();

    if (_isScanning) {
      RfidService.stopInventory();
    }
    super.dispose();
  }

  // RFID LISTENER
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

  // TAG EVENT
  void _onTagScanned(Map<dynamic, dynamic> raw) {
    final tag = InventoryTag.fromMap(
      Map<String, dynamic>.from(raw),
    );

    InventoryStore.upsert(tag);
    _beepDebounced();
  }

  // BEEP
  void _beepDebounced() {
    final now = DateTime.now();
    if (now.difference(_lastBeep).inMilliseconds < 250) return;
    _lastBeep = now;
    _beepPlayer.play(AssetSource('sounds/beep.mp3'));
  }

  // START SCAN
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
      if (!ok) throw Exception('RFID start failed');

      _tagSubscription?.resume();

      _uiRefreshTimer = Timer.periodic(
        const Duration(milliseconds: 300),
            (_) {
          if (!_isScanning || !mounted) return;

          setState(() {
            _totalTagsFound = InventoryStore.total;

            if (_scanStartTime != null) {
              _execTime = DateTime.now()
                  .difference(_scanStartTime!)
                  .inSeconds;
              if (_execTime > 0) {
                _scanSpeed =
                    (_totalTagsFound / _execTime).round();
              }
            }
          });
        },
      );

      int seconds = _timeUnit == 'minutes'
          ? _timeValue * 60
          : _timeUnit == 'hours'
          ? _timeValue * 3600
          : _timeValue;

      _stopScanTimer =
          Timer(Duration(seconds: seconds), _handleScanStop);
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

  // STOP SCAN
  Future<void> _handleScanStop() async {
    if (!_isScanning) return;

    await RfidService.stopInventory();
    _tagSubscription?.pause();
    _stopScanTimer?.cancel();
    _uiRefreshTimer?.cancel();

    setState(() {
      _isScanning = false;
    });
  }

  // CLEAR
  void _clearData() {
    if (_isScanning) return;

    InventoryStore.clear();

    setState(() {
      _totalTagsFound = 0;
      _scanSpeed = 0;
      _execTime = 0;
    });
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ===== SETTINGS =====
        SliverToBoxAdapter(
          child: InventorySettings(
            expanded: _showSettings,
            onToggle: () =>
                setState(() => _showSettings = !_showSettings),
          ),
        ),

        // ===== ACTION ROW =====
        SliverToBoxAdapter(
          child: InventoryActionRow(
            timeDisplay: '$_timeValue $_timeUnit',
            isScanning: _isScanning,
            onPickTime: () {},
            onStart:
            _isScanning ? _handleScanStop : _handleScanStart,
            onClear: _clearData,
          ),
        ),

        // ===== INFO BAR =====
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InventoryInfoBar(
              tags: _rows.length,
              speed: _scanSpeed,
              total: _totalTagsFound,
              execTime: _execTime,
            ),
          ),
        ),

        // ===== TABLE (CHIẾM PHẦN CÒN LẠI) =====
        SliverFillRemaining(
          hasScrollBody: true,
          child: AppDataTable(
            headers: const ['No', 'Tag ID', 'Time', 'RSSI'],
            rows: _rows.map((r) {
              return [
                Text(r.no.toString()),
                Text(r.tagId),
                Text(
                  r.time.toString(),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(r.rssi),
              ];
            }).toList(),
          ),
        ),
      ],
    );
  }

}
