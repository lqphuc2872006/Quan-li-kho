import 'package:flutter/material.dart';


class AccessSettings extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;

  const AccessSettings({
    super.key,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onToggle,
              icon: const Icon(Icons.settings),
              label: const Text(
                'Access settings',
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

        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: const [
              Text('Power / Session / Target / Filter / Antenna'),
            ],
          ),
        ),
      ),
    );
  }
}
