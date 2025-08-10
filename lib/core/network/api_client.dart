import 'package:dio/dio.dart';
import 'package:talker/talker.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import '../constants/api_constants.dart';

class ApiClient {
  late final Dio _dio;
  late final Talker _talker;
  
  static ApiClient? _instance;
  
  ApiClient._internal() {
    _talker = Talker();
    _dio = Dio(_baseOptions);
    _setupInterceptors();
  }
  
  factory ApiClient() {
    _instance ??= ApiClient._internal();
    return _instance!;
  }
  
  BaseOptions get _baseOptions => BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
    receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
    sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );
  
  void _setupInterceptors() {
    // Add Talker logger
    _dio.interceptors.add(
      TalkerDioLogger(
        talker: _talker,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true,
          printResponseMessage: true,
        ),
      ),
    );
    
    // Add error interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) {
          _talker.error('API Error', error);
          
          // Transform error for better handling
          final transformedError = _transformError(error);
          handler.reject(transformedError);
        },
      ),
    );
  }
  
  DioException _transformError(DioException error) {
    String message = 'An unexpected error occurred';
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        
        if (statusCode != null) {
          switch (statusCode) {
            case 400:
              message = 'Bad request. Please check your input.';
              break;
            case 401:
              message = 'Unauthorized. Please login again.';
              break;
            case 403:
              message = 'Forbidden. You don\'t have permission to perform this action.';
              break;
            case 404:
              message = 'Resource not found.';
              break;
            case 422:
              if (responseData != null && responseData['detail'] != null) {
                message = 'Validation error: ${_extractValidationMessage(responseData['detail'])}';
              } else {
                message = 'Validation error. Please check your input.';
              }
              break;
            case 500:
            case 502:
            case 503:
              message = 'Server error. Please try again later.';
              break;
            default:
              message = 'Error $statusCode: ${error.message ?? "Unknown error"}';
          }
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error. Please check your internet connection.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Security certificate error.';
        break;
      case DioExceptionType.unknown:
      default:
        message = error.message ?? 'An unknown error occurred.';
    }
    
    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: error.error,
      message: message,
    );
  }
  
  String _extractValidationMessage(dynamic detail) {
    if (detail is List && detail.isNotEmpty) {
      final firstError = detail.first;
      if (firstError is Map) {
        return firstError['msg'] ?? 'Validation error';
      }
    }
    return detail.toString();
  }
  
  Dio get dio => _dio;
  Talker get talker => _talker;
  
  // Convenience methods for common HTTP operations
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
  
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
  
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}