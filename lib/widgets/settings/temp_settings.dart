import 'package:flutter/material.dart';

const Color kPrimaryBlue = Color(0xFF0D47A1);

class TempSettings extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;

  final bool johar;
  final bool axzon;
  final bool other;

  final ValueChanged<bool> onJoharChanged;
  final ValueChanged<bool> onAxzonChanged;
  final ValueChanged<bool> onOtherChanged;

  final VoidCallback onStart;

  const TempSettings({
    super.key,
    required this.expanded,
    required this.onToggle,
    required this.johar,
    required this.axzon,
    required this.other,
    required this.onJoharChanged,
    required this.onAxzonChanged,
    required this.onOtherChanged,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// BUTTON
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onToggle,
              icon: const Icon(Icons.thermostat),
              label: const Text(
                'Temp settings',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),

        /// PANEL
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState:
          expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: _panel(),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _panel() {
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
              const Text(
                'Chip type',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryBlue,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  _check('Johar', johar, onJoharChanged),
                  _check('Axzon', axzon, onAxzonChanged),
                  _check('Other', other, onOtherChanged),
                ],
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'START INVENTORY',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _check(String label, bool value, ValueChanged<bool> onChanged) {
    return Expanded(
      child: CheckboxListTile(
        value: value,
        onChanged: (v) => onChanged(v!),
        title: Text(label),
        activeColor: kPrimaryBlue,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
