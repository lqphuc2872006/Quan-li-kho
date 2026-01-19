import 'package:flutter/material.dart';

class HeaderMenu extends StatelessWidget {
  final String activeMenu;
  final ValueChanged<String> onChanged;

  const HeaderMenu({
    super.key,
    required this.activeMenu,
    required this.onChanged,
  });

  Widget _button(String title) {
    final isActive = activeMenu == title;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white24,
        highlightColor: Colors.transparent,
        onTap: () => onChanged(title),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight:
                  isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3,
                width: isActive ? 24 : 0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _button('Filter'),
        _button('Inventory'),
        _button('Access'),
        _button('Temp'),
        _button('Params'),
      ],
    );
  }
}
