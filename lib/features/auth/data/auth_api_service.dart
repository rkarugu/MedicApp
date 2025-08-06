import 'package:dio/dio.dart';
import '../../../core/services/token_storage_service.dart';

class AuthApiService {
  final Dio _dio;
  final TokenStorageService _tokenStorage;

  AuthApiService(this._dio, this._tokenStorage);

  // Login endpoint
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/medical-worker/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Provide more specific error from backend if available
      final errorMsg = e.response?.data['message'] ?? e.message;
      throw Exception('Login error: $errorMsg');
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Register endpoint
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
  }) async {
    try {
      final response = await _dio.post(
        '/medical-worker/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone': phone,
        },
      );

      if (response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Registration failed');
    } catch (e) {
      throw Exception('Registration error: ${e.toString()}');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await _tokenStorage.getToken();
      if (token == null) throw Exception('No token found');

      final response = await _dio.get(
        '/worker/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return response.data;
    } catch (e) {
      throw Exception('Profile fetch error: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final token = await _tokenStorage.getToken();
      if (token != null) {
        await _dio.post(
          '/worker/logout',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
      }
      await _tokenStorage.deleteToken();
    } catch (e) {
      // Even if logout fails, clear local token
      await _tokenStorage.deleteToken();
    }
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final token = await _tokenStorage.getToken();
      if (token == null) throw Exception('No token found');

      final response = await _dio.put(
        '/worker/profile',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return response.data;
    } catch (e) {
      throw Exception('Profile update error: ${e.toString()}');
    }
  }
}
