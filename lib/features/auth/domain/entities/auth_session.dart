import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_session.freezed.dart';

/// Result of a successful login: just the access token for now.
///
/// Uses `freezed` purely for value equality (so it compares correctly once
/// embedded in `LoginState` during tests), not for union-type behavior.
@freezed // (from package freezed) will generate automaticly constructors, getters, setters, copyWith, == hascode and toString
sealed class AuthSession with _$AuthSession {
  // "$" with freezed will generate .dart and .freezed.dart ()
  const factory AuthSession({required String accessToken}) = _AuthSession;
}

// dart run build_runner build --delete-conflicting-outputs
// Execute this at the project's root to generate / update freezed.dart files

// dart run build_runner watch --delete-conflicting-outputs
// The build_runner will watch the files, and update freezed.dart files everytime they change
