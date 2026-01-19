import 'package:flutter/material.dart';

class InventoryInfoBar extends StatelessWidget {
  final int tags;
  final int speed;
  final int total;
  final int execTime;

  const InventoryInfoBar({
    super.key,
    required this.tags,
    required this.speed,
    required this.total,
    required this.execTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          /// TAGS + SPEED
          Expanded(
            child: _InfoGroup(
              leftLabel: 'Tags',
              leftValue: '$tags',
              rightLabel: 'Speed',
              rightValue: '$speed p/s',
              highlight: true,
            ),
          ),
          const SizedBox(width: 12),

          /// ALL DATA + EXEC TIME
          Expanded(
            child: _InfoGroup(
              leftLabel: 'All data',
              leftValue: '$total p',
              rightLabel: 'Exec time',
              rightValue: '${execTime}s',
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoGroup extends StatelessWidget {
  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;
  final bool highlight;

  const _InfoGroup({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _InfoItem(
            label: leftLabel,
            value: leftValue,
            highlight: highlight,
          ),
          Container(
            width: 1,
            height: 32,
            color: Colors.grey.shade300,
          ),
          _InfoItem(
            label: rightLabel,
            value: rightValue,
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _InfoItem({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: highlight ? Colors.blue : Colors.black,
          ),
        ),
      ],
    );
  }
}
