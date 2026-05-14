import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banabana_b2b/features/producer/data/analytics_repository.dart';
import 'package:banabana_b2b/features/producer/data/order_repository.dart';
import 'package:banabana_b2b/core/api/api_client.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final orderRepo = OrderRepository(ref.watch(apiClientProvider));
  return AnalyticsRepository(orderRepo);
});

final analyticsSummaryProvider = FutureProvider<AnalyticsSummary>((ref) {
  return ref.watch(analyticsRepositoryProvider).getSummary();
});
