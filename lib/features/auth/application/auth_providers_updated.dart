import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/providers.dart';
import '../data/auth_repository.dart';
import '../data/auth_api_service.dart';
import '../../../data/models/login_response.dart';

// Create new auth API service that works with existing structure
class UpdatedAuthApiService {
  final Dio _dio;
  
  UpdatedAuthApiService(this._dio);

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
      return response.data;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

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
      return response.data;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get('/api/worker/me');
      return response.data;
    } catch (e) {
      throw Exception('Profile fetch failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/worker/logout');
    } catch (e) {
      // Log error but continue
      print('Logout error: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/api/worker/profile', data: data);
      return response.data;
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }
}

// Updated auth repository that integrates with existing structure
class UpdatedAuthRepository {
  final UpdatedAuthApiService _apiService;
  
  UpdatedAuthRepository(this._apiService);

  Future<LoginData> login(String email, String password) async {
    final response = await _apiService.login(
      email: email,
      password: password,
    );
    
    // Convert response to LoginData format
    return LoginData(
      token: response['data']['token'],
      user: UserData.fromJson(response['data']),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
  }) async {
    await _apiService.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      phone: phone,
    );
  }

  Future<UserData> getUserProfile() async {
    final response = await _apiService.getUserProfile();
    return UserData.fromJson(response['data']);
  }

  Future<void> logout() async {
    await _apiService.logout();
  }

  Future<UserData> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiService.updateProfile(data);
    return UserData.fromJson(response['data']);
  }
}

// Updated providers that work with existing structure
final updatedAuthApiServiceProvider = Provider<UpdatedAuthApiService>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return UpdatedAuthApiService(dio);
});

final updatedAuthRepositoryProvider = Provider<UpdatedAuthRepository>((ref) {
  final apiService = ref.watch(updatedAuthApiServiceProvider);
  return UpdatedAuthRepository(apiService);
});

// Provider for authentication state
final authStateProvider = StateProvider<bool>((ref) => false);

// Provider for current user
final currentUserProvider = StateProvider<UserData?>((ref) => null);

// Provider for auth loading state
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Provider for auth error
final authErrorProvider = StateProvider<String?>((ref) => null);
