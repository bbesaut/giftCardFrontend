import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/auth_session.dart';

part 'login_state.freezed.dart';

/// UI-facing states for the login screen. `failure` carries only a display
/// message (not the `Failure` type itself): the presentation layer doesn't
/// need to know whether it was a 401, 429 or a network error, just what to
/// show the user — per the earlier decision to keep this increment simple
/// (no dedicated countdown/retry-after handling for rate limiting).
@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState.initial() = LoginInitial;
  const factory LoginState.loading() = LoginLoading;
  const factory LoginState.success(AuthSession session) = LoginSuccess;
  const factory LoginState.failure(String message) = LoginFailure;
}
