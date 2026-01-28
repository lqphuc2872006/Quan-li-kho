import 'dart:async';
import 'package:flutter/material.dart';

import '../../inventory/page/store/inventory_store.dart';
import '../../../services/models/inventory_tag.dart';
import '../../../services/models/temp_tag.dart';
import '../page/store/temp_store.dart';

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

  Timer? _pollTimer;

  // ================= START TEMP =================

  void _startTemp() {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    _pollTimer = Timer.periodic(
      const Duration(milliseconds: 300),
          (_) {
        if (!_isScanning) return;

        // 🔥 INVENTORY → TEMP STORE
        TempStore.upsertFromInventory(
          InventoryStore.all,
        );

        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  // ================= STOP TEMP =================

  void _stopTemp() {
    _pollTimer?.cancel();
    _pollTimer = null;

    setState(() {
      _isScanning = false;
    });
  }

  // ================= CLEAR =================

  void _clear() {
    if (_isScanning) return;

    TempStore.clear();
    setState(() {});
  }

  // ================= FILTER (STORE LEVEL) =================

  List<TempTag> get _filteredTags {
    final list = TempStore.all
      ..sort((a, b) => a.epc.compareTo(b.epc));

    if (_searchText.isEmpty) return list;

    final q = _searchText.toLowerCase();
    return list.where((t) =>
        t.epc.toLowerCase().contains(q)
    ).toList();
  }

  // ================= MAP TO UI ROW =================

  List<TempRow> get _uiRows {
    int index = 1;
    return _filteredTags.map((t) {
      return TempRow(
        id: (index++).toString(),
        epc: t.epc,
        times: t.times,
        temp: t.temp,
        antId: t.antId,
        pc: t.pc,
        crc: t.crc,
      );
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
          onStart: _isScanning ? _stopTemp : _startTemp,
          isScanning: _isScanning,
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search EPC',
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
          child: TempTable(
            rows: _uiRows, // ✅ ĐÚNG KIỂU
          ),
        ),

        if (TempStore.hasData)
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('CLEAR DATA'),
                onPressed: _clear,
              ),
            ),
          ),
      ],
    );
  }
}
