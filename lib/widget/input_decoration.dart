import 'package:flutter/material.dart';

InputDecoration getInputDecoration(String? placeholder) {
  return InputDecoration(
    filled: true,
    hintText: placeholder,
    border: OutlineInputBorder(
      borderSide: const BorderSide(
        width: 0,
        style: BorderStyle.none,
      ),
      borderRadius: BorderRadius.circular(10.0),
    ),
    contentPadding: const EdgeInsets.all(16.0),
  );
}
