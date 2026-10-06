import 'dart:io';
import 'package:dio/dio.dart';
import '../../config/environment.dart';
import '../../config/network_constants.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  final Dio dio;
  final SecureStorageService secureStorage;

  ApiClient({
    required this.dio,
    required this.secureStorage,
  }) {
    _initialize();
  }

  void _initialize() {
    dio.options = BaseOptions(
      baseUrl: EnvironmentConfig.current.apiBaseUrl,
      connectTimeout:
          const Duration(milliseconds: NetworkConstants.connectTimeoutMs),
      receiveTimeout:
          const Duration(milliseconds: NetworkConstants.receiveTimeoutMs),
      sendTimeout:
          const Duration(milliseconds: NetworkConstants.connectTimeoutMs),
      headers: {
        NetworkConstants.headerAccept: 'application/json',
        NetworkConstants.headerContentType: 'application/json',
        NetworkConstants.headerPlatform: Platform.isAndroid ? 'android' : 'ios',
        NetworkConstants.headerAppVersion: '1.0.0+1',
      },
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await secureStorage.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers[NetworkConstants.headerAuthorization] =
                  'Bearer $token';
            }

            final deviceId = await secureStorage.getOrCreateDeviceId();
            options.headers[NetworkConstants.headerDeviceId] = deviceId;
          } catch (_) {}

          return handler.next(options);
        },
      ),
    );
  }

  AppException _mapDioException(DioException error) {
    final response = error.response;

    if (response != null) {
      final statusCode = response.statusCode ?? 500;
      final data = response.data;

      String message = 'A server error occurred.';
      String? errorCode;
      Map<String, List<String>> formattedErrors = {};

      if (data is Map) {
        message = data['message']?.toString() ?? message;
        errorCode = data['error_code']?.toString() ?? data['code']?.toString();

        final rawErrors = data['errors'];
        if (rawErrors is Map) {
          rawErrors.forEach((key, value) {
            if (value is List) {
              formattedErrors[key.toString()] =
                  value.map((e) => e.toString()).toList();
            } else if (value != null) {
              formattedErrors[key.toString()] = [value.toString()];
            }
          });
        }
      }

      switch (statusCode) {
        case 400:
          return BadRequestException(message, code: errorCode ?? 'ERR_BAD_REQUEST');
        case 401:
          return UnauthorizedException(message);
        case 403:
          return ForbiddenException(message, code: errorCode ?? 'ERR_FORBIDDEN');
        case 404:
          return NotFoundException(message, code: errorCode ?? 'ERR_NOT_FOUND');
        case 409:
          return ConflictException(message, code: errorCode ?? 'ERR_CONFLICT');
        case 422:
          return ValidationException(
            message,
            errors: formattedErrors,
            code: errorCode ?? 'ERR_VALIDATION',
          );
        case 429:
          return RateLimitException(
            message.isNotEmpty && message != 'A server error occurred.'
                ? message
                : 'Too many requests. Please wait before trying again.',
            code: errorCode ?? 'ERR_RATE_LIMIT',
          );
        case 500:
          return ServerException(
            message,
            code: errorCode ?? 'ERR_INTERNAL_SERVER',
            statusCode: 500,
          );
        case 502:
        case 503:
        case 504:
          return ServiceUnavailableException(
            'Freska service is temporarily unavailable. Please retry shortly.',
            code: errorCode ?? 'ERR_SERVICE_UNAVAILABLE',
            statusCode: statusCode,
          );
        default:
          return ServerException(
            message,
            code: errorCode,
            statusCode: statusCode,
          );
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException(
          'Connection timed out while contacting Freska server. Please try again.',
        );
      case DioExceptionType.connectionError:
        final rawError = error.error;
        final rawStr = rawError?.toString().toLowerCase() ?? '';
        if (rawStr.contains('refused') ||
            rawStr.contains('connection refused') ||
            rawStr.contains('failed host lookup') == false) {
          return ServerUnreachableException(
            'Unable to reach Freska server at ${error.requestOptions.baseUrl}. Please check server connectivity.',
          );
        }
        return const NoInternetException(
          'No internet connection. Please verify your mobile network or Wi-Fi.',
        );
      case DioExceptionType.badCertificate:
        return const SecurityException(
          'Secure SSL connection could not be established.',
        );
      case DioExceptionType.cancel:
        return const RequestCancelledException(
          'Request was cancelled.',
        );
      default:
        if (error.error is SocketException) {
          return ServerUnreachableException(
            'Unable to connect to Freska server at ${error.requestOptions.baseUrl}.',
          );
        }
        return ServerException(
          error.message ?? 'Network communication failure.',
        );
    }
  }

  Future<Response<T>> _execute<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _execute(() => dio.get(path, queryParameters: queryParameters, options: options));
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _execute(() => dio.post(path, data: data, queryParameters: queryParameters, options: options));
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _execute(() => dio.put(path, data: data, queryParameters: queryParameters, options: options));
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _execute(() => dio.patch(path, data: data, queryParameters: queryParameters, options: options));
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _execute(() => dio.delete(path, data: data, queryParameters: queryParameters, options: options));
  }
}
