import 'package:flutter/material.dart';

class AccessActionBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onChanged;

  const AccessActionBar({
    super.key,
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final labels = ['Read', 'Write', 'Lock', 'Destroy'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = activeIndex == i;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.indigo.shade700
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
