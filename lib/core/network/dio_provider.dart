import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/browser.dart' show BrowserHttpClientAdapter;
import 'package:universal_html/html.dart' as html;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Global [Dio] instance configured for the API.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      // Backend base URL – includes /api prefix
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
    ),
  );

  // On web, ensure cookies (session & XSRF) are included with every request
  if (kIsWeb) {
    (dio.httpClientAdapter as BrowserHttpClientAdapter).withCredentials = true;
  }

  // Add authentication token interceptor for all platforms
  dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
    if (kIsWeb) {
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
    
    // Add authentication token for API requests
    try {
      const secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: 'auth_token');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Token read error - continue without auth header
    }
    
    return handler.next(options);
  }));
  
  return dio;
});
