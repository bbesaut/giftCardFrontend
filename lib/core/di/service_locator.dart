import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_api_client.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../network/auth_session_store.dart';
import '../network/dio_client.dart';

final getIt = GetIt.instance; // getIt = centralize DI of the app

/// Registers every dependency the app needs. Called once from `main()`.
/// Resolution (`getIt<T>()`) happens at each feature's composition boundary
/// (a route's `BlocProvider`), not scattered through business logic.
void configureDependencies() {
  // we declare here all the dependencies as singletons or factories
  getIt.registerLazySingleton<Dio>(createDioClient); // GetIt registers a Dio when someone needs it fore the first time (when this happen, call createDioClient)
  getIt.registerLazySingleton<AuthSessionStore>(AuthSessionStore.new); // GetIt registers an AuthSessionStore when someone needs it fore the first time (when this happen, call ...)

  getIt.registerLazySingleton<AuthApiClient>(() => AuthApiClient(getIt()));
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt()),
  );

  // Factory, not singleton: a Cubit is scoped to the screen that owns it
  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(getIt()),
  ); // when someone calls a logincubit,
  // getIt() = find me the dependency i need here
}
