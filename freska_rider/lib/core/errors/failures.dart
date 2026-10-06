import 'package:equatable/equatable.dart';
import 'exceptions.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final int? statusCode;

  const Failure(this.message, {this.code, this.statusCode});

  @override
  List<Object?> get props => [message, code, statusCode];

  static Failure fromException(Object error) {
    if (error is Failure) return error;

    if (error is ValidationException) {
      return ValidationFailure(
        error.message,
        errors: error.errors,
        code: error.code,
        statusCode: error.statusCode,
      );
    }

    if (error is UnauthorizedException) {
      return AuthenticationFailure(
        error.message,
        code: error.code,
        statusCode: error.statusCode,
      );
    }

    if (error is ForbiddenException) {
      return ForbiddenFailure(
        error.message,
        code: error.code,
        statusCode: error.statusCode,
      );
    }

    if (error is NotFoundException) {
      return NotFoundFailure(
        error.message,
        code: error.code,
        statusCode: error.statusCode,
      );
    }

    if (error is ConflictException) {
      return ConflictFailure(
        error.message,
        code: error.code,
        statusCode: error.statusCode,
      );
    }

    if (error is BadRequestException) {
      return BadRequestFailure(
        error.message,
        code: error.code,
        statusCode: error.statusCode,
      );
    }

    if (error is RateLimitException) {
      return RateLimitFailure(
        error.message,
        code: error.code,
        statusCode: error.statusCode,
      );
    }

    if (error is ServiceUnavailableException) {
      return ServiceUnavailableFailure(
        error.message,
        code: error.code,
        statusCode: error.statusCode,
      );
    }

    if (error is ServerUnreachableException) {
      return ServerUnreachableFailure(
        error.message,
        code: error.code,
      );
    }

    if (error is NoInternetException) {
      return NoInternetFailure(
        message: error.message,
        code: error.code,
      );
    }

    if (error is TimeoutException) {
      return TimeoutFailure(
        error.message,
        code: error.code,
      );
    }

    if (error is OtpException) {
      return OtpFailure(
        error.message,
        code: error.code,
        statusCode: error.statusCode,
      );
    }

    if (error is CacheException) {
      return CacheFailure(
        message: error.message,
        code: error.code,
      );
    }

    if (error is ServerException) {
      return ServerFailure(
        error.message,
        code: error.code,
        statusCode: error.statusCode,
      );
    }

    if (error is AppException) {
      return ServerFailure(
        error.message,
        code: error.code,
        statusCode: error.statusCode,
      );
    }

    return ServerFailure(error.toString());
  }
}

class ServerFailure extends Failure {
  const ServerFailure(
    super.message, {
    super.code = 'ERR_SERVER',
    super.statusCode,
  });
}

class ServerUnreachableFailure extends Failure {
  const ServerUnreachableFailure(
    super.message, {
    super.code = 'ERR_SERVER_UNREACHABLE',
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'No internet connection. Please verify your network.',
    String? code = 'ERR_NETWORK',
  }) : super(message, code: code);
}

class NoInternetFailure extends NetworkFailure {
  const NoInternetFailure({
    super.message = 'No internet connection detected. Please check your mobile data or Wi-Fi.',
    super.code = 'ERR_NO_INTERNET',
  });
}

class TimeoutFailure extends Failure {
  const TimeoutFailure(
    super.message, {
    super.code = 'ERR_TIMEOUT',
  });
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(
    super.message, {
    super.code = 'ERR_UNAUTHENTICATED',
    super.statusCode = 401,
  });
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure(
    super.message, {
    super.code = 'ERR_FORBIDDEN',
    super.statusCode = 403,
  });
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(
    super.message, {
    super.code = 'ERR_NOT_FOUND',
    super.statusCode = 404,
  });
}

class ConflictFailure extends Failure {
  const ConflictFailure(
    super.message, {
    super.code = 'ERR_CONFLICT',
    super.statusCode = 409,
  });
}

class BadRequestFailure extends Failure {
  const BadRequestFailure(
    super.message, {
    super.code = 'ERR_BAD_REQUEST',
    super.statusCode = 400,
  });
}

class RateLimitFailure extends Failure {
  const RateLimitFailure(
    super.message, {
    super.code = 'ERR_RATE_LIMIT',
    super.statusCode = 429,
  });
}

class ServiceUnavailableFailure extends Failure {
  const ServiceUnavailableFailure(
    super.message, {
    super.code = 'ERR_SERVICE_UNAVAILABLE',
    super.statusCode = 503,
  });
}

class OtpFailure extends Failure {
  const OtpFailure(
    super.message, {
    super.code = 'ERR_OTP',
    super.statusCode,
  });
}

class ValidationFailure extends Failure {
  final Map<String, List<String>> errors;

  const ValidationFailure(
    super.message, {
    this.errors = const {},
    super.code = 'ERR_VALIDATION',
    super.statusCode = 422,
  });

  @override
  List<Object?> get props => [message, code, statusCode, errors];
}

class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Failed to load cached data.',
    String? code = 'ERR_CACHE',
  }) : super(message, code: code);
}
