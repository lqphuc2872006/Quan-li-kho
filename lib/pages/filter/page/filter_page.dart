import 'package:flutter/material.dart';

class FilterPage extends StatelessWidget {
  const FilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          /// ================= HEADER =================
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text(
                  'Filter settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          /// ================= BODY =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ===== FILTER SETTINGS =====
                  _sectionTitle('Filter settings'),

                  Row(
                    children: const [
                      Expanded(child: _Dropdown(label: 'Filter ID', value: 'Mask No.1')),
                      SizedBox(width: 12),
                      Expanded(child: _Dropdown(label: 'Session', value: 'S0')),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: const [
                      Expanded(child: _Dropdown(label: 'Filter action', value: '00')),
                      SizedBox(width: 12),
                      Expanded(child: _Dropdown(label: 'Filter area', value: 'Reserve')),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: const [
                      Expanded(child: _NumberField(label: 'Start address (bit)')),
                      SizedBox(width: 12),
                      Expanded(child: _NumberField(label: 'Filter length (bit)')),
                    ],
                  ),

                  const SizedBox(height: 8),

                  const _TextField(label: 'Filter value (HEX)'),

                  const SizedBox(height: 12),

                  _primaryButton('SET FILTER'),

                  const SizedBox(height: 20),

                  /// ===== CLEAR SETTINGS =====
                  _sectionTitle('Clear settings'),

                  Row(
                    children: [
                      const Expanded(child: _Dropdown(label: 'ID', value: 'Mask All')),
                      const SizedBox(width: 12),
                      Expanded(child: _secondaryButton('CLEAR FILTER')),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// ===== QUERY SETTINGS =====
                  _sectionTitle('Query settings'),

                  _secondaryButton('QUERY FILTER'),

                  const SizedBox(height: 12),

                  /// ===== RESULT TABLE HEADER =====
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Expanded(child: Text('ID', style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(child: Text('Session', style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(child: Text('Action', style: TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(child: Text('Area', style: TextStyle(fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= COMPONENTS =================

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _primaryButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _secondaryButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}

/// ================= INPUT WIDGETS =================

class _Dropdown extends StatelessWidget {
  final String label;
  final String value;

  const _Dropdown({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          items: [value]
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (_) {},
          decoration: _decoration(),
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;

  const _NumberField({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: _decoration(),
        ),
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;

  const _TextField({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        TextFormField(
          decoration: _decoration(),
        ),
      ],
    );
  }
}

InputDecoration _decoration() {
  return InputDecoration(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );
}
