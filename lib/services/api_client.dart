import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../core/config/api_config.dart';

/// A singleton API client configured with Dio, cookie storage, and timeouts.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: ApiConfig.defaultHeaders,
        // We'll manually control validation
        validateStatus: (status) => status != null && status >= 200 && status < 500,
      ),
    );
    if (kIsWeb) {
      // On web, let the browser manage cookies. Enable credentials for XHR/fetch.
      // Avoid importing web-only types on non-web platforms; use dynamic.
      try {
        final adapter = _dio.httpClientAdapter;
        // BrowserHttpClientAdapter has `withCredentials`; set it when available.
        (adapter as dynamic).withCredentials = true;
      } catch (_) {
        // Ignore if adapter doesn't support withCredentials (non-web or different adapter)
      }
    } else {
      // Use in-memory cookie jar on mobile/desktop to avoid filesystem issues on some devices/emulators.
      _cookieJar = CookieJar();
      _dio.interceptors.add(CookieManager(_cookieJar!));
    }
  }

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  CookieJar? _cookieJar;

  Dio get dio => _dio;
  CookieJar? get cookieJar => _cookieJar;

  Future<void> clearCookies() async {
    if (!kIsWeb && _cookieJar != null) {
      try {
        await (_cookieJar as dynamic).deleteAll();
      } catch (_) {
        // If not supported, replace with a new instance
        _cookieJar = CookieJar();
        // Recreate interceptor
        _dio.interceptors.removeWhere((it) => it is CookieManager);
        _dio.interceptors.add(CookieManager(_cookieJar!));
      }
    }
  }
}
