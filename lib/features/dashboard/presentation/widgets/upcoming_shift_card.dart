import 'package:flutter/material.dart';
import '../../data/dashboard_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../shift_details_page.dart';


class UpcomingShiftCard extends StatelessWidget {
  final Shift shift;
  final VoidCallback onRefresh;

  const UpcomingShiftCard({
    super.key,
    required this.shift,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ShiftDetailsPage(shift: shift, onRefresh: onRefresh),
              ),
            );
          },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shift.facility,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${shift.startTime} - ${shift.endTime}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  _ShiftStatusBadge(status: shift.applicationStatus ?? shift.status),
                ],
              ),
              const SizedBox(height: 16),
              _ShiftActionButtons(
                shift: shift,
                onRefresh: onRefresh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShiftStatusBadge extends StatelessWidget {
  final String status;

  const _ShiftStatusBadge({required this.status});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'waiting':
        return Colors.grey;
      case 'approved':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ShiftActionButtons extends ConsumerWidget {
  final Shift shift;
  final VoidCallback onRefresh;

  const _ShiftActionButtons({
    required this.shift,
    required this.onRefresh,
  });

  Future<void> _acceptShift(BuildContext context, WidgetRef ref, int shiftId) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/worker/locum-shifts/$shiftId/apply',
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ShiftDetailsPage(shift: shift, onRefresh: onRefresh)),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shift accepted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting shift: $e')),
      );
    }
  }

  Future<void> _startShift(BuildContext context, WidgetRef ref, int shiftId) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/worker/locum-shifts/$shiftId/start',
      );
      onRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shift started successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting shift: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        if (shift.applicationStatus == null && shift.status == 'open')
          Expanded(
            child: ElevatedButton(
              onPressed: () => _acceptShift(context, ref, shift.id),
              child: const Text('Accept Shift'),
            ),
          )
        else if (shift.applicationStatus == 'approved' && 
            DateTime.parse(shift.startTime).isBefore(DateTime.now()))
          Expanded(
            child: ElevatedButton(
              onPressed: () => _startShift(context, ref, shift.id),
              child: const Text('Start Shift'),
            ),
          ),
      ],
    );
  }
}
