/// In-memory holder for the current access token.
///
/// Deliberately never persisted (no `localStorage`, no `SharedPreferences`):
/// the backend contract requires the access token to live in memory only.
/// A token lost on reload/restart is recovered via the refresh-token cookie
/// flow (not implemented yet), not by persisting it here.
class AuthSessionStore {
  String? _accessToken;

  String? get accessToken => _accessToken; // getter of the _accessToken

  bool get isAuthenticated => _accessToken != null; 

  void save(String accessToken) { 
    _accessToken = accessToken;
  }

  void clear() {
    _accessToken = null;
  }
}
