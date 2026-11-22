import 'package:flutter_test/flutter_test.dart';
import 'package:gift_card_front/features/auth/data/dtos/login_response_dto.dart';

void main() {
  test('fromJson parses the backend AuthResponse shape', () {
    final dto = LoginResponseDto.fromJson({'accessToken': 'jwt.token.value'});

    expect(dto.accessToken, 'jwt.token.value');
  });
}
