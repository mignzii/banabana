import 'package:banabana_b2b/features/producer/data/order_repository.dart';
import 'package:banabana_b2b/shared/models/order.dart';

class DailyRevenue {
  final DateTime date;
  final double revenue;
  DailyRevenue(this.date, this.revenue);
}

class TopProduct {
  final String productId;
  final String title;
  final int totalQuantity;
  final double totalRevenue;
  TopProduct(this.productId, this.title, this.totalQuantity, this.totalRevenue);
}

class AnalyticsSummary {
  final double totalRevenue;
  final int totalOrders;
  final int pendingOrders;
  final List<DailyRevenue> revenueByDay;
  final List<TopProduct> topProducts;

  AnalyticsSummary({
    required this.totalRevenue,
    required this.totalOrders,
    required this.pendingOrders,
    required this.revenueByDay,
    required this.topProducts,
  });
}

class AnalyticsRepository {
  final OrderRepository _orderRepo;
  AnalyticsRepository(this._orderRepo);

  Future<AnalyticsSummary> getSummary() async {
    final orders = await _orderRepo.getMyOrders();
    final delivered = orders.where((o) => o.status == OrderStatus.delivered).toList();
    final pending = orders
        .where((o) =>
            o.status == OrderStatus.created || o.status == OrderStatus.preparing)
        .length;

    final totalRevenue =
        delivered.fold<double>(0, (sum, o) => sum + o.totalAmount);

    final now = DateTime.now();
    final revenueByDay = List.generate(30, (i) {
      final day = now.subtract(Duration(days: 29 - i));
      final dayRevenue = delivered
          .where((o) =>
              o.createdAt.year == day.year &&
              o.createdAt.month == day.month &&
              o.createdAt.day == day.day)
          .fold<double>(0, (sum, o) => sum + o.totalAmount);
      return DailyRevenue(day, dayRevenue);
    });

    final productTotals = <String, _ProductAgg>{};
    for (final order in orders) {
      for (final item in order.items) {
        final agg = productTotals.putIfAbsent(
          item.productId,
          () => _ProductAgg(item.productId),
        );
        agg.quantity += item.quantity;
        agg.revenue += item.unitPrice * item.quantity;
      }
    }
    final topProducts = productTotals.values.toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));
    final top5 = topProducts.take(5).map((a) => TopProduct(
          a.productId,
          a.productId,
          a.quantity,
          a.revenue,
        )).toList();

    return AnalyticsSummary(
      totalRevenue: totalRevenue,
      totalOrders: orders.length,
      pendingOrders: pending,
      revenueByDay: revenueByDay,
      topProducts: top5,
    );
  }
}

class _ProductAgg {
  final String productId;
  int quantity = 0;
  double revenue = 0;
  _ProductAgg(this.productId);
}
