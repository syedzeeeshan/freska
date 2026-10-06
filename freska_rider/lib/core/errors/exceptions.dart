abstract class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  const AppException(this.message, {this.code, this.statusCode});

  @override
  String toString() => '$runtimeType: $message (code: $code, status: $statusCode)';
}

class ServerException extends AppException {
  const ServerException(
    super.message, {
    super.code = 'ERR_SERVER',
    super.statusCode = 500,
  });
}

class ValidationException extends AppException {
  final Map<String, List<String>> errors;

  const ValidationException(
    super.message, {
    this.errors = const {},
    super.code = 'ERR_VALIDATION',
    super.statusCode = 422,
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(
    super.message, {
    super.code = 'ERR_UNAUTHORIZED',
  }) : super(statusCode: 401);
}

class ForbiddenException extends AppException {
  const ForbiddenException(
    super.message, {
    super.code = 'ERR_FORBIDDEN',
    super.statusCode = 403,
  });
}

class NotFoundException extends AppException {
  const NotFoundException(
    super.message, {
    super.code = 'ERR_NOT_FOUND',
    super.statusCode = 404,
  });
}

class ConflictException extends AppException {
  const ConflictException(
    super.message, {
    super.code = 'ERR_CONFLICT',
    super.statusCode = 409,
  });
}

class BadRequestException extends AppException {
  const BadRequestException(
    super.message, {
    super.code = 'ERR_BAD_REQUEST',
    super.statusCode = 400,
  });
}

class RateLimitException extends AppException {
  const RateLimitException(
    super.message, {
    super.code = 'ERR_RATE_LIMIT',
    super.statusCode = 429,
  });
}

class ServiceUnavailableException extends AppException {
  const ServiceUnavailableException(
    super.message, {
    super.code = 'ERR_SERVICE_UNAVAILABLE',
    super.statusCode = 503,
  });
}

class ServerUnreachableException extends AppException {
  const ServerUnreachableException(
    super.message, {
    super.code = 'ERR_SERVER_UNREACHABLE',
  });
}

class NoInternetException extends AppException {
  const NoInternetException(
    super.message, {
    super.code = 'ERR_NO_INTERNET',
  });
}

class TimeoutException extends AppException {
  const TimeoutException(
    super.message, {
    super.code = 'ERR_TIMEOUT',
  });
}

class SecurityException extends AppException {
  const SecurityException(
    super.message, {
    super.code = 'ERR_SECURITY',
  });
}

class RequestCancelledException extends AppException {
  const RequestCancelledException(
    super.message, {
    super.code = 'ERR_CANCELLED',
  });
}

class OtpException extends AppException {
  const OtpException(
    super.message, {
    super.code = 'ERR_OTP',
    super.statusCode,
  });
}

class CacheException extends AppException {
  const CacheException(
    super.message, {
    super.code = 'ERR_CACHE',
  });
}
