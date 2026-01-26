import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

import '../../../services/rfid_service.dart';
import '../widgets/temp_action_bar.dart';
import '../widgets/temp_table.dart';

class TempPage extends StatefulWidget {
  const TempPage({super.key});

  @override
  State<TempPage> createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> {
  // UI State
  bool _isScanning = false;
  String _searchText = '';

  // RFID & Data
  final AudioPlayer _beepPlayer = AudioPlayer();
  StreamSubscription<Map<dynamic, dynamic>>? _tagSubscription;
  final Map<String, TempRow> _tagMap = {};
  List<TempRow> get _rows => _tagMap.values.toList();

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
    _tagSubscription?.pause(); // Start paused
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

  // ======================
  // RFID EVENTS
  // ======================
  void _onTagScanned(Map<dynamic, dynamic> raw) {
    final map = Map<String, dynamic>.from(raw);
    final tag = RfidTag.fromMap(map);

    // Play sound for each tag event
    _beepPlayer.play(AssetSource('sounds/beep.mp3'));

    setState(() {
      final oldRow = _tagMap[tag.epc];
      _tagMap[tag.epc] = TempRow(
        id: oldRow?.id ?? (_tagMap.length + 1).toString(),
        epc: tag.epc,
        times: (oldRow?.times ?? 0) + 1,
        // Using placeholders for data not available in RfidTag
        temp: '0',
        antId: '0',
        pc: '0',
        crc: '0',
      );
    });
  }

  // ======================
  // START SCAN
  // ======================
  Future<void> _handleScanStart() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _tagMap.clear(); // Clear previous results
    });

    try {
      await RfidService.stopInventory(); // Ensure it's stopped before starting
      await Future.delayed(const Duration(milliseconds: 100));

      final ok = await RfidService.startInventory();
      if (!ok) throw Exception("Could not start RFID inventory");

      _tagSubscription?.resume();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Start scan error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      _handleScanStop();
    }
  }

  // ======================
  // STOP SCAN
  // ======================
  Future<void> _handleScanStop() async {
    if (!_isScanning && mounted) return;

    await RfidService.stopInventory();
    _tagSubscription?.pause();

    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  // ======================
  // FILTER LOGIC
  // ======================
  List<TempRow> get _filteredRows {
    final List<TempRow> allRows = _tagMap.values.toList()
      ..sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));

    if (_searchText.isEmpty) return allRows;

    final q = _searchText.toLowerCase();
    return allRows.where((r) {
      return r.epc.toLowerCase().contains(q) ||
          r.id.toLowerCase().contains(q) ||
          r.antId.toLowerCase().contains(q);
    }).toList();
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TempActionBar(
          johar: false, // These are no longer used
          axzon: false,
          other: false,
          onToggle: (_) {}, // No longer needed
          onStart: _isScanning ? _handleScanStop : _handleScanStart,
          isScanning: _isScanning, // Pass the state
        ),

        const SizedBox(height: 8),

        // ================= SEARCH BAR =================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search EPC / ID / Antenna',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
          ),
        ),

        const SizedBox(height: 8),

        // ================= TABLE =================
        TempTable(rows: _filteredRows),
      ],
    );
  }
}
