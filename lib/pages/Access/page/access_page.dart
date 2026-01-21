import 'package:flutter/material.dart';
import 'package:untitled3/pages/Access/panels/destroy_tag_panel.dart';
import 'package:untitled3/pages/Access/panels/lock_tag_panel.dart';

import '../widgets/access_action_bar.dart';
import '../widgets/access_settings.dart';

// PANELS
import '../panels/read_tag_panel.dart';
import '../panels/write_tag_panel.dart';
// import '../panels/lock_tag_panel.dart';
// import '../panels/destroy_tag_panel.dart';

class AccessPage extends StatefulWidget {
  const AccessPage({super.key});

  @override
  State<AccessPage> createState() => _AccessPageState();
}

class _AccessPageState extends State<AccessPage> {
  bool _showAccessSettings = false;
  int _accessTabIndex = 0;

  /// ======================
  /// BUILD PANEL THEO TAB
  /// ======================
  Widget _buildAccessPanel() {
    switch (_accessTabIndex) {
      case 0:
        return const ReadTagPanel();
      case 1:
        return const WriteTagPanel();
      case 2:
        return const LockTagPanel();
      case 3:
        return const DestroyTagPanel();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _placeholder(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// ACCESS SETTINGS
        AccessSettings(
          expanded: _showAccessSettings,
          onToggle: () {
            setState(() {
              _showAccessSettings = !_showAccessSettings;
            });
          },
        ),

        const SizedBox(height: 8),

        /// ACTION BAR – READ / WRITE / LOCK / DESTROY
        AccessActionBar(
          activeIndex: _accessTabIndex,
          onChanged: (i) {
            setState(() => _accessTabIndex = i);
          },
        ),

        const SizedBox(height: 8),

        /// PANEL CONTENT
        _buildAccessPanel(),
      ],
    );
  }
}
