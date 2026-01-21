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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ===== CHECKBOX ROW =====
          Row(
            children: [
              _check('Johar', johar),
              _check('Axzon', axzon),
              _check('Other', other),
            ],
          ),

          const SizedBox(height: 12),

          /// ===== ACTION BUTTON =====
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'START INVENTORY',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _check(String label, bool value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
