import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart';
import 'features/auth/presentation/cubit/login_cubit.dart';
import 'features/auth/presentation/pages/login_page.dart';

class GiftCardApp extends StatelessWidget {
  const GiftCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gift Card Service',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: BlocProvider<LoginCubit>(
        // define the first page shown when app started (blocprovider creates instance of logincubit, and make it available to his childs)
        create: (_) => getIt<LoginCubit>(),
        child: const LoginPage(),
      ),
    );
  }
}
