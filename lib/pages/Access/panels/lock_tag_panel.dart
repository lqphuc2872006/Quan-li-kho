import 'package:flutter/material.dart';

class LockTagPanel extends StatelessWidget {
  const LockTagPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ===== TITLE =====
              const Text(
                'Lock tag',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              /// ===== LOCK AREA =====
              _DropdownRow(
                label: 'Lock area',
                value: 'USER',
                items: const [
                  'EPC',
                  'TID',
                  'USER',
                  'ACCESS PWD',
                  'KILL PWD',
                ],
                onChanged: (_) {},
              ),

              const SizedBox(height: 12),

              /// ===== LOCK TYPE =====
              _DropdownRow(
                label: 'Lock type',
                value: 'Open',
                items: const [
                  'Open',
                  'Permanent Open',
                  'Lock',
                  'Permanent Lock',
                ],
                onChanged: (_) {},
              ),

              const SizedBox(height: 20),

              /// ===== ACTION BUTTON =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: gọi SDK LOCK TAG
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'LOCK TAG',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===================================================
/// PRIVATE COMPONENTS – CHỈ DÙNG TRONG FILE NÀY
/// ===================================================

class _DropdownRow extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map(
                (e) => DropdownMenuItem(
              value: e,
              child: Text(e),
            ),
          )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
