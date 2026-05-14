import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';

enum OrderProgressStep { placed, accepted, inDelivery, delivered }

extension OrderProgressStepX on String {
  OrderProgressStep toProgressStep() => switch (toLowerCase()) {
    'pending'    => OrderProgressStep.placed,
    'accepted'   => OrderProgressStep.accepted,
    'shipped'    => OrderProgressStep.inDelivery,
    'delivered'  => OrderProgressStep.delivered,
    _            => OrderProgressStep.placed,
  };
}

class OrderProgressBar extends StatelessWidget {
  const OrderProgressBar({super.key, required this.currentStatus});

  final String currentStatus;

  static const _steps = [
    (OrderProgressStep.placed,     'Placée',       Symbols.receipt_long),
    (OrderProgressStep.accepted,   'Acceptée',     Symbols.check_circle),
    (OrderProgressStep.inDelivery, 'En livraison', Symbols.local_shipping),
    (OrderProgressStep.delivered,  'Livrée',       Symbols.home),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final current = currentStatus.toProgressStep();
    final currentIndex = OrderProgressStep.values.indexOf(current);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Ligne de connexion
            final lineIndex = i ~/ 2;
            final isCompleted = lineIndex < currentIndex;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 2,
                color: isCompleted
                    ? AppColors.primary
                    : (isDark ? AppColors.darkBorder2 : AppColors.gray200),
              ),
            );
          }
          // Étape
          final stepIndex = i ~/ 2;
          final (_, label, icon) = _steps[stepIndex];
          final isCompleted = stepIndex <= currentIndex;
          final isCurrent = stepIndex == currentIndex;

          return _StepDot(
            label: label,
            icon: icon,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
            isDark: isDark,
          );
        }),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.label,
    required this.icon,
    required this.isCompleted,
    required this.isCurrent,
    required this.isDark,
  });

  final String label;
  final IconData icon;
  final bool isCompleted;
  final bool isCurrent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final dotColor = isCompleted
        ? AppColors.primary
        : (isDark ? AppColors.darkSurface2 : AppColors.gray200);
    final iconColor = isCompleted
        ? AppColors.white
        : (isDark ? AppColors.gray600 : AppColors.gray400);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCurrent ? 36 : 28,
          height: isCurrent ? 36 : 28,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, size: isCurrent ? 18 : 14, color: iconColor),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isCompleted
                ? AppColors.primary
                : (isDark ? AppColors.gray600 : AppColors.gray400),
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
            fontSize: 9,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
