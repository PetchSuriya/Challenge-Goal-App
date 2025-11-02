import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../core/config/api_config.dart';
// Only available on web builds; guarded at runtime by kIsWeb
import 'package:dio/browser.dart' show BrowserHttpClientAdapter;

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
      final adapter = _dio.httpClientAdapter;
      if (adapter is BrowserHttpClientAdapter) {
        adapter.withCredentials = true;
      }
    } else {
      _cookieJar = PersistCookieJar(ignoreExpires: false);
      _dio.interceptors.add(CookieManager(_cookieJar!));
    }
  }

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  PersistCookieJar? _cookieJar;

  Dio get dio => _dio;
  PersistCookieJar? get cookieJar => _cookieJar;

  Future<void> clearCookies() async {
    if (!kIsWeb && _cookieJar != null) {
      await _cookieJar!.deleteAll();
    }
  }
}
