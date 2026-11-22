import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_response_dto.freezed.dart';
part 'login_response_dto.g.dart';

/// Mirrors the backend's `AuthResponse`: `{"accessToken": "..."}`.
@freezed
sealed class LoginResponseDto with _$LoginResponseDto {
  const factory LoginResponseDto({required String accessToken}) = _LoginResponseDto;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);
}
