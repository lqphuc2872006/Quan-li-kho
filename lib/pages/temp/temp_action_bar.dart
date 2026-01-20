import 'package:flutter/material.dart';

class TempActionBar extends StatelessWidget {
  final bool johar;
  final bool axzon;
  final bool other;
  final VoidCallback onStart;
  final ValueChanged<String> onToggle;

  const TempActionBar({
    super.key,
    required this.johar,
    required this.axzon,
    required this.other,
    required this.onStart,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _check('Johar', johar),
          _check('Axzon', axzon),
          _check('Other', other),
          const Spacer(),
          ElevatedButton(
            onPressed: onStart,
            child: const Text('START INVENTORY'),
          ),
        ],
      ),
    );
  }

  Widget _check(String label, bool value) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (_) => onToggle(label),
        ),
        Text(label),
        const SizedBox(width: 8),
      ],
    );
  }
}
