import 'package:flutter/material.dart';

class ParamsPage extends StatelessWidget {
  const ParamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= FIRMWARE =================
          _section(
            title: 'Query firmware version',
            child: _fullButton('FDW.1.1'),
          ),

          /// ================= TEMPERATURE =================
          _section(
            title: 'Read temperature',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _dropdown('Antenna', '1')),
                    const SizedBox(width: 12),
                    Expanded(child: _input('')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _grayButton('READ')),
                    const SizedBox(width: 12),
                    Expanded(child: _grayButton('SET UP')),
                  ],
                ),
              ],
            ),
          ),

          /// ================= RF POWER =================
          _section(
            title: 'Temporary RF output power',
            trailing: const Chip(label: Text('Permanent')),
            child: Column(
              children: [
                Slider(
                  value: 33,
                  min: 0,
                  max: 33,
                  divisions: 33,
                  onChanged: (_) {},
                ),
                Row(
                  children: [
                    Expanded(child: _grayButton('-')),
                    const SizedBox(width: 12),
                    Expanded(child: _grayButton('READ')),
                    const SizedBox(width: 12),
                    Expanded(child: _grayButton('+')),
                  ],
                ),
              ],
            ),
          ),

          /// ================= BUZZER =================
          _section(
            title: 'Buzzer',
            child: Column(
              children: [
                _radio('Quiet', false),
                _radio('Sound after inventory', true),
                _radio('Every time you read a tag sound', false),
                const SizedBox(height: 8),
                _grayButton('Set the buzzer'),
              ],
            ),
          ),

          /// ================= READER IDENTIFICATION =================
          _section(
            title: 'Reader identification',
            child: Row(
              children: [
                Expanded(child: _grayButton('READ')),
                const SizedBox(width: 12),
                Expanded(child: _grayButton('SET UP')),
              ],
            ),
          ),

          /// ================= READER ADDRESS =================
          _section(
            title: 'Set reader address [0, FF]',
            child: Row(
              children: [
                Expanded(child: _input('01')),
                const SizedBox(width: 12),
                Expanded(child: _grayButton('SET UP')),
              ],
            ),
          ),

          /// ================= READER STATUS =================
          _section(
            title: 'Reader status [0, FF]',
            child: Row(
              children: [
                Expanded(child: _input('')),
                const SizedBox(width: 12),
                Expanded(child: _grayButton('READ')),
                const SizedBox(width: 12),
                Expanded(child: _grayButton('SET UP')),
              ],
            ),
          ),

          /// ================= RETURN LOSS =================
          _section(
            title: 'Return loss threshold [0,255]',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _input('dB')),
                    const SizedBox(width: 12),
                    Expanded(child: _grayButton('READ')),
                    const SizedBox(width: 12),
                    Expanded(child: _grayButton('SET UP')),
                  ],
                ),
                const SizedBox(height: 8),
                _hintText(
                  '1. The system automatically measures return loss.\n'
                      '2. Error if return loss > threshold.\n'
                      '3. Set 0 to disable this function.',
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('RL: 0 @'),
                    const SizedBox(width: 8),
                    Expanded(child: _dropdown('', '865.00')),
                    const SizedBox(width: 4),
                    const Text('MHz'),
                  ],
                ),
                const SizedBox(height: 8),
                _grayButton('Measuring return loss'),
              ],
            ),
          ),

          /// ================= GPIO =================
          _section(
            title: 'GPIO',
            child: _grayButton('Read and write GPIO'),
          ),

          /// ================= RF PARAM =================
          _section(
            title: 'RF parameter',
            child: _grayButton('RF parameter setting'),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// ================= COMPONENTS =================

  Widget _section({
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (trailing != null) ...[
                  const Spacer(),
                  trailing,
                ],
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _fullButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        child: Text(text),
      ),
    );
  }

  Widget _grayButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.black87,
        ),
        child: Text(text),
      ),
    );
  }

  Widget _input(String value) {
    return TextFormField(
      initialValue: value,
      decoration: const InputDecoration(
        isDense: true,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _dropdown(String label, String value) {
    return DropdownButtonFormField<String>(
      value: value,
      items: [value]
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (_) {},
      decoration: const InputDecoration(
        isDense: true,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _radio(String text, bool selected) {
    return RadioListTile<bool>(
      value: true,
      groupValue: selected,
      onChanged: (_) {},
      title: Text(text),
      dense: true,
    );
  }

  Widget _hintText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    );
  }
}
