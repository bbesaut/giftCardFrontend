import 'package:flutter_test/flutter_test.dart';
import 'package:gift_card_front/features/auth/data/dtos/login_request_dto.dart';

void main() {
  test('toJson produces the exact shape the backend expects', () {
    const dto = LoginRequestDto(email: 'user@example.com', password: 'secret123');

    expect(dto.toJson(), {'email': 'user@example.com', 'password': 'secret123'});
  });
}
