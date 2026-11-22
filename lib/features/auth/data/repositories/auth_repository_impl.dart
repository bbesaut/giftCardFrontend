import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/auth_session_store.dart';
import '../../../../core/network/dio_failure_mapper.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api_client.dart';
import '../dtos/login_request_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._apiClient, this._sessionStore);

  final AuthApiClient _apiClient;
  final AuthSessionStore _sessionStore;

  @override
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.login(
        LoginRequestDto(email: email, password: password),
      );
      _sessionStore.save(response.accessToken);
      return Right(AuthSession(accessToken: response.accessToken));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    }
  }
}
