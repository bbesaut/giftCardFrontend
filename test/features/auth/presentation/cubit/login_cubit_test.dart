import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gift_card_front/core/error/failure.dart';
import 'package:gift_card_front/features/auth/domain/entities/auth_session.dart';
import 'package:gift_card_front/features/auth/domain/repositories/auth_repository.dart';
import 'package:gift_card_front/features/auth/presentation/cubit/login_cubit.dart';
import 'package:gift_card_front/features/auth/presentation/cubit/login_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository authRepository;

  setUp(() {
    authRepository = _MockAuthRepository();
  });

  test('initial state is LoginState.initial', () {
    expect(LoginCubit(authRepository).state, const LoginState.initial());
  });

  blocTest<LoginCubit, LoginState>(
    'emits [loading, success] when the repository returns a Right',
    build: () {
      when(
        () => authRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Right(AuthSession(accessToken: 'jwt.token.value')),
      );
      return LoginCubit(authRepository);
    },
    act: (cubit) =>
        cubit.login(email: 'user@example.com', password: 'secret123'),
    expect: () => [
      const LoginState.loading(),
      const LoginState.success(AuthSession(accessToken: 'jwt.token.value')),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'emits [loading, failure] with the Failure message when the repository returns a Left',
    build: () {
      when(
        () => authRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left(UnauthorizedFailure('Invalid email or password')),
      );
      return LoginCubit(authRepository);
    },
    act: (cubit) => cubit.login(email: 'user@example.com', password: 'wrong'),
    expect: () => [
      const LoginState.loading(),
      const LoginState.failure('Invalid email or password'),
    ],
  );
}
