import 'package:dio/dio.dart';
import 'history_model.dart';

class HistoryApiService {
  final Dio _dio;

  HistoryApiService(this._dio);

  Future<List<CompletedShift>> getCompletedShifts({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = <String, dynamic>{};
      
      if (startDate != null) {
        params['start_date'] = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      }
      
      if (endDate != null) {
        params['end_date'] = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      }

      final response = await _dio.get(
        '/worker/completed-shifts',
        queryParameters: params,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        if (data.isEmpty) return [];
        
        final shifts = data.map<CompletedShift>((shift) {
          return CompletedShift(
            id: shift['id']?.toString() ?? '',
            facilityName: shift['facilityName'] ?? shift['facility_name'] ?? 'Unknown',
            position: shift['position'] ?? 'Unknown',
            date: shift['date'] ?? '',
            startTime: shift['startTime'] ?? shift['start_time'] ?? '',
            endTime: shift['endTime'] ?? shift['end_time'] ?? '',
            hours: (shift['hours'] ?? 0.0).toDouble(),
            rate: (shift['rate'] ?? 0.0).toDouble(),
            total: (shift['total'] ?? 0.0).toDouble(),
            status: shift['status'] ?? 'Completed',
          );
        }).toList();
        
        // Sort by date descending
        shifts.sort((a, b) {
          final dateA = DateTime.parse(a.date);
          final dateB = DateTime.parse(b.date);
          return dateB.compareTo(dateA);
        });
        return shifts;
      }
      
      throw Exception('Failed to load completed shifts');
    } catch (e) {
      throw Exception('Error fetching completed shifts: $e');
    }
  }
}
