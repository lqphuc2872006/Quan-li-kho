import 'package:flutter/material.dart';

class InventoryActionRow extends StatelessWidget {
  final String timeDisplay;
  final VoidCallback onPickTime;
  final VoidCallback onStart;
  final VoidCallback onClear;
  final bool isScanning;

  const InventoryActionRow({
    super.key,
    required this.timeDisplay,
    required this.onPickTime,
    required this.onStart,
    required this.onClear,
    this.isScanning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.timer),
              label: Text('Time ($timeDisplay)'),
              onPressed: isScanning ? null : onPickTime,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              icon: Icon(isScanning ? Icons.stop : Icons.play_arrow),
              label: Text(isScanning ? 'Stop' : 'Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isScanning ? Colors.red : null,
              ),
              onPressed: onStart,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
              onPressed: isScanning ? null : onClear,
            ),
          ),
        ],
      ),
    );
  }
}
