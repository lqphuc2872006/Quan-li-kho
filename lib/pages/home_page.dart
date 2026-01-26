import 'package:flutter/material.dart';

import '../widgets/header_menu.dart';

// INVENTORY PAGE (ĐÃ TÁCH)
import 'inventory/page/inventory_page.dart';

// ACCESS PAGE
import 'Access/page/access_page.dart';

// TEMP
import 'temp/page/temp_page.dart';

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
  // State preservation using an index and a list of pages
  int _activeIndex = 0;

  // Define the mapping from menu name to index
  final Map<String, int> _pageMap = {
    'Inventory': 0,
    'Access': 1,
    'Temp': 2,
  };

  // Create a persistent list of page widgets.
  // Using const ensures the pages themselves are not rebuilt.
  final List<Widget> _pages = const [
    InventoryPage(),
    AccessPage(),
    TempPage(),
  ];


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

  // Helper to get the current active menu string from the index
  String get _activeMenu {
    return _pageMap.keys.firstWhere(
      (key) => _pageMap[key] == _activeIndex,
      orElse: () => 'Inventory',
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
              // Update state based on the selected menu's index
              setState(() {
                _activeIndex = _pageMap[menu] ?? 0;
              });
            },
            onMenuSelected: _onMenuSelected, // ⭐ menu 3 chấm
          ),
        ],
      ),

      // Use IndexedStack to preserve state of children
      body: IndexedStack(
        index: _activeIndex,
        children: _pages,
      ),
    );
  }
}
