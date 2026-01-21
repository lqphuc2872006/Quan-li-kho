import 'package:flutter/material.dart';

class HeaderMenu extends StatelessWidget {
  final String activeMenu;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onMenuSelected; // ⭐ menu 3 chấm

  const HeaderMenu({
    super.key,
    required this.activeMenu,
    required this.onChanged,
    required this.onMenuSelected,
  });

  Widget _button(String title) {
    final isActive = activeMenu == title;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.white24,
        highlightColor: Colors.transparent,
        onTap: () => onChanged(title),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight:
                  isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: isActive ? 16 : 0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moreMenu() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: const Icon(
        Icons.more_vert,
        size: 18,
        color: Colors.white,
      ),
      onSelected: onMenuSelected,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _button('Filter'),
        _button('Inventory'),
        _button('Access'),
        _button('Temp'),
        _button('Params'),
        const SizedBox(width: 4),
        _moreMenu(), // ⭐ menu ngay cạnh Params
      ],
    );
  }
}
