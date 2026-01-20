import 'package:flutter/material.dart';

import '../widgets/header_menu.dart';

// INVENTORY
import 'inventory/inventory_settings.dart';
import 'inventory/inventory_action_row.dart';
import 'inventory/time_picker_sheet.dart';
import 'inventory/inventory_info_bar.dart';

// ACCESS
import 'Access/access_action_bar.dart';
import 'Access/access_settings.dart';

// TEMP
import 'temp/temp_page.dart';

// COMMON
import '../widgets/app_data_table.dart';

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// TAB CHÍNH
  String _activeMenu = 'Inventory';

  /// SETTINGS
  bool _showInventorySettings = false;
  bool _showAccessSettings = false;

  /// ACCESS MODE
  int _accessTabIndex = 0;

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

  void _onMenuSelected(String value) {
    if (value == 'reset') {
      setState(() => _rows.clear());
    }
  }

  // ======================
  // BODY
  // ======================
  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ================= INVENTORY =================
          if (_activeMenu == 'Inventory') ...[
            InventorySettings(
              expanded: _showInventorySettings,
              onToggle: () {
                setState(() {
                  _showInventorySettings = !_showInventorySettings;
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

          // ================= ACCESS =================
          if (_activeMenu == 'Access') ...[
            const SizedBox(height: 8),

            /// ACTION BAR – READ / WRITE / LOCK / DESTROY
            AccessActionBar(
              activeIndex: _accessTabIndex,
              onChanged: (i) {
                setState(() => _accessTabIndex = i);
              },
            ),

            const SizedBox(height: 8),

            /// PANEL NỘI DUNG ACCESS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    [
                      'READ TAG PANEL',
                      'WRITE TAG PANEL',
                      'LOCK TAG PANEL',
                      'DESTROY TAG PANEL',
                    ][_accessTabIndex],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            /// ACCESS SETTINGS – NÚT RIÊNG
            AccessSettings(
              expanded: _showAccessSettings,
              onToggle: () {
                setState(() {
                  _showAccessSettings = !_showAccessSettings;
                });
              },
            ),
          ],

          // ================= TEMP =================
          if (_activeMenu == 'Temp') ...[
            const SizedBox(height: 8),
            TempPage(),
          ],

          // ================= OTHER =================
          if (_activeMenu != 'Inventory' &&
              _activeMenu != 'Access' &&
              _activeMenu != 'Temp')
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '$_activeMenu content here',
                style: const TextStyle(fontSize: 16),
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          HeaderMenu(
            activeMenu: _activeMenu,
            onChanged: (menu) {
              setState(() {
                _activeMenu = menu;
                _showInventorySettings = false;
                _showAccessSettings = false;
              });
            },
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _onMenuSelected,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'reset', child: Text('Reset reader')),
              PopupMenuItem(value: 'monitor', child: Text('Data monitoring')),
              PopupMenuItem(value: 'language', child: Text('Language switch')),
              PopupMenuItem(value: 'connection', child: Text('Other connection')),
              PopupMenuItem(value: 'export', child: Text('Export to Excel')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'setup', child: Text('Set up')),
              PopupMenuItem(value: 'about', child: Text('About')),
              PopupMenuItem(value: 'find', child: Text('Find tag')),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
