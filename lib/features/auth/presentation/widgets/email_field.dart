import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  const EmailField({required this.controller, required this.enabled, super.key}); 

  final TextEditingController controller;// the controller (a dependency) permit to read the written text
                                         // it contains the field data (text) but is a parameter, so we don't need a statefullwidget here
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      decoration: const InputDecoration(labelText: 'Email'),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email is required';
        }
        if (!value.contains('@')) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }
}
