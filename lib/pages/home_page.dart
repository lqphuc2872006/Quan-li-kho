import 'package:flutter/material.dart';

import '../widgets/header_menu.dart';

// INVENTORY PAGE (ĐÃ TÁCH)
import 'inventory/page/inventory_page.dart';

// ACCESS PAGE
import 'Access/page/access_page.dart';

// TEMP
import 'temp/widgets/temp_page.dart';

//Filter
import 'filter/page/filter_page.dart';

//params
import 'params/page/params_page.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// MENU CHÍNH
  String _activeMenu = 'Inventory';

  void _onMenuSelected(String value) {
    // xử lý menu chung (nếu cần)
  }

  //Mo filter
  void _openFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.9,
        child: FilterPage(),
      ),
    );
  }

  void _openParams(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.9,
        child: ParamsPage(),
      ),
    );
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
            const InventoryPage(),
          ],

          // ================= ACCESS =================
          if (_activeMenu == 'Access') ...[
            const AccessPage(),
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
              if (menu == 'Filter') {
                _openFilter(context);
                return;
              }
              if (menu == 'Params') {
                _openParams(context);
                return;
              }
              setState(() {
                _activeMenu = menu;
              });
            },
            onMenuSelected: _onMenuSelected, // ⭐ menu 3 chấm
          ),
        ],
      ),

      body: _buildBody(),
    );
  }
}
