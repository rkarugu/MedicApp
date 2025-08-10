import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/history_model.dart';
import '../../dashboard/application/dashboard_provider.dart';

// State class for history with date filtering
class HistoryState {
  final List<CompletedShift> shifts;
  final bool isLoading;
  final String? error;
  final DateTime? startDate;
  final DateTime? endDate;

  const HistoryState({
    this.shifts = const [],
    this.isLoading = false,
    this.error,
    this.startDate,
    this.endDate,
  });

  HistoryState copyWith({
    List<CompletedShift>? shifts,
    bool? isLoading,
    String? error,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return HistoryState(
      shifts: shifts ?? this.shifts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

// State notifier for managing completed shifts from dashboard data
class HistoryNotifier extends StateNotifier<HistoryState> {
  final Ref _ref;

  HistoryNotifier(this._ref) : super(const HistoryState());

  Future<void> loadCompletedShifts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Get dashboard data which includes shift applications
      final dashboardData = await _ref.read(dashboardProvider.future);
      
      // Filter completed shift applications
      final completedApplications = dashboardData.shiftApplications
          .where((app) => app.status.toLowerCase() == 'completed')
          .toList();
      
      // Convert to CompletedShift objects
      List<CompletedShift> completedShifts = completedApplications.map((app) {
        return CompletedShift(
          id: app.id.toString(),
          facilityName: app.facilityName ?? 'Unknown Facility',
          position: app.shiftTitle ?? 'Unknown Position',
          date: _formatDateFromDateTime(app.shiftStartTime), // Extract and format date part
          startTime: _formatTimeFromDateTime(app.shiftStartTime),
          endTime: _formatTimeFromDateTime(app.shiftEndTime),
          hours: _calculateHoursFromDateTime(app.shiftStartTime, app.shiftEndTime),
          rate: app.payRate?.toDouble() ?? 0.0,
          total: _calculateHoursFromDateTime(app.shiftStartTime, app.shiftEndTime) * (app.payRate?.toDouble() ?? 0.0),
          status: app.status ?? 'Completed',
        );
      }).toList();
      
      // Apply date filtering if provided
      if (state.startDate != null || state.endDate != null) {
        completedShifts = completedShifts.where((shift) {
          final shiftDate = DateTime.parse(shift.date);
          if (state.startDate != null && shiftDate.isBefore(state.startDate!)) return false;
          if (state.endDate != null && shiftDate.isAfter(state.endDate!)) return false;
          return true;
        }).toList();
      }
      
      // Sort by date descending (newest first)
      completedShifts.sort((a, b) {
        final dateA = DateTime.parse(a.date);
        final dateB = DateTime.parse(b.date);
        return dateB.compareTo(dateA);
      });
      
      state = state.copyWith(
        shifts: completedShifts,
        isLoading: false,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
    }
  }
  
  void setDateRange(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
    );
    loadCompletedShifts();
  }
  
  void clearFilters() {
    state = state.copyWith(
      startDate: null,
      endDate: null,
    );
    loadCompletedShifts();
  }
  
  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00';
    }
  }
  
  String _formatDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return DateTime.now().toString().split('T')[0];
    }
  }
  
  double _calculateHours(String startTime, String endTime) {
    try {
      final start = DateTime.parse(startTime);
      final end = DateTime.parse(endTime);
      return end.difference(start).inMinutes / 60.0;
    } catch (e) {
      return 1.0; // Default to 1 hour if calculation fails
    }
  }
  
  // New helper functions for DateTime objects
  String _formatDateFromDateTime(DateTime? dateTime) {
    if (dateTime == null) return DateTime.now().toString().split('T')[0];
    // Convert to local time if it's in UTC
    final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    return '${localDateTime.year}-${localDateTime.month.toString().padLeft(2, '0')}-${localDateTime.day.toString().padLeft(2, '0')}';
  }
  
  String _formatTimeFromDateTime(DateTime? dateTime) {
    if (dateTime == null) return '00:00';
    // Convert to local time if it's in UTC
    final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    return '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
  }
  
  double _calculateHoursFromDateTime(DateTime? startTime, DateTime? endTime) {
    if (startTime == null || endTime == null) return 1.0;
    return endTime.difference(startTime).inMinutes / 60.0;
  }
}

// Provider for the History notifier
final historyNotifierProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(ref);
});
