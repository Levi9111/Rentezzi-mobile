import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final List<dynamic>? errorSources;

  ApiException({
    required this.message,
    this.statusCode = 400,
    this.errorSources,
  });

  @override
  String toString() => message;
}

class ApiService {
  static final http.Client _client = http.Client();
  static bool _isRefreshing = false;

  static String get baseUrl {
    final custom = StorageService.getCustomBaseUrl();
    if (custom != null && custom.isNotEmpty) return custom;
    return ApiEndpoints.baseUrl;
  }

  static Map<String, String> _getHeaders({bool isAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (isAuth) {
      final token = StorageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// Generic GET
  static Future<dynamic> get(String path, {bool requireAuth = true}) async {
    return _sendWithRetry(() async {
      final url = Uri.parse('$baseUrl$path');
      final res = await _client.get(url, headers: _getHeaders(isAuth: requireAuth));
      return _processResponse(res);
    });
  }

  /// Generic POST
  static Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    return _sendWithRetry(() async {
      final url = Uri.parse('$baseUrl$path');
      final res = await _client.post(
        url,
        headers: _getHeaders(isAuth: requireAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(res);
    });
  }

  /// Generic PATCH
  static Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    return _sendWithRetry(() async {
      final url = Uri.parse('$baseUrl$path');
      final res = await _client.patch(
        url,
        headers: _getHeaders(isAuth: requireAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(res);
    });
  }

  /// Generic PUT
  static Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    return _sendWithRetry(() async {
      final url = Uri.parse('$baseUrl$path');
      final res = await _client.put(
        url,
        headers: _getHeaders(isAuth: requireAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(res);
    });
  }

  /// Generic DELETE
  static Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    return _sendWithRetry(() async {
      final url = Uri.parse('$baseUrl$path');
      final res = await _client.delete(
        url,
        headers: _getHeaders(isAuth: requireAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(res);
    });
  }

  /// Retry on 401 by refreshing token
  static Future<dynamic> _sendWithRetry(Future<dynamic> Function() requestFn) async {
    try {
      return await requestFn();
    } on ApiException catch (e) {
      if (e.statusCode == 401 && !_isRefreshing) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          return await requestFn();
        } else {
          await StorageService.clearTokens();
          rethrow;
        }
      }
      rethrow;
    } on SocketException {
      throw ApiException(
        message: 'Unable to connect to server. Please check your internet connection.',
        statusCode: 0,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  /// Token refresh handler
  static Future<bool> _refreshAccessToken() async {
    final refreshToken = StorageService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    _isRefreshing = true;
    try {
      final url = Uri.parse('$baseUrl${ApiEndpoints.refreshToken}');
      final res = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final newAccess = decoded['data']['accessToken'] ?? decoded['data']['token'];
          final newRefresh = decoded['data']['refreshToken'] ?? refreshToken;
          if (newAccess != null) {
            await StorageService.saveTokens(
              accessToken: newAccess,
              refreshToken: newRefresh,
            );
            return true;
          }
        }
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Process standard response envelope
  static dynamic _processResponse(http.Response res) {
    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return res.body;
      }
      throw ApiException(
        message: 'Server returned ${res.statusCode}: ${res.reasonPhrase}',
        statusCode: res.statusCode,
      );
    }

    if (decoded is Map<String, dynamic>) {
      final bool success = decoded['success'] ?? (res.statusCode >= 200 && res.statusCode < 300);
      if (!success) {
        final msg = decoded['message'] ?? 'An error occurred';
        final errorSources = decoded['errorSources'] as List<dynamic>?;
        throw ApiException(
          message: msg,
          statusCode: decoded['statusCode'] ?? res.statusCode,
          errorSources: errorSources,
        );
      }
      return decoded['data'] ?? decoded;
    }

    return decoded;
  }
}
