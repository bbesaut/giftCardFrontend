import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authRepository) : super(const LoginState.initial());

  final AuthRepository _authRepository;

  Future<void> login({required String email, required String password}) async {
    emit(const LoginState.loading());
    final result = await _authRepository.login(email: email, password: password);
    result.match(
      (failure) => emit(LoginState.failure(failure.message)),
      (session) => emit(LoginState.success(session)),
    );
  }
}
