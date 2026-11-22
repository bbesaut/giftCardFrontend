import 'package:dio/dio.dart';

import '../error/failure.dart';
import 'api_error_dto.dart';

/// Maps a [DioException] onto the shared [Failure] hierarchy, using the
/// backend's error envelope (`ApiErrorDto`) and status code. Shared across
/// every feature's repository, since the backend's error contract is the
/// same for all endpoints (see the project's CLAUDE.md "Backend Contract").
Failure mapDioExceptionToFailure(DioException exception) {
  // purpose = transform the backend's error reponse into a dart Failure
  final response = exception.response;
  if (response == null) {
    return NetworkFailure(
      exception.message ?? 'Could not reach the server. Check your connection.',
    );
  }

  final message =
      _tryParseApiError(response.data)?.message ?? 'Unexpected server error.';

  switch (response.statusCode) {
    case 400:
      return ValidationFailure(message);
    case 401:
      return UnauthorizedFailure(message);
    case 403:
      return ForbiddenFailure(message);
    case 429:
      return RateLimitFailure(
        message,
        retryAfter: _parseRetryAfter(response.headers),
      );
    case 500:
      return ServerFailure(message);
    default:
      return UnknownFailure(message);
  }
}

ApiErrorDto? _tryParseApiError(dynamic data) {
  if (data is Map<String, dynamic>) {
    return ApiErrorDto.fromJson(data);
  }
  return null;
}

Duration? _parseRetryAfter(Headers headers) {
  final seconds = int.tryParse(headers.value('retry-after') ?? '');
  return seconds == null ? null : Duration(seconds: seconds);
}
