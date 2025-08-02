import '../../../core/services/token_storage_service.dart';
import 'auth_api_service.dart';

class AuthRepository {
  final AuthApiService _apiService;
  final TokenStorageService _tokenStorage;

  AuthRepository(this._apiService, this._tokenStorage);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.login(email: email, password: password);
      final token = response['data']['token'];
      await _tokenStorage.saveToken(token);
      return response;
    } catch (e) {
      rethrow;
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
      return await _apiService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      return await _apiService.getUserProfile();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // The API service already handles clearing the token on failure,
      // so we can just rethrow to let the UI know if something went wrong.
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      return await _apiService.updateProfile(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getToken() async {
    return await _tokenStorage.getToken();
  }
}
