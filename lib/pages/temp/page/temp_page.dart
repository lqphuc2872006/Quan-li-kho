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
    bool _isScanning = false;
    String _searchText = '';

    // 🔊 AUDIO
    final AudioPlayer _beepPlayer = AudioPlayer();
    DateTime _lastBeep = DateTime.fromMillisecondsSinceEpoch(0);

    // ⏱ TIMER
    Timer? _uiRefreshTimer;

    StreamSubscription<Map<dynamic, dynamic>>? _tagSubscription;

    // 📦 DATA
    final Map<String, TempRow> _buffer = {}; // raw RFID buffer
    final Map<String, TempRow> _tagMap = {}; // UI data

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
      _uiRefreshTimer?.cancel();
      _beepPlayer.dispose();
      if (_isScanning) {
        RfidService.stopInventory();
      }
      super.dispose();
    }

    // ================= RFID =================

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

    // ================= TAG EVENT (NO setState) =================

    void _onTagScanned(Map<dynamic, dynamic> raw) {
      final tag = RfidTag.fromMap(Map<String, dynamic>.from(raw));
      final old = _buffer[tag.epc];

      if (old != null) {
        _buffer[tag.epc] = TempRow(
          id: old.id,
          epc: tag.epc,
          times: old.times + 1,
          temp: old.temp,
          antId: old.antId,
          pc: old.pc,
          crc: old.crc,
        );
      } else {
        _buffer[tag.epc] = TempRow(
          id: (_buffer.length + 1).toString(),
          epc: tag.epc,
          times: 1,
          temp: '0',
          antId: '0',
          pc: '0',
          crc: '0',
        );
      }

      _beepDebounced();
    }

    // ================= BEEP DEBOUNCE =================

    void _beepDebounced() {
      final now = DateTime.now();
      if (now.difference(_lastBeep).inMilliseconds < 250) return;
      _lastBeep = now;
      _beepPlayer.play(AssetSource('sounds/beep.mp3'));
    }

    // ================= SCAN CONTROL =================

    Future<void> _handleScanStart() async {
      if (_isScanning) return;

      setState(() {
        _isScanning = true;
      });

      try {
        await RfidService.stopInventory();
        await Future.delayed(const Duration(milliseconds: 150));

        final ok = await RfidService.startInventory();
        if (!ok) throw Exception('Cannot start inventory');

        _tagSubscription?.resume();

        // ⏱ UI refresh mỗi 300ms
        _uiRefreshTimer = Timer.periodic(
          const Duration(milliseconds: 300),
              (_) {
            if (!_isScanning || !mounted) return;
            setState(() {
              _tagMap
                ..clear()
                ..addAll(_buffer);
            });
          },
        );
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

    Future<void> _handleScanStop() async {
      if (!_isScanning) return;

      await RfidService.stopInventory();
      _tagSubscription?.pause();
      _uiRefreshTimer?.cancel();

      setState(() {
        _isScanning = false;
        _tagMap
          ..clear()
          ..addAll(_buffer);
      });
    }

    // ================= CLEAR =================

    void _clearTable() {
      if (_isScanning) return;
      setState(() {
        _buffer.clear();
        _tagMap.clear();
      });
    }

    // ================= FILTER =================

    List<TempRow> get _filteredRows {
      final rows = _tagMap.values.toList()
        ..sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));

      if (_searchText.isEmpty) return rows;

      final q = _searchText.toLowerCase();
      return rows.where((r) {
        return r.epc.toLowerCase().contains(q) ||
            r.id.contains(q) ||
            r.antId.contains(q);
      }).toList();
    }

    // ================= UI =================

    @override
    Widget build(BuildContext context) {
      return Column(
        children: [
          TempActionBar(
            johar: false,
            axzon: false,
            other: false,
            onToggle: (_) {},
            onStart: _isScanning ? _handleScanStop : _handleScanStart,
            isScanning: _isScanning,
          ),

          const SizedBox(height: 8),

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
              onChanged: (v) => setState(() => _searchText = v),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: TempTable(rows: _filteredRows),
          ),

          if (_tagMap.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text(
                    'CLEAR DATA',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    _isScanning ? Colors.grey : Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isScanning ? null : _clearTable,
                ),
              ),
            ),
        ],
      );
    }
  }
