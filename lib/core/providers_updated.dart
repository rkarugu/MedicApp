import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/browser.dart' show BrowserHttpClientAdapter;
import 'package:universal_html/html.dart' as html;

import '../features/auth/data/auth_api_service.dart';
import '../features/auth/providers/auth_notifier.dart';
import '../features/dashboard/data/dashboard_repository.dart';
import '../features/dashboard/application/dashboard_provider.dart';
import 'services/token_storage_service.dart';

/// Provides access to [FlutterSecureStorage].
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Provides cross-platform token storage service.
final tokenStorageProvider = Provider<TokenStorageService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return TokenStorageService(secureStorage);
});

/// Base Dio instance without authentication
final baseDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: kIsWeb
          ? 'http://localhost/mediconnect/public/api'
          : Platform.isAndroid
              ? 'http://localhost/mediconnect/public/api'
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
      print('Dio Request: ${options.method} ${options.uri}');
      print('Dio Headers: ${options.headers}');
      return handler.next(options);
    },
    onResponse: (response, handler) {
      print('Dio Response: ${response.statusCode} ${response.requestOptions.uri}');
      return handler.next(response);
    },
    onError: (error, handler) {
      print('Dio Error: ${error.response?.statusCode} ${error.requestOptions.uri}');
      print('Dio Error Message: ${error.message}');
      return handler.next(error);
    },
  ));

  return dio;
});

/// Authenticated Dio instance with Bearer token
final authenticatedDioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final baseDio = ref.watch(baseDioProvider);

  // Clone the base dio to avoid conflicts
  final dio = Dio(baseDio.options);

  // Add authentication interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      try {
        final token = await tokenStorage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          print('AuthInterceptor: Added Bearer token');
        } else {
          print('AuthInterceptor: No token found');
        }
      } catch (e) {
        print('AuthInterceptor: Error getting token: $e');
      }
      return handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        print('AuthInterceptor: 401 Unauthorized - clearing token');
        await tokenStorage.deleteToken();
        // Optionally navigate to login
      }
      return handler.next(error);
    },
  ));

  // Web-specific configuration
  if (kIsWeb) {
    (dio.httpClientAdapter as BrowserHttpClientAdapter).withCredentials = true;

    // Handle XSRF token for Sanctum
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

/// Re-export all providers for easy access
export '../features/auth/providers/auth_notifier.dart';
export '../features/dashboard/data/dashboard_repository.dart';
export '../features/dashboard/application/dashboard_provider.dart';
