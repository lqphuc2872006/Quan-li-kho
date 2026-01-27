import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/header_menu.dart';
import 'inventory/page/inventory_page.dart';
import 'Access/page/access_page.dart';
import 'temp/page/temp_page.dart';
import 'filter/page/filter_page.dart';
import 'params/page/params_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _activeIndex = 0;
  late final List<Widget> _pages;
  late final PageController _pageController;
  bool _isLoading = false;

  // Define navigation items
  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.inventory_2_outlined),
      activeIcon: Icon(Icons.inventory_2),
      label: 'Kho',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.security_outlined),
      activeIcon: Icon(Icons.security),
      label: 'Truy cập',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.thermostat_outlined),
      activeIcon: Icon(Icons.thermostat),
      label: 'Nhiệt độ',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pages = const [
      InventoryPage(),
      AccessPage(),
      TempPage(),
    ];
    _pageController = PageController(initialPage: _activeIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _activeIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _openFilter(BuildContext context) {
    _showModalBottomSheet(context, const FilterPage());
  }

  void _openParams(BuildContext context) {
    _showModalBottomSheet(context, const ParamsPage());
  }

  void _showModalBottomSheet(BuildContext context, Widget child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle for the modal
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Content
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () => _openFilter(context),
            tooltip: 'Bộ lọc',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _openParams(context),
            tooltip: 'Cài đặt',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _activeIndex = index);
            },
            children: _pages,
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _activeIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        elevation: 8,
      ),
    );
  }
}