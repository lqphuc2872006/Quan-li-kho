import 'package:flutter/material.dart';
import '../widgets/temp_action_bar.dart';
import '../widgets/temp_table.dart';

class TempPage extends StatefulWidget {
  const TempPage({super.key});

  @override
  State<TempPage> createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> {
  bool johar = false;
  bool axzon = false;
  bool other = false;

  final List<TempRow> _rows = [];
  String _searchText = '';

  // ======================
  // TOGGLE CHIP
  // ======================
  void _toggle(String key) {
    setState(() {
      if (key == 'Johar') johar = !johar;
      if (key == 'Axzon') axzon = !axzon;
      if (key == 'Other') other = !other;
    });
  }

  // ======================
  // START (FAKE DATA)
  // ======================
  void _startInventory() {
    setState(() {
      _rows.add(
        TempRow(
          id: '${_rows.length + 1}',
          temp: '32.${_rows.length}°C',
          antId: '1',
          times: _rows.length + 1,
          pc: '3000',
          crc: 'ABCD',
          epc: 'E2000017221101441890A1B${_rows.length}',
        ),
      );
    });
  }

  // ======================
  // FILTER LOGIC
  // ======================
  List<TempRow> get _filteredRows {
    if (_searchText.isEmpty) return _rows;

    final q = _searchText.toLowerCase();
    return _rows.where((r) {
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
          johar: johar,
          axzon: axzon,
          other: other,
          onToggle: _toggle,
          onStart: _startInventory,
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
