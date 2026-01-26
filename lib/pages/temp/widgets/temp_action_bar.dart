import 'package:flutter/material.dart';

class TempActionBar extends StatelessWidget {
  final bool johar;
  final bool axzon;
  final bool other;
  final VoidCallback onStart;
  final ValueChanged<String> onToggle;
  final bool isScanning; // New parameter

  const TempActionBar({
    super.key,
    required this.johar,
    required this.axzon,
    required this.other,
    required this.onStart,
    required this.onToggle,
    required this.isScanning, // New parameter
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
                backgroundColor: isScanning ? Colors.red : Colors.blue, // Dynamic color
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text( // Dynamic text
                isScanning ? 'STOP INVENTORY' : 'START INVENTORY',
                style: const TextStyle(
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
