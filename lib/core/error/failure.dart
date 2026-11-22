/// Error types a repository can return instead of throwing, so presentation
/// code never deals with raw exceptions (Dio, platform, etc). Shared across
/// features: every repository maps its own exceptions onto these same types.
sealed class Failure {
  // sealed class = abstract class but childs can only be declared in the same library (~ same file)
  const Failure(this.message);

  final String message;
}

//all failures types below

final class ValidationFailure extends Failure {
  // when data given is bad according to business rules (invalid email, password too short, ..)
  const ValidationFailure(super.message);
}

final class UnauthorizedFailure extends Failure {
  // (401) when jwt is missing / expired, or credentials bad
  const UnauthorizedFailure(super.message);
}

final class ForbiddenFailure extends Failure {
  // (403) when user is authenticated, but not authorized to do something
  const ForbiddenFailure(super.message);
}

final class RateLimitFailure extends Failure {
  // (429) when user send too many request
  const RateLimitFailure(super.message, {this.retryAfter}); // {} = named parameter = optional if no required, and has to be called with the name : ex : (retryAfter: 60)

  /// Parsed from the backend's `Retry-After` header, when present.
  final Duration? retryAfter; // ? = Duration or null
}

final class ServerFailure extends Failure {
  // (5xx) when server faces an error
  const ServerFailure(super.message);
}

final class NetworkFailure extends Failure {
  // No internet access, ..
  const NetworkFailure(super.message);
}

final class UnknownFailure extends Failure {
  // Error out of the ones above
  const UnknownFailure(super.message);
}
