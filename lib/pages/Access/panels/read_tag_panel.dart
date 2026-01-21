import 'package:flutter/material.dart';

class ReadTagPanel extends StatelessWidget {
  const ReadTagPanel({super.key});

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
                'Read tag',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              /// ===== MULTI AREA =====
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (_) {},
                  ),
                  const Text('Multi-area reading'),
                ],
              ),

              const SizedBox(height: 12),

              /// ===== ACCESS AREA =====
              _DropdownRow(
                label: 'Access area',
                value: 'EPC',
                items: const ['EPC', 'TID', 'USER', 'RESERVED'],
                onChanged: (_) {},
              ),

              const SizedBox(height: 10),

              /// ===== START ADDR =====
              _NumberField(
                label: 'Start addr (WORD)',
                initialValue: '2',
              ),

              const SizedBox(height: 10),

              /// ===== DATA LEN =====
              _NumberField(
                label: 'Data len (WORD)',
                initialValue: '2',
              ),

              const SizedBox(height: 14),

              /// ===== OPTIONS =====
              Row(
                children: const [
                  _OptionCheckbox(label: 'LED'),
                  SizedBox(width: 16),
                  _OptionCheckbox(label: 'Repeat'),
                ],
              ),

              const SizedBox(height: 18),

              /// ===== ACTION BUTTON =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: gọi SDK READ TAG
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
                    'READ TAG',
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
/// COMPONENTS (PRIVATE – CHỈ DÙNG TRONG FILE NÀY)
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

class _NumberField extends StatelessWidget {
  final String label;
  final String initialValue;

  const _NumberField({
    required this.label,
    required this.initialValue,
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
        TextFormField(
          initialValue: initialValue,
          keyboardType: TextInputType.number,
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

class _OptionCheckbox extends StatelessWidget {
  final String label;

  const _OptionCheckbox({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: false,
          onChanged: (_) {},
        ),
        Text(label),
      ],
    );
  }
}
