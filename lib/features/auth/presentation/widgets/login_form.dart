import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/presentation/home_page.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import 'email_field.dart';
import 'login_submit_button.dart';
import 'password_field.dart';

class LoginForm extends StatefulWidget { // the widget class 
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState(); // every StatefulWidget has to override this
}

class _LoginFormState extends State<LoginForm> { // the state class
  final _formKey = GlobalKey<FormState>(); // controlls and validate the form
  final _emailController = TextEditingController(); // email widget controller 
  final _passwordController = TextEditingController(); // password widget controller

  @override
  void dispose() { // called when widget is destroyed to release resources (called the cleanup)
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() { // when sumbit button is clicked
    if (_formKey.currentState!.validate()) { // ! = wont be null   // will verify "validator : (value) .." in every Widget of the Form
      context.read<LoginCubit>().login( // we call the cubit function here (goes backwards in the tree to find the Cubit) // BlocProvider (where Cubit can be called) -> LoginPage -> LoginForm
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>( // Widget that lsit CubitState, rebuilds UI auto when needed, executes actions via listener (calls setState alone)
      listener: (context, state) {
        if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message))); // handles the snackbars (SnackBar = small temporary messagebox on the screens bottom)
        } else if (state is LoginSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()), // creates a route to the new page
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is LoginLoading;
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // colmun takes size of the content, and .max = all the height available
            children: [
              EmailField(controller: _emailController, enabled: !isLoading),
              const SizedBox(height: 16),
              PasswordField(controller: _passwordController, enabled: !isLoading),
              const SizedBox(height: 24),
              LoginSubmitButton(isLoading: isLoading, onPressed: isLoading ? null : _submit),
            ],
          ),
        );
      },
    );
  }
}
