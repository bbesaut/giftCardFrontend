import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request_dto.freezed.dart'; // to write yourself, if not freezed will not generate it
part 'login_request_dto.g.dart'; // same here

/// Mirrors the backend's `LoginRequest`: `{"email": "...", "password": "..."}`.
@freezed
sealed class LoginRequestDto with _$LoginRequestDto {
  const factory LoginRequestDto({
    // = when someone instaciate a LoginRequestDto, use the constructor of _LoginRequestDto to do it
    required String email,
    required String password,
  }) = _LoginRequestDto;

  factory LoginRequestDto.fromJson(
    Map<String, dynamic> json,
  ) => // constructor but from json
      _$LoginRequestDtoFromJson(json); // jsonserializable will generate this function, using the constructor fields above to know what should be in the json
}
