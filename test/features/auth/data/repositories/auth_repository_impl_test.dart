import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_card_front/core/error/failure.dart';
import 'package:gift_card_front/core/network/auth_session_store.dart';
import 'package:gift_card_front/features/auth/data/datasources/auth_api_client.dart';
import 'package:gift_card_front/features/auth/data/dtos/login_request_dto.dart';
import 'package:gift_card_front/features/auth/data/dtos/login_response_dto.dart';
import 'package:gift_card_front/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthApiClient extends Mock implements AuthApiClient {}

void main() {
  late _MockAuthApiClient apiClient;
  late AuthSessionStore sessionStore;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      const LoginRequestDto(
        email: 'fallback@example.com',
        password: 'fallback',
      ),
    );
  });

  setUp(() {
    apiClient = _MockAuthApiClient();
    sessionStore = AuthSessionStore();
    repository = AuthRepositoryImpl(apiClient, sessionStore);
  });

  test('on success, returns the AuthSession and saves the access token in the session store', () async {
    when(() => apiClient.login(any())).thenAnswer(
      (_) async => const LoginResponseDto(accessToken: 'jwt.token.value'),
    );

    final result = await repository.login(
      email: 'user@example.com',
      password: 'secret123',
    );

    expect(result.getRight().toNullable()?.accessToken, 'jwt.token.value');
    expect(sessionStore.accessToken, 'jwt.token.value');
  });

  test('on a DioException, returns the mapped Failure and does not touch the session store', () async {
    final requestOptions = RequestOptions(path: '/api/v1/auth/login');
    when(() => apiClient.login(any())).thenThrow(
      DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
          data: {
            'error': 'Unauthorized',
            'message': 'Invalid email or password',
          },
        ),
      ),
    );

    final result = await repository.login(
      email: 'user@example.com',
      password: 'wrong',
    );

    expect(result.getLeft().toNullable(), isA<UnauthorizedFailure>());
    expect(sessionStore.isAuthenticated, isFalse);
  });
}
