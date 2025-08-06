import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/shift_application_models.dart';
import '../../data/shift_application_service.dart';
import '../../../../core/providers.dart';

class ShiftApplicationCard extends ConsumerWidget {
  final ShiftApplication application;
  final VoidCallback? onStatusChanged;

  const ShiftApplicationCard({
    Key? key,
    required this.application,
    this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    application.shiftTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: application.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: application.statusColor),
                  ),
                  child: Text(
                    application.statusDisplayText,
                    style: TextStyle(
                      color: application.statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Facility and time info
            Row(
              children: [
                const Icon(Icons.local_hospital, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  application.facilityName,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  application.shiftTime,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'KES ${application.payRate}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            // Applied date
            const SizedBox(height: 8),
            Text(
              'Applied: ${_formatDate(application.appliedAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            
            // Action buttons based on status
            const SizedBox(height: 16),
            _buildActionButtons(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    if (application.isPending) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.hourglass_empty, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text(
              'Waiting for admin approval...',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
    
    if (application.isRejected) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text(
              'Application was rejected',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
    
    if (application.isApproved || application.isInProgress) {
      if (application.canStartShift) {
        return ElevatedButton.icon(
          onPressed: () => _handleStartShift(context, ref),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Shift'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        );
      } else if (application.canCompleteShift) {
        return ElevatedButton.icon(
          onPressed: () => _handleCompleteShift(context, ref),
          icon: const Icon(Icons.check_circle),
          label: const Text('Complete Shift'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        );
      } else {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                application.shiftStartTime != null 
                    ? 'Shift starts at ${_formatTime(application.shiftStartTime!)}'
                    : 'Approved - Waiting for shift time',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }
    }
    
    return const SizedBox.shrink();
  }

  void _handleStartShift(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Shift'),
        content: Text('Are you ready to start your shift at ${application.facilityName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Start Shift'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed || !context.mounted) return;

    try {
      final dio = ref.read(authenticatedDioProvider);
      final service = ShiftApplicationService(dio);
      
      final result = await service.startShift(application.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['success'] == true 
                  ? 'Shift started successfully!'
                  : 'Failed to start shift: ${result['error'] ?? 'Unknown error'}',
            ),
            backgroundColor: result['success'] == true ? Colors.green : Colors.red,
          ),
        );
        
        if (result['success'] == true) {
          onStatusChanged?.call();
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while starting the shift'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleCompleteShift(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Shift'),
        content: Text('Are you ready to complete your shift at ${application.facilityName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Complete Shift'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed || !context.mounted) return;

    try {
      final dio = ref.read(authenticatedDioProvider);
      final service = ShiftApplicationService(dio);
      
      final result = await service.completeShift(application.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['success'] == true 
                  ? 'Shift completed successfully!'
                  : 'Failed to complete shift: ${result['error'] ?? 'Unknown error'}',
            ),
            backgroundColor: result['success'] == true ? Colors.green : Colors.red,
          ),
        );
        
        if (result['success'] == true) {
          onStatusChanged?.call();
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while completing the shift'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${_formatTime(date)}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
