import 'package:flutter/material.dart';

Future<void> showTimePickerSheet({
  required BuildContext context,
  required int value,
  required String unit,
  required Function(int, String) onApply,
}) {
  int tempValue = value;
  String tempUnit = unit;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TIÊU ĐỀ
                const Text(
                  'Thời gian inventory',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                /// GIÁ TRỊ THỜI GIAN
                DropdownButtonFormField<int>(
                  value: tempValue,
                  decoration: const InputDecoration(
                    labelText: 'Giá trị',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(
                    60,
                        (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text('${i + 1}'),
                    ),
                  ),
                  onChanged: (v) {
                    setState(() {
                      tempValue = v!;
                    });
                  },
                ),

                const SizedBox(height: 12),

                /// ĐƠN VỊ THỜI GIAN
                DropdownButtonFormField<String>(
                  value: tempUnit,
                  decoration: const InputDecoration(
                    labelText: 'Đơn vị',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'seconds',
                      child: Text('Giây'),
                    ),
                    DropdownMenuItem(
                      value: 'minutes',
                      child: Text('Phút'),
                    ),
                    DropdownMenuItem(
                      value: 'hours',
                      child: Text('Giờ'),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      tempUnit = v!;
                    });
                  },
                ),

                const SizedBox(height: 20),

                /// NÚT ÁP DỤNG
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      onApply(tempValue, tempUnit);
                      Navigator.pop(context);
                    },
                    child: const Text('Áp dụng'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
