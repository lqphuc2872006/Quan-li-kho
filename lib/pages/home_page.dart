import 'package:flutter/material.dart';

import '../widgets/header_menu.dart';
import '../widgets/inventory_settings.dart';
import '../widgets/inventory_action_row.dart';
import '../widgets/time_picker_sheet.dart';
import '../widgets/inventory_table.dart';
import '../widgets/inventory_info_bar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// Menu đang được chọn trên header
  String _activeMenu = 'Inventory';

  /// Trạng thái mở / đóng phần cài đặt Inventory
  bool _showInventorySettings = false;

  // ======================
  // THỜI GIAN INVENTORY
  // ======================
  int _timeValue = 5;          // Giá trị thời gian
  String _timeUnit = 'seconds'; // seconds | minutes | hours

  /// Chuỗi hiển thị thời gian (vd: 5 s, 3 min, 1 h)
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
  // DỮ LIỆU BẢNG INVENTORY
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

  // ======================
  // MENU DỌC (3 CHẤM)
  // ======================
  void _onMenuSelected(String value) {
    if (value == 'reset') {
      // Xoá toàn bộ dữ liệu inventory
      setState(() {
        _rows.clear();
      });
    }
  }

  // ======================
  // NỘI DUNG CHÍNH
  // ======================
  Widget _buildBody() {
    // Nếu không ở tab Inventory thì chỉ hiển thị text
    if (_activeMenu != 'Inventory') {
      return Center(
        child: Text('$_activeMenu content here'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          /// PHẦN CÀI ĐẶT INVENTORY
          InventorySettings(
            expanded: _showInventorySettings,
            onToggle: () {
              setState(() {
                _showInventorySettings = !_showInventorySettings;
              });
            },
          ),

          /// THANH THAO TÁC: TIME / START / CLEAR
          InventoryActionRow(
            timeDisplay: _timeDisplay,
            onPickTime: () {
              showTimePickerSheet(
                context: context,
                value: _timeValue,
                unit: _timeUnit,
                onApply: (value, unit) {
                  setState(() {
                    _timeValue = value;
                    _timeUnit = unit;
                  });
                },
              );
            },
            onStart: () {
              // Chưa xử lý logic start
            },
            onClear: () {
              setState(() {
                _rows.clear();
              });
            },
          ),

          const SizedBox(height: 8),

          /// THANH THÔNG SỐ (Tags + Speed | All data + Exec time)
          InventoryInfoBar(
            tags: _rows.length,
            speed: 13,        // Tạm thời mock
            total: _rows.length,
            execTime: 0,      // Tạm thời mock
          ),

          const SizedBox(height: 8),

          /// BẢNG DỮ LIỆU INVENTORY
          InventoryTable(rows: _rows),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ======================
  // BUILD GIAO DIỆN
  // ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),

        /// MENU NGANG + MENU DỌC
        actions: [
          HeaderMenu(
            activeMenu: _activeMenu,
            onChanged: (menu) {
              setState(() {
                _activeMenu = menu;

                // Rời Inventory thì tự đóng phần settings
                if (menu != 'Inventory') {
                  _showInventorySettings = false;
                }
              });
            },
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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

          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }
}
