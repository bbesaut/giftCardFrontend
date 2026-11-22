import 'package:dio/dio.dart';

import '../dtos/login_request_dto.dart';
import '../dtos/login_response_dto.dart';

/// Thin wrapper around Dio: raw HTTP, zero business logic, zero error
/// mapping. Lets [DioException] propagate — the repository maps it to a
/// `Failure`.
class AuthApiClient {
  AuthApiClient(this._dio);

  final Dio _dio;

  Future<LoginResponseDto> login(LoginRequestDto request) async { // the http call
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/login',
      data: request.toJson(),
    );
    return LoginResponseDto.fromJson(response.data!);// ! = is not gonna be null
  }
}
