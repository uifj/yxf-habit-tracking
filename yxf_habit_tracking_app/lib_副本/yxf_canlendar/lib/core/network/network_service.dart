import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../error/exceptions.dart';
import '../error/error_handler.dart';

/// 网络服务抽象接口
abstract class NetworkService {
  /// GET 请求
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// POST 请求
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  });

  /// PUT 请求
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  });

  /// DELETE 请求
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// 检查网络连接状态
  Future<bool> isConnected();

  /// 设置基础URL
  void setBaseUrl(String baseUrl);

  /// 设置超时时间
  void setTimeout(Duration timeout);

  /// 添加拦截器
  void addInterceptor(Interceptor interceptor);
}

/// 网络服务实现类
class NetworkServiceImpl implements NetworkService {
  late final Dio _dio;
  static const String _tag = 'NetworkService';

  // 默认配置
  static const String _defaultBaseUrl = 'https://api.example.com';
  static const Duration _defaultTimeout = Duration(seconds: 30);

  NetworkServiceImpl({
    String? baseUrl,
    Duration? timeout,
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? _defaultBaseUrl,
      connectTimeout: timeout ?? _defaultTimeout,
      receiveTimeout: timeout ?? _defaultTimeout,
      sendTimeout: timeout ?? _defaultTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  @override
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  @override
  void setTimeout(Duration timeout) {
    _dio.options.connectTimeout = timeout;
    _dio.options.receiveTimeout = timeout;
    _dio.options.sendTimeout = timeout;
  }

  @override
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// 设置拦截器
  void _setupInterceptors() {
    // 请求拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            print('[$_tag] Request: ${options.method} ${options.uri}');
            if (options.data != null) {
              print('[$_tag] Request Data: ${options.data}');
            }
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
                '[$_tag] Response: ${response.statusCode} ${response.requestOptions.uri}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print('[$_tag] Error: ${error.message}');
          }
          handler.next(error);
        },
      ),
    );

    // 重试拦截器
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logPrint: kDebugMode ? print : null,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    );
  }

  /// 处理响应
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else if (response.data is String) {
        try {
          return json.decode(response.data);
        } catch (e) {
          throw const ServerException(
            message: 'Invalid JSON response format',
          );
        }
      } else {
        return {'data': response.data};
      }
    } else {
      throw ServerException(
        message: 'Server error: ${response.statusCode}',
      );
    }
  }

  /// 处理错误
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkException(
            message: 'Connection timeout',
          );

        case DioExceptionType.connectionError:
          return const NetworkException(
            message: 'Connection error',
          );

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode ?? 0;
          return ServerException(
            message: 'Server error: $statusCode',
          );

        case DioExceptionType.cancel:
          return const NetworkException(
            message: 'Request cancelled',
          );

        case DioExceptionType.unknown:
        default:
          return NetworkException(
            message: 'Network error: ${error.message}',
          );
      }
    }

    if (error is SocketException) {
      return const NetworkException(
        message: 'No internet connection',
      );
    }

    return NetworkException(
      message: 'Unknown network error: ${error.toString()}',
    );
  }
}

/// 重试拦截器
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final void Function(String message)? logPrint;
  final int retries;
  final List<Duration> retryDelays;

  RetryInterceptor({
    required this.dio,
    this.logPrint,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ],
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retry_count'] ?? 0;

    if (retryCount < retries && _shouldRetry(err)) {
      logPrint?.call(
          'Retrying request (${retryCount + 1}/$retries): ${err.requestOptions.uri}');

      // 等待重试延迟
      if (retryCount < retryDelays.length) {
        await Future.delayed(retryDelays[retryCount]);
      } else {
        await Future.delayed(retryDelays.last);
      }

      // 更新重试次数
      err.requestOptions.extra['retry_count'] = retryCount + 1;

      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
      } catch (e) {
        if (e is DioException) {
          handler.next(e);
        } else {
          handler.next(err);
        }
      }
    } else {
      handler.next(err);
    }
  }

  /// 判断是否应该重试
  bool _shouldRetry(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        // 5xx 服务器错误可以重试，4xx 客户端错误不重试
        return statusCode >= 500;

      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
      default:
        return false;
    }
  }
}

/// 网络状态监听器
class NetworkStatusListener {
  static NetworkStatusListener? _instance;
  static NetworkStatusListener get instance {
    _instance ??= NetworkStatusListener._internal();
    return _instance!;
  }

  NetworkStatusListener._internal();

  bool _isConnected = true;
  final List<Function(bool)> _listeners = [];

  /// 当前网络状态
  bool get isConnected => _isConnected;

  /// 添加网络状态监听器
  void addListener(Function(bool isConnected) listener) {
    _listeners.add(listener);
  }

  /// 移除网络状态监听器
  void removeListener(Function(bool isConnected) listener) {
    _listeners.remove(listener);
  }

  /// 更新网络状态
  void updateStatus(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      for (final listener in _listeners) {
        listener(isConnected);
      }
    }
  }

  /// 清理所有监听器
  void dispose() {
    _listeners.clear();
  }
}
