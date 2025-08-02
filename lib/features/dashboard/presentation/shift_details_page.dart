import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';

import '../data/dashboard_models.dart';
import 'package:intl/intl.dart';

class ShiftDetailsPage extends ConsumerWidget {
  final Shift shift;
  final VoidCallback onRefresh;

  const ShiftDetailsPage({super.key, required this.shift, required this.onRefresh});

  Future<void> _acceptShift(BuildContext context, WidgetRef ref) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/worker/locum-shifts/${shift.id}/apply');
      onRefresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shift accepted')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _startShift(BuildContext context, WidgetRef ref) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/worker/locum-shifts/${shift.id}/start');
      onRefresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shift started')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final start = DateTime.parse(shift.startTime);
    final end = DateTime.parse(shift.endTime);
    final df = DateFormat('EEE, d MMM • h:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text('Shift Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shift.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            _detailRow('Facility', shift.facility),
            if (shift.location.isNotEmpty) _detailRow('Address', shift.location),
            _detailRow('Time', '${df.format(start)} → ${DateFormat('h:mm a').format(end)}'),
            _detailRow('Duration', '${shift.durationHrs.toStringAsFixed(1)} hrs'),
            _detailRow('Hourly Rate', '\$${shift.payRate.toStringAsFixed(2)}'),
            _detailRow('Expected Pay', '\$${shift.expectedPay.toStringAsFixed(2)}'),
            _detailRow('Status', (shift.applicationStatus ?? shift.status).toUpperCase()),
            const SizedBox(height: 24),
            if (shift.applicationStatus == null && shift.status == 'open')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _acceptShift(context, ref),
                  child: const Text('Apply for Shift'),
                ),
              )
            else if (shift.applicationStatus == 'waiting')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300),
                  child: const Text('Waiting for Approval', style: TextStyle(color: Colors.black54)),
                ),
              )
            else if ((shift.applicationStatus == 'approved' || shift.applicationStatus == 'confirmed') && DateTime.parse(shift.startTime).isBefore(DateTime.now()))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _startShift(context, ref),
                  child: const Text('Start Shift'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text('$label:')),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

