import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../common/mediconnect_app_bar.dart';
import '../providers/history_providers.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  static const String routeName = 'history';

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  @override
  void initState() {
    super.initState();
    // Load completed shifts when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyNotifierProvider.notifier).loadCompletedShifts();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final historyNotifier = ref.read(historyNotifierProvider.notifier);
    final state = ref.read(historyNotifierProvider);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: state.startDate != null && state.endDate != null
          ? DateTimeRange(start: state.startDate!, end: state.endDate!)
          : null,
    );

    if (picked != null) {
      historyNotifier.setDateRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyNotifierProvider);

    return Scaffold(
      appBar: const MediconnectAppBar(),
      body: Column(
        children: [
          // Date Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    state.startDate != null && state.endDate != null
                        ? '${DateFormat('MMM d, y').format(state.startDate!)} - ${DateFormat('MMM d, y').format(state.endDate!)}'
                        : 'All Dates',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDateRange(context),
                ),
                if (state.startDate != null || state.endDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => ref.read(historyNotifierProvider.notifier).clearFilters(),
                  ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: ${state.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref.read(historyNotifierProvider.notifier).loadCompletedShifts(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : state.shifts.isEmpty
                        ? const Center(
                            child: Text('No completed shifts found'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.shifts.length,
                            itemBuilder: (context, index) {
                              final shift = state.shifts[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              shift.facilityName,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'Completed',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        shift.position,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat('MMM d, y').format(DateTime.parse(shift.date)),
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                          const SizedBox(width: 16),
                                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${shift.startTime} - ${shift.endTime}',
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${shift.hours} hours',
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                          Text(
                                            '\$${shift.total.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rate: \$${shift.rate.toStringAsFixed(2)}/hour',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
