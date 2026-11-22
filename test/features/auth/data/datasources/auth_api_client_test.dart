import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_card_front/features/auth/data/datasources/auth_api_client.dart';
import 'package:gift_card_front/features/auth/data/dtos/login_request_dto.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late AuthApiClient client;

  setUp(() {
    dio = _MockDio();
    client = AuthApiClient(dio);
  });

  test('login posts the serialized request body to /api/v1/auth/login and parses the response', () async {
    const request = LoginRequestDto(email: 'user@example.com', password: 'secret123');
    final requestOptions = RequestOptions(path: '/api/v1/auth/login');

    when(
      () => dio.post<Map<String, dynamic>>('/api/v1/auth/login', data: request.toJson()),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: requestOptions,
        statusCode: 200,
        data: {'accessToken': 'jwt.token.value'},
      ),
    );

    final response = await client.login(request);

    expect(response.accessToken, 'jwt.token.value');
  });

  test('login lets a DioException propagate unchanged for the repository to map', () async {
    final requestOptions = RequestOptions(path: '/api/v1/auth/login');
    when(() => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data'))).thenThrow(
      DioException(
        requestOptions: requestOptions,
        response: Response(requestOptions: requestOptions, statusCode: 401),
      ),
    );

    await expectLater(
      client.login(const LoginRequestDto(email: 'user@example.com', password: 'wrong')),
      throwsA(isA<DioException>()),
    );
  });
}
