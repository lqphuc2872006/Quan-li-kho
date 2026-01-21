import 'package:flutter/material.dart';

import '../widgets/inventory_settings.dart';
import '../widgets/inventory_action_row.dart';
import '../widgets/time_picker_sheet.dart';
import '../widgets/inventory_info_bar.dart';
import '../../../widgets/app_data_table.dart';

/// ======================
/// MODEL INVENTORY
/// ======================
class InventoryRow {
  final int no;
  final String tagId;
  final String rssi;
  final String time;
  final String status;

  InventoryRow({
    required this.no,
    required this.tagId,
    required this.rssi,
    required this.time,
    required this.status,
  });
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  bool _showSettings = false;

  // ======================
  // TIME INVENTORY
  // ======================
  int _timeValue = 5;
  String _timeUnit = 'seconds';

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

  // ======================
  // INVENTORY DATA
  // ======================
  final List<InventoryRow> _rows = [
    InventoryRow(
      no: 1,
      tagId: 'E2000017221101441890A1B2',
      rssi: '-45 dBm',
      time: '10:32:11',
      status: 'OK',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// SETTINGS
        InventorySettings(
          expanded: _showSettings,
          onToggle: () {
            setState(() {
              _showSettings = !_showSettings;
            });
          },
        ),

        InventoryActionRow(
          timeDisplay: _timeDisplay,
          onPickTime: () {
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
          onStart: () {},
          onClear: () => setState(() => _rows.clear()),
        ),

        const SizedBox(height: 8),

        InventoryInfoBar(
          tags: _rows.length,
          speed: 13,
          total: _rows.length,
          execTime: 0,
        ),

        const SizedBox(height: 8),

        AppDataTable(
          headers: const ['No', 'Tag ID', 'RSSI', 'Time', 'Status'],
          rows: _rows.map((r) {
            return [
              Text(r.no.toString()),
              Text(r.tagId),
              Text(r.rssi),
              Text(r.time),
              Text(
                r.status,
                style: TextStyle(
                  color: r.status == 'OK'
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ];
          }).toList(),
        ),
      ],
    );
  }
}
