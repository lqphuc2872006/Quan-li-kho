import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart'; // Import for EventChannel

import '../page/store/inventory_store.dart';
import '../../../services/rfid_service.dart';
import '../../../services/models/inventory_tag.dart';
import '../widgets/inventory_settings.dart';
import '../widgets/inventory_action_row.dart';
import '../widgets/inventory_info_bar.dart';
import '../../../widgets/app_data_table.dart';

/// ================= DEBUG =================
void logI(String msg) {
  debugPrint('[INVENTORY] $msg');
}

/// ================= UI ROW =================
class InventoryRow {
  final int no;
  final String tagId;
  final String rssi;
  final int time; // số lần quét

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
  bool _isPhysicalScanning = false; // New state to track physical button scanning

  // AUDIO
  final AudioPlayer _beepPlayer = AudioPlayer();
  DateTime _lastBeep = DateTime.fromMillisecondsSinceEpoch(0);

  // TIMERS
  // Timer? _stopScanTimer; // Removed: Physical button controls stopping
  Timer? _uiRefreshTimer;

  DateTime? _scanStartTime;
  int _totalTagsFound = 0;
  int _scanSpeed = 0;
  int _execTime = 0;

  StreamSubscription<Map<dynamic, dynamic>>? _tagSubscription;
  StreamSubscription<dynamic>? _physicalButtonSubscription; // New subscription for physical button

  int _timeValue = 5;
  String _timeUnit = 'seconds';

  // ===== DERIVE TABLE FROM STORE =====
  List<InventoryRow> get _rows {
    int index = 1;
    return InventoryStore.all.map((tag) {
      return InventoryRow(
        no: index++,
        tagId: tag.epc,
        rssi: tag.rssi,
        time: tag.count,
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    logI('initState');

    _beepPlayer.setReleaseMode(ReleaseMode.stop);
    _initTagListener();
    _initPhysicalButtonListener(); // Initialize physical button listener
    _checkConnection();
  }

  @override
  void dispose() {
    logI('dispose');

    _tagSubscription?.cancel();
    _physicalButtonSubscription?.cancel(); // Cancel physical button subscription
    // _stopScanTimer?.cancel(); // Removed
    _uiRefreshTimer?.cancel();
    _beepPlayer.dispose();

    if (_isScanning) {
      RfidService.stopInventory();
    }
    super.dispose();
  }

  // ================= RFID CONNECTION =================

  Future<void> _checkConnection() async {
    logI('checkConnection...');
    final ok = await RfidService.isConnected();
    logI('RFID connected = $ok');

    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('RFID chưa kết nối'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // ================= RFID STREAM =================

  void _initTagListener() {
    logI('initTagListener');

    _tagSubscription = RfidService.tagStream.listen(
          (raw) {
        logI('TAG RAW RECEIVED: $raw');
        _onTagScanned(raw);
      },
      onError: (e) {
        logI('STREAM ERROR: $e');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('RFID error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        _handleScanStop();
      },
      onDone: () {
        logI('STREAM DONE');
      },
    );

    _tagSubscription?.pause();
  }

  // ================= PHYSICAL BUTTON LISTENER =================
  void _initPhysicalButtonListener() {
    logI('initPhysicalButtonListener');
    const EventChannel _physicalButtonChannel =
    EventChannel('com.example.untitled3/rfid/physicalButton');

    _physicalButtonSubscription = _physicalButtonChannel.receiveBroadcastStream().listen(
          (event) {
        logI('Physical Button Event: $event');
        if (event is bool) {
          if (event) {
            // Button pressed
            if (!_isPhysicalScanning && !_isScanning) {
              setState(() {
                _isPhysicalScanning = true;
              });
              _handleScanStart();
            }
          } else {
            // Button released
            if (_isPhysicalScanning) {
              setState(() {
                _isPhysicalScanning = false;
              });
              _handleScanStop();
            }
          }
        }
      },
      onError: (e) {
        logI('PHYSICAL BUTTON STREAM ERROR: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi nút vật lý: $e'),
            backgroundColor: Colors.red,
          ),
        );
        if (_isPhysicalScanning) {
          setState(() {
            _isPhysicalScanning = false;
          });
          _handleScanStop();
        }
      },
      onDone: () {
        logI('PHYSICAL BUTTON STREAM DONE');
      },
    );
  }

  // ================= TAG EVENT =================

  void _onTagScanned(Map<dynamic, dynamic> raw) {
    logI('onTagScanned called');

    final tag = InventoryTag.fromMap(
      Map<String, dynamic>.from(raw),
    );

    logI('PARSED TAG: epc=${tag.epc}, rssi=${tag.rssi}');

    InventoryStore.upsert(tag);
    logI('STORE SIZE = ${InventoryStore.total}');

    _beepDebounced();
  }

  // ================= BEEP =================

  void _beepDebounced() {
    final now = DateTime.now();
    if (now.difference(_lastBeep).inMilliseconds < 250) return;
    _lastBeep = now;
    _beepPlayer.play(AssetSource('sounds/beep.mp3'));
  }

  // ================= START SCAN =================

  Future<void> _handleScanStart() async {
    if (_isScanning) return; // Prevent starting if already scanning

    logI('START SCAN triggered');

    setState(() {
      _isScanning = true;
      _scanStartTime = DateTime.now();
      _execTime = 0;
      _scanSpeed = 0;
    });

    try {
      logI('Calling stopInventory (safety)');
      await RfidService.stopInventory();

      await Future.delayed(const Duration(milliseconds: 200));

      logI('Calling startInventory');
      final ok = await RfidService.startInventory();
      logI('startInventory result = $ok');

      if (!ok) throw Exception('RFID start failed');

      logI('Resuming tag stream');
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

      // _stopScanTimer was removed as physical button controls stopping
    } catch (e) {
      logI('START SCAN ERROR: $e');

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

  // ================= STOP SCAN =================

  Future<void> _handleScanStop() async {
    if (!_isScanning) return; // Only stop if actually scanning

    logI('STOP SCAN triggered');

    await RfidService.stopInventory();
    _tagSubscription?.pause();
    // _stopScanTimer?.cancel(); // Removed
    _uiRefreshTimer?.cancel();

    setState(() {
      _isScanning = false;
      _isPhysicalScanning = false; // Reset physical scanning state
    });
  }

  // ================= CLEAR =================

  void _clearData() {
    if (_isScanning) return;

    logI('CLEAR DATA');

    InventoryStore.clear();

    setState(() {
      _totalTagsFound = 0;
      _scanSpeed = 0;
      _execTime = 0;
    });
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: InventorySettings(
            expanded: _showSettings,
            onToggle: () =>
                setState(() => _showSettings = !_showSettings),
          ),
        ),

        SliverToBoxAdapter(
          child: InventoryActionRow(
            timeDisplay: '$_timeValue $_timeUnit',
            // Disable UI buttons if physical scanning is active
            isScanning: _isPhysicalScanning ? true : _isScanning,
            onPickTime: _isPhysicalScanning ? () {} : () { /* Original onPickTime logic */ },
            onStart: _isPhysicalScanning
                ? () {} // Disable UI start if physical button is scanning
                : (_isScanning ? _handleScanStop : _handleScanStart),
            onClear: _isPhysicalScanning ? () {} : _clearData,
          ),
        ),

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
