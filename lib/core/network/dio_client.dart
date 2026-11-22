import 'package:dio/dio.dart';

import '../config/app_config.dart';

/// Builds the shared [Dio] client used by every feature's data layer.
///
/// `withCredentials` makes the browser send and accept the backend's
/// `refresh_token` cookie on cross-origin calls, per the backend's CORS
/// contract. The native (io) adapter used on mobile/desktop ignores this
/// `extra` option, so the same client works unchanged there.
Dio createDioClient() {
  return Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      extra: const {'withCredentials': true},
    ),
  );
}
