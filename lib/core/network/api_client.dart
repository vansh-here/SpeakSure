import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiClient {
  final Dio _dio;
  final SharedPreferences _prefs;

  ApiClient._(this._dio, this._prefs);

  factory ApiClient.create(AppConfig config, SharedPreferences prefs) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add authentication interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired, try to refresh
            final refreshToken = prefs.getString('refresh_token');
            if (refreshToken != null) {
              try {
                final newToken = await _refreshToken(refreshToken, dio);
                if (newToken != null) {
                  prefs.setString('auth_token', newToken);
                  // Retry the original request
                  final retryOptions = error.requestOptions;
                  retryOptions.headers['Authorization'] = 'Bearer $newToken';
                  final retryResponse = await dio.fetch(retryOptions);
                  return handler.resolve(retryResponse);
                }
              } catch (e) {
                // Refresh failed, clear tokens
                await prefs.remove('auth_token');
                await prefs.remove('refresh_token');
              }
            }
          }
          return handler.next(error);
        },
      ),
    );

    if (config.enableLogging) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestBody: true,
        requestHeader: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ));
    }

    return ApiClient._(dio, prefs);
  }

  static Future<String?> _refreshToken(String refreshToken, Dio dio) async {
    try {
      final response = await dio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });
      return response.data['token'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) {
    return _dio.get<T>(path, queryParameters: query);
  }

  Future<Response<T>> post<T>(String path, {Object? data}) {
    return _dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(String path, {Object? data}) {
    return _dio.put<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path, {Object? data}) {
    return _dio.delete<T>(path, data: data);
  }

  Future<Response<T>> patch<T>(String path, {Object? data}) {
    return _dio.patch<T>(path, data: data);
  }

  // Method to get binary data (for audio files)
  Future<Response<List<int>>> getBinary(String path, {Map<String, dynamic>? query}) {
    return _dio.get<List<int>>(
      path,
      queryParameters: query,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Accept': 'audio/mpeg, audio/wav, audio/*',
        },
      ),
    );
  }

  // Helper method to handle API errors consistently
  Future<T?> handleApiCall<T>(Future<Response<T>> Function() apiCall) async {
    try {
      final response = await apiCall();
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Server error';
        switch (statusCode) {
          case 400:
            return Exception('Bad request: $message');
          case 401:
            return Exception('Unauthorized: Please login again.');
          case 403:
            return Exception('Forbidden: $message');
          case 404:
            return Exception('Not found: $message');
          case 500:
            return Exception('Server error: $message');
          default:
            return Exception('HTTP $statusCode: $message');
        }
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      case DioExceptionType.connectionError:
        return Exception('Connection error. Please check your internet connection.');
      default:
        return Exception('Network error: ${error.message}');
    }
  }

  // Clear authentication tokens
  Future<void> clearAuth() async {
    await _prefs.remove('auth_token');
    await _prefs.remove('refresh_token');
  }

  // Check if user is authenticated
  bool get isAuthenticated {
    final token = _prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }
}





