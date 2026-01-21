import 'package:flutter/material.dart';
import 'temp_action_bar.dart';
import 'temp_table.dart';

class TempPage extends StatefulWidget {
  const TempPage({super.key});

  @override
  State<TempPage> createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> {
  bool johar = false;
  bool axzon = false;
  bool other = false;

  final List<TempRow> rows = [];

  void _toggle(String key) {
    setState(() {
      if (key == 'Johar') johar = !johar;
      if (key == 'Axzon') axzon = !axzon;
      if (key == 'Other') other = !other;
    });
  }

  void _startInventory() {
    setState(() {
      rows.add(
        TempRow(
          id: '${rows.length + 1}',
          temp: '32.${rows.length}°C',
          antId: '1',
          times: rows.length + 1,
          pc: '3000',
          crc: 'ABCD',
          epc: 'E2000017221101441890A1B2',
        ),
      );
    });
  }

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
        TempTable(rows: rows),
      ],
    );
  }
}
