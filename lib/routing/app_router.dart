import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/payments/presentation/payments_page.dart';
import '../features/common/main_shell.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/availability/presentation/availability_page.dart';
import '../features/history/presentation/history_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: LoginPage.routeName,
      builder: (context, state) => const LoginPage(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          name: DashboardPage.routeName,
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/profile',
          name: ProfilePage.routeName,
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/availability',
          name: AvailabilityPage.routeName,
          builder: (context, state) => const AvailabilityPage(),
        ),
        GoRoute(
          path: '/payments',
          name: PaymentsPage.routeName,
          builder: (context, state) => const PaymentsPage(),
        ),
        GoRoute(
          path: '/history',
          name: HistoryPage.routeName,
          builder: (context, state) => const HistoryPage(),
        ),
      ],
    ),
  ],
);
