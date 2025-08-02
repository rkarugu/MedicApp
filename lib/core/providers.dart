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
      // TODO: replace with your backend base URL – keep `/api` suffix for retrofit paths.
      baseUrl: kIsWeb
          ? 'http://localhost/mediconnect/public/api' // For web browsers
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
