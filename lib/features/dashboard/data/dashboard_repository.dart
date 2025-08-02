import 'package:dio/dio.dart';
import 'dashboard_models.dart';

class DashboardRepository {
  final Dio _dio;
  
  DashboardRepository(this._dio);

  Future<DashboardData> getDashboardData() async {
    try {
      print('DashboardRepository: Making request to /worker/dashboard-success');
      print('DashboardRepository: Headers: ${_dio.options.headers}');
      
      final response = await _dio.get('/worker/dashboard-success');
      print('DashboardRepository: Raw response: ${response.data}');
      
      // Extract the 'data' field from the backend response
      final dashboardJson = response.data['data'] ?? response.data;
      print('DashboardRepository: Dashboard JSON: $dashboardJson');
      
      return DashboardData.fromJson(dashboardJson);
    } catch (e) {
      print('DashboardRepository: Error fetching dashboard: $e');
      rethrow;
    }
  }
}
