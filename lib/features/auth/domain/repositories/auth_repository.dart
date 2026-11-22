import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/auth_session.dart';

/// Port the data layer implements and the presentation layer depends on.
abstract interface class AuthRepository { // abstract = not instanciable directly, interface = other classes can "implements" this
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  });
}
