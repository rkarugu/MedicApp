import 'package:dio/dio.dart';
import 'shift_application_models.dart';

class ShiftApplicationService {
  final Dio _dio;

  ShiftApplicationService(this._dio);

  /// Get all shift applications for the authenticated worker
  Future<List<ShiftApplication>> getShiftApplications() async {
    try {
      final response = await _dio.get('/worker/shift-applications');
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => ShiftApplication.fromJson(item)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error fetching shift applications: $e');
      return [];
    }
  }

  /// Start a shift (mark as in progress)
  Future<Map<String, dynamic>> startShift(int applicationId) async {
    try {
      print('Starting shift for application ID: $applicationId');
      
      final response = await _dio.post(
        '/worker/shift-applications/$applicationId/start',
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      );
      
      print('Start shift response:');
      print('  Status: ${response.statusCode}');
      print('  Data: ${response.data}');
      
      return {
        'success': true,
        'message': response.data['message'] ?? 'Shift started successfully',
        'data': response.data,
      };
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['error'] ?? 
                          e.response?.data?['message'] ?? 
                          'Failed to start shift';
      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred',
      };
    }
  }

  /// Complete a shift (mark as completed)
  Future<Map<String, dynamic>> completeShift(int applicationId) async {
    try {
      print('Completing shift for application ID: $applicationId');
      
      final response = await _dio.post(
        '/worker/shift-applications/$applicationId/complete',
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      );
      
      print('Complete shift response:');
      print('  Status: ${response.statusCode}');
      print('  Data: ${response.data}');
      
      return {
        'success': true,
        'message': response.data['message'] ?? 'Shift completed successfully',
        'data': response.data,
      };
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['error'] ?? 
                          e.response?.data?['message'] ?? 
                          'Failed to complete shift';
      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred',
      };
    }
  }
}
