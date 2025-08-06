import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/browser.dart' show BrowserHttpClientAdapter;
import 'package:universal_html/html.dart' as html;

import 'network/dio_provider.dart';
import '../data/api/mediconnect_api.dart';
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

/// Authenticated [Dio] instance that automatically includes Bearer tokens
final authenticatedDioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  
  final dio = Dio(
    BaseOptions(
      // Laravel development server base URL with /api suffix
      baseUrl: kIsWeb
          ? 'http://localhost:8000/api' // For web browsers (Laravel dev server)
          : Platform.isAndroid
              ? 'http://10.0.2.2:8000/api' // For Android emulators
              : 'http://localhost:8000/api', // For iOS simulators
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      },
      followRedirects: false, // Prevent redirects that might change the method
      validateStatus: (status) => status! < 500, // Don't throw on 4xx errors
    ),
  );
  
  // Add request/response logging interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      print('[Dio] Request:');
      print('[Dio] ${options.method.toUpperCase()} ${options.uri}');
      print('[Dio] Headers: ${options.headers}');
      if (options.data != null) {
        print('[Dio] Body: ${options.data}');
      }
      return handler.next(options);
    },
    onResponse: (response, handler) {
      print('[Dio] Response:');
      print('[Dio] Status: ${response.statusCode}');
      print('[Dio] Headers: ${response.headers}');
      print('[Dio] Data: ${response.data}');
      return handler.next(response);
    },
    onError: (DioException e, handler) {
      print('[Dio] Error:');
      print('[Dio] ${e.requestOptions.method.toUpperCase()} ${e.requestOptions.uri}');
      print('[Dio] Status: ${e.response?.statusCode}');
      print('[Dio] Error: ${e.message}');
      print('[Dio] Response: ${e.response?.data}');
      return handler.next(e);
    },
  ));

  // On web, ensure cookies (session & XSRF) are included with every request
  if (kIsWeb) {
    (dio.httpClientAdapter as BrowserHttpClientAdapter).withCredentials = true;

    // Attach XSRF token from cookie for Sanctum-protected POST/PUT/DELETE requests
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

    // initial set
    setXsrfHeader();

    // refresh header before every request
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      setXsrfHeader();
      return handler.next(options);
    }));
  }

  // Add authentication interceptor to automatically attach Bearer token
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      try {
        final token = await tokenStorage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          print('AuthInterceptor: Added Bearer token to request: ${token.substring(0, 10)}...'); // Debug log
        } else {
          print('AuthInterceptor: No token found, request will be unauthorized'); // Debug log
        }
      } catch (e) {
        print('AuthInterceptor: Error getting token: $e'); // Debug log
      }
      return handler.next(options);
    },
    onError: (error, handler) {
      if (error.response?.statusCode == 401) {
        print('AuthInterceptor: 401 Unauthorized - token may be invalid or expired'); // Debug log
        print('AuthInterceptor: Request URL: ${error.requestOptions.uri}'); // Debug log
        print('AuthInterceptor: Request Headers: ${error.requestOptions.headers}'); // Debug log
      }
      return handler.next(error);
    },
  ));

  return dio;
});

/// Provides a generated Retrofit API client (unauthenticated).
final mediconnectApiProvider = Provider<MediconnectApi>((ref) {
  final dio = ref.watch(dioProvider);
  return MediconnectApi(dio);
});

/// Provides a generated Retrofit API client (authenticated).
final authenticatedApiProvider = Provider<MediconnectApi>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return MediconnectApi(dio);
});
