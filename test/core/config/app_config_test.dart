import 'package:flutter_test/flutter_test.dart';
import 'package:gift_card_front/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('should_useDefaultApiBaseUrl_when_noDartDefineIsProvided', () {
      expect(AppConfig.apiBaseUrl, AppConfig.defaultApiBaseUrl);
    });

    test('should_haveNoTrailingSlash_when_usingDefaultApiBaseUrl', () {
      expect(AppConfig.defaultApiBaseUrl.endsWith('/'), isFalse);
    });
  });
}
