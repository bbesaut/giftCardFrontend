/// Build-time settings, injected with `--dart-define` or `--dart-define-from-file`.
///
/// Values are compiled into the bundle, so they are public: never put a secret here.
abstract final class AppConfig {
  /// Base URL of the Gift Card Service backend, without trailing slash.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: defaultApiBaseUrl,
  );

  /// Matches the backend's dev profile (served over HTTPS, see its "Dev HTTPS").
  static const String defaultApiBaseUrl = 'https://localhost:8080';
}
