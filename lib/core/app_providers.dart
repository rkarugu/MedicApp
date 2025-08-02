import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/browser.dart' show BrowserHttpClientAdapter;
import 'package:universal_html/html.dart' as html;

import '../features/auth/data/auth_api_service.dart';
import '../features/auth/providers/auth_notifier.dart';
import '../features/dashboard/data/dashboard_repository.dart';
import 'services/token_storage_service.dart';

/// Core providers for the entire app

// Storage providers
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenStorageProvider = Provider<TokenStorageService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return TokenStorageService(secureStorage);
});

// Network providers
final baseDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: kIsWeb
          ? 'http://localhost/mediconnect/public/api'
          : Platform.isAndroid
              ? 'http://localhost/mediconnect/public/api' // For Android emulators
              : 'http://localhost/mediconnect/public/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      },
    ),
  );

  // Add comprehensive logging
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      print('📡 REQUEST: ${options.method} ${options.uri}');
      print('📋 HEADERS: ${options.headers}');
      if (options.data != null) {
        print('📦 DATA: ${options.data}');
      }
      return handler.next(options);
    },
    onResponse: (response, handler) {
      print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
      return handler.next(response);
    },
    onError: (error, handler) {
      print('❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}');
      print('❌ MESSAGE: ${error.message}');
      if (error.response?.data != null) {
        print('❌ DATA: ${error.response?.data}');
      }
      return handler.next(error);
    },
  ));

  return dio;
});

// Authenticated Dio with token injection
final authenticatedDioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final baseDio = ref.watch(baseDioProvider);

  final dio = Dio(baseDio.options);

  // Add authentication interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      try {
        final token = await tokenStorage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          print('🔐 TOKEN ADDED: ${token.substring(0, 10)}...');
        } else {
          print('⚠️ NO TOKEN FOUND');
        }
      } catch (e) {
        print('❌ TOKEN ERROR: $e');
      }
      return handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        print('🚪 401 UNAUTHORIZED - Clearing token');
        await tokenStorage.deleteToken();
        
        // Optionally navigate to login
        // final context = ref.read(navigationProvider);
        // if (context != null) {
        //   context.go('/login');
        // }
      }
      return handler.next(error);
    },
  ));

  // Web-specific configuration
  if (kIsWeb) {
    (dio.httpClientAdapter as BrowserHttpClientAdapter).withCredentials = true;

    void setXsrfHeader() {
      final cookies = html.document.cookie?.split('; ') ?? [];
      final xsrf = cookies.firstWhere(
        (c) => c.startsWith('XSRF-TOKEN='),
        orElse: () => '',
      );
      if (xsrf.isNotEmpty) {
        final token = Uri.decodeComponent(xsrf.substring('XSRF-TOKEN='.length));
        dio.options.headers['X-XSRF-TOKEN'] = token;
      }
    }

    setXsrfHeader();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      setXsrfHeader();
      return handler.next(options);
    }));
  }

  return dio;
});

// Service providers
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthApiService(dio, tokenStorage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authApiService = ref.watch(authApiServiceProvider);
  return AuthRepository(authApiService);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return DashboardRepository(dio);
});

// Auth state providers
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authApiService = ref.watch(authApiServiceProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthNotifier(authApiService, tokenStorage);
});

// Convenience providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authNotifierProvider).user;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authNotifierProvider).error;
});

// Dashboard providers
final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return await repo.fetchDashboard();
});
