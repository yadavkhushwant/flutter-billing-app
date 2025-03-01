import 'package:flutter/material.dart';

InputDecoration getInputDecoration(String? placeholder) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    hintText: placeholder,
    labelText: placeholder,
    labelStyle: TextStyle(
      fontWeight: FontWeight.w500,
      color: Colors.grey[700],
    ),
    hintStyle: TextStyle(
      color: Colors.grey[400],
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.0),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.0),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.0),
      borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.0),
      borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.0),
      borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
    ),
  );
}
