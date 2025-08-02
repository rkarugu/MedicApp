import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/mediconnect_app_bar.dart';
import '../application/dashboard_provider.dart';
import 'widgets/dashboard_cards.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  static const String routeName = 'dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: const MediconnectAppBar(),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hello, Medical Worker!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DashboardCards(data: data),
            ],
          ),
        ),
      ),
      
    );
  }
}
