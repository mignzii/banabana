import 'package:flutter/material.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';

class PinDot extends StatelessWidget {
  const PinDot({super.key, required this.filled});
  final bool filled;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        width: 16, height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? AppColors.primary : Colors.transparent,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
      );
}

class PinPad extends StatelessWidget {
  const PinPad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.disabled = false,
  });
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final keys = ['1','2','3','4','5','6','7','8','9','','0','⌫'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2,
      children: keys.map((k) {
        if (k.isEmpty) return const SizedBox.shrink();
        return InkWell(
          onTap: disabled ? null : () {
            if (k == '⌫') { onDelete(); } else { onDigit(k); }
          },
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(k,
                style: AppTextStyles.sectionTitle.copyWith(
                  color: disabled ? AppColors.gray300 : AppColors.gray900,
                )),
          ),
        );
      }).toList(),
    );
  }
}
