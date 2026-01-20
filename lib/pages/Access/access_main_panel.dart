import 'package:flutter/material.dart';
import 'access_action_bar.dart';

class AccessMainPanel extends StatefulWidget {
  const AccessMainPanel({super.key});

  @override
  State<AccessMainPanel> createState() => _AccessMainPanelState();
}

class _AccessMainPanelState extends State<AccessMainPanel> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// 🔥 READ / WRITE / LOCK / DESTROY (LUÔN HIỆN)
        AccessActionBar(
          activeIndex: _activeIndex,
          onChanged: (i) => setState(() => _activeIndex = i),
        ),

        const SizedBox(height: 12),

        /// 🔥 CONTENT THEO TAB
        _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    switch (_activeIndex) {
      case 0:
        return _readContent();
      case 1:
        return _writeContent();
      case 2:
        return _lockContent();
      case 3:
        return _destroyContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _readContent() => _card('READ TAG CONTENT');
  Widget _writeContent() => _card('WRITE TAG CONTENT');
  Widget _lockContent() => _card('LOCK TAG CONTENT');
  Widget _destroyContent() => _card('DESTROY TAG CONTENT');

  Widget _card(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
