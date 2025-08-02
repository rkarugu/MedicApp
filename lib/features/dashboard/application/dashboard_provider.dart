import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_repository.dart';
import '../data/dashboard_models.dart';
import '../data/notification_dashboard_service.dart';

import '../../../core/providers.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final authenticatedDio = ref.watch(authenticatedDioProvider);
  return DashboardRepository(authenticatedDio);
});

final notificationDashboardServiceProvider = Provider<NotificationDashboardService>((ref) {
  final authenticatedDio = ref.watch(authenticatedDioProvider);
  return NotificationDashboardService(authenticatedDio);
});

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  
  // Fetch dashboard data (now includes bid invitations from our working endpoint)
  final dashboardData = await repo.getDashboardData();
  
  return dashboardData;
});
