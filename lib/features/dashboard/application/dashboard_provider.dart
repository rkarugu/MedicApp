import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_repository.dart';
import '../data/dashboard_models.dart';
import '../data/notification_dashboard_service.dart';
import 'dart:async';

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

// Manual refresh function that can be called to immediately refresh dashboard
final dashboardRefreshProvider = Provider<VoidCallback>((ref) {
  return () {
    print('DashboardRefresh: Manually refreshing dashboard data...');
    ref.invalidate(dashboardProvider);
  };
});

// Auto-refresh provider that periodically invalidates the dashboard
final dashboardAutoRefreshProvider = Provider<Timer?>((ref) {
  Timer? timer;
  
  // Start periodic refresh every 30 seconds
  timer = Timer.periodic(const Duration(seconds: 30), (timer) {
    print('DashboardAutoRefresh: Refreshing dashboard data...');
    ref.invalidate(dashboardProvider);
  });
  
  // Clean up timer when provider is disposed
  ref.onDispose(() {
    print('DashboardAutoRefresh: Disposing timer');
    timer?.cancel();
  });
  
  return timer;
});
