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
    const activeColor = Colors.blue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = activeIndex == i;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        color: active
                            ? Colors.blue.shade700
                            : Colors.grey.shade700,
                        fontWeight:
                        active ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  /// GẠCH CHÂN ACTIVE
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 3,
                    width: active ? 28 : 0,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
