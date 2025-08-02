import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mediconnect/core/network/dio_provider.dart';
import 'package:mediconnect/core/services/token_storage_service.dart';
import 'package:mediconnect/features/auth/data/auth_api_service.dart';
import 'package:mediconnect/features/auth/data/auth_repository.dart';
import 'package:mediconnect/features/auth/providers/auth_notifier.dart';

// Centralized Authentication Providers

// 1. Token Storage Service (Lowest Level)
final tokenStorageProvider = Provider<TokenStorageService>((ref) {
  const secureStorage = FlutterSecureStorage();
  return TokenStorageService(secureStorage);
});

// 2. API Service (Depends on Dio and Token Storage)
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final dio = ref.watch(dioProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthApiService(dio, tokenStorage);
});

// 3. Repository (Depends on API Service and Token Storage)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(authApiServiceProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthRepository(apiService, tokenStorage);
});

// 4. State Notifier (Depends on Repository)
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
