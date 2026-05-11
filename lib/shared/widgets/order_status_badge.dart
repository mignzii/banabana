import 'package:flutter/material.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/shared/models/order.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      OrderStatus.created   => ('Nouvelle', AppColors.info, Icons.fiber_new),
      OrderStatus.preparing => ('En préparation', AppColors.warning, Icons.inventory_2),
      OrderStatus.shipped   => ('Expédiée', AppColors.primary, Icons.local_shipping),
      OrderStatus.delivered => ('Livrée', AppColors.success, Icons.check_circle),
      OrderStatus.cancelled => ('Annulée', AppColors.error, Icons.cancel),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
