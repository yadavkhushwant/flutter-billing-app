import 'package:flutter/material.dart';

import 'input_decoration.dart';

class TextInput extends StatefulWidget {
  final String? placeholder;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool? isPassword;
  final String? initialValue;
  final bool? enabled;
  final void Function(String)? onChanged;
  const TextInput({
    super.key,
    this.placeholder,
    this.controller,
    this.validator,
    this.keyboardType,
    this.isPassword,
    this.initialValue,
    this.enabled,
    this.onChanged,
  });

  @override
  TextInputState createState() => TextInputState();
}

class TextInputState extends State<TextInput> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword ?? false,
      initialValue: widget.initialValue,
      enabled: widget.enabled,
      decoration: getInputDecoration(widget.placeholder),
      validator: widget.validator,
      onChanged: widget.onChanged,
    );
  }
}
