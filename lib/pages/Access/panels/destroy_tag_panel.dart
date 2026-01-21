import 'package:flutter/material.dart';

class DestroyTagPanel extends StatelessWidget {
  const DestroyTagPanel({super.key});

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
                'Destroy tag',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              /// ===== WARNING =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Destroy (Kill) will permanently disable the tag. '
                            'This operation cannot be undone.',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// ===== DESTROY PASSWORD =====
              _PasswordField(
                label: 'Destroy pwd (HEX)',
                hint: '00000000',
              ),

              const SizedBox(height: 20),

              /// ===== ACTION BUTTON =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO:
                    // 1. Hiện confirm dialog
                    // 2. Gọi SDK KILL TAG
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'DESTROY TAG',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
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

class _PasswordField extends StatelessWidget {
  final String label;
  final String hint;

  const _PasswordField({
    required this.label,
    required this.hint,
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
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
