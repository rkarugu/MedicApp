import 'package:flutter/material.dart';

class ShiftApplication {
  final int id;
  final int shiftId;
  final String status; // 'pending', 'waiting', 'approved', 'rejected'
  final String facilityName;
  final String shiftTitle;
  final String shiftTime;
  final int payRate;
  final DateTime appliedAt;
  final DateTime? selectedAt;
  final DateTime? shiftStartTime;
  final DateTime? shiftEndTime;

  ShiftApplication({
    required this.id,
    required this.shiftId,
    required this.status,
    required this.facilityName,
    required this.shiftTitle,
    required this.shiftTime,
    required this.payRate,
    required this.appliedAt,
    this.selectedAt,
    this.shiftStartTime,
    this.shiftEndTime,
  });

  factory ShiftApplication.fromJson(Map<String, dynamic> json) {
    return ShiftApplication(
      id: json['id'] ?? 0,
      shiftId: json['shift_id'] ?? 0,
      status: json['status'] ?? 'pending',
      facilityName: json['facility_name'] ?? 'Unknown Facility',
      shiftTitle: json['shift_title'] ?? 'Shift',
      shiftTime: json['shift_time'] ?? 'TBD',
      payRate: json['pay_rate'] ?? 0,
      appliedAt: DateTime.tryParse(json['applied_at'] ?? '') ?? DateTime.now(),
      selectedAt: json['selected_at'] != null 
          ? DateTime.tryParse(json['selected_at']) 
          : null,
      shiftStartTime: json['shift_start_time'] != null 
          ? DateTime.tryParse(json['shift_start_time']) 
          : null,
      shiftEndTime: json['shift_end_time'] != null 
          ? DateTime.tryParse(json['shift_end_time']) 
          : null,
    );
  }

  // Helper methods for status checking
  bool get isPending => status == 'pending' || status == 'waiting';
  bool get isApproved => status == 'approved';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isRejected => status == 'rejected';
  
  // Check if shift can be started (approved and within start time window)
  bool get canStartShift {
    if (!isApproved || shiftStartTime == null) return false;
    
    final now = DateTime.now();
    final startTime = shiftStartTime!;
    
    // Allow starting 15 minutes before scheduled time
    final allowedStartTime = startTime.subtract(const Duration(minutes: 15));
    
    return now.isAfter(allowedStartTime) && now.isBefore(startTime.add(const Duration(hours: 1)));
  }
  
  // Check if shift can be completed (in progress and within end time window)
  bool get canCompleteShift {
    if (!isInProgress || shiftEndTime == null) return false;
    
    final now = DateTime.now();
    final endTime = shiftEndTime!;
    
    // Allow completing from 5 minutes before end time
    final allowedCompleteTime = endTime.subtract(const Duration(minutes: 5));
    
    return now.isAfter(allowedCompleteTime);
  }

  String get statusDisplayText {
    switch (status) {
      case 'pending':
      case 'waiting':
        return 'Pending Approval';
      case 'approved':
        return 'Approved';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      default:
        return status.toUpperCase();
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
      case 'waiting':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
