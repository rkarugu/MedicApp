import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cross-platform token storage service that works reliably on web and mobile
class TokenStorageService {
  static const String _tokenKey = 'auth_token';
  
  final FlutterSecureStorage _secureStorage;
  
  TokenStorageService(this._secureStorage);

  /// Save authentication token
  Future<void> saveToken(String token) async {
    try {
      print('TokenStorage: Saving token...'); // Debug log
      if (kIsWeb) {
        // Use SharedPreferences for web (more reliable than secure storage)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        print('TokenStorage: Token saved to SharedPreferences'); // Debug log
      } else {
        // Use secure storage for mobile platforms
        await _secureStorage.write(key: _tokenKey, value: token);
        print('TokenStorage: Token saved to secure storage'); // Debug log
      }
    } catch (e) {
      print('TokenStorage: Error saving token: $e'); // Debug log
      rethrow;
    }
  }

  /// Retrieve authentication token
  Future<String?> getToken() async {
    try {
      String? token;
      if (kIsWeb) {
        // Use SharedPreferences for web
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString(_tokenKey);
      } else {
        // Use secure storage for mobile platforms
        token = await _secureStorage.read(key: _tokenKey);
      }
      print('TokenStorage: Retrieved token: ${token != null ? "${token.substring(0, 10)}..." : "null"}'); // Debug log
      return token;
    } catch (e) {
      print('TokenStorage: Error retrieving token: $e'); // Debug log
      return null;
    }
  }

  /// Delete authentication token (logout)
  Future<void> deleteToken() async {
    if (kIsWeb) {
      // Use SharedPreferences for web
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } else {
      // Use secure storage for mobile platforms
      await _secureStorage.delete(key: _tokenKey);
    }
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
