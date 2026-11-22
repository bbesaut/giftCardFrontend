import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_card_front/core/error/failure.dart';
import 'package:gift_card_front/core/network/dio_failure_mapper.dart';

DioException _exceptionWithResponse(
  int statusCode,
  Map<String, dynamic>? data, {
  Map<String, List<String>> headers = const {},
}) {
  final requestOptions = RequestOptions(path: '/api/v1/auth/login');
  return DioException(
    requestOptions: requestOptions,
    response: Response(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: data,
      headers: Headers.fromMap(headers),
    ),
  );
}

void main() {
  group('mapDioExceptionToFailure', () { // function's name we want to test
    test('maps 400 to ValidationFailure with the backend message', () {
      final failure = mapDioExceptionToFailure(
        _exceptionWithResponse(400, {'error': 'Bad Request', 'message': 'Email cannot be blank'}),
      );

      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Email cannot be blank');
    });

    test('maps 401 to UnauthorizedFailure', () {
      final failure = mapDioExceptionToFailure(
        _exceptionWithResponse(401, {'error': 'Unauthorized', 'message': 'Invalid email or password'}),
      );

      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.message, 'Invalid email or password');
    });

    test('maps 403 to ForbiddenFailure', () {
      final failure = mapDioExceptionToFailure(
        _exceptionWithResponse(403, {'error': 'Forbidden', 'message': 'Email Not Verified'}),
      );

      expect(failure, isA<ForbiddenFailure>());
    });

    test('maps 429 to RateLimitFailure and parses the Retry-After header', () {
      final failure = mapDioExceptionToFailure(
        _exceptionWithResponse(
          429,
          {'error': 'Too Many Requests', 'message': 'Too many requests. Please try again later.'},
          headers: {'retry-after': const ['30']},
        ),
      );

      expect(failure, isA<RateLimitFailure>());
      expect((failure as RateLimitFailure).retryAfter, const Duration(seconds: 30));
    });

    test('maps 429 without a Retry-After header to a null retryAfter', () {
      final failure = mapDioExceptionToFailure(
        _exceptionWithResponse(429, {'error': 'Too Many Requests', 'message': 'Slow down'}),
      );

      expect((failure as RateLimitFailure).retryAfter, isNull);
    });

    test('maps 500 to ServerFailure', () {
      final failure = mapDioExceptionToFailure(
        _exceptionWithResponse(500, {'error': 'Internal Server Error', 'message': 'Database error occurred'}),
      );

      expect(failure, isA<ServerFailure>());
    });

    test('maps an unexpected status code to UnknownFailure', () {
      final failure = mapDioExceptionToFailure(
        _exceptionWithResponse(418, {'error': "I'm a teapot", 'message': 'Unexpected'}),
      );

      expect(failure, isA<UnknownFailure>());
    });

    test('maps a non-JSON error body to a fallback message instead of throwing', () {
      final failure = mapDioExceptionToFailure(_exceptionWithResponse(500, null));

      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Unexpected server error.');
    });

    test('maps a connection error (no response at all) to NetworkFailure', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/login'),
        type: DioExceptionType.connectionError,
        message: 'Connection refused',
      );

      expect(mapDioExceptionToFailure(exception), isA<NetworkFailure>());
    });
  });
}
