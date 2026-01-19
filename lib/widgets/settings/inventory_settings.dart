import 'package:flutter/material.dart';

class InventorySettings extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;

  const InventorySettings({
    super.key,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// NÚT MỞ / ĐÓNG SETTINGS
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onToggle,
              icon: const Icon(Icons.settings),
              label: const Text(
                'Inventory settings',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),

        /// PANEL SETTINGS
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState:
          expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: _SettingsPanel(),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// ================= PANEL =================
class _SettingsPanel extends StatelessWidget {
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
            children: const [
              _SectionTitle('Read mode'),
              _CheckItem(
                title: 'Fast TID',
                subtitle: 'Đọc nhanh EPC + TID',
              ),
              _CheckItem(
                title: 'Tag Focus',
                subtitle: 'Tối ưu đọc nhiều tag',
              ),

              Divider(height: 28),

              _SectionTitle('Inventory optimization'),
              _RowSelect(
                label: 'Antenna',
                value: '1',
              ),
              _RowSelect(
                label: 'Session',
                value: 'S0',
              ),
              _RowSelect(
                label: 'Target',
                value: 'A',
              ),

              Divider(height: 28),

              _SectionTitle('Advanced'),
              _CheckItem(title: 'Fast switch inventory'),
              _CheckItem(title: 'Phase'),
              _CheckItem(title: 'Freezer'),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= COMPONENTS =================

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _CheckItem({
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: false,
      onChanged: (_) {},
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
        subtitle!,
        style: const TextStyle(fontSize: 12),
      )
          : null,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

class _RowSelect extends StatelessWidget {
  final String label;
  final String value;

  const _RowSelect({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}
