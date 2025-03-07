import 'package:flutter/material.dart';

InputDecoration getInputDecoration(String? placeholder, [Widget? suffix]) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.grey.shade100, // Lighter background for visibility (especially when disabled)
    hintText: placeholder,
    hintStyle: TextStyle(
      color: Colors.grey.shade400,
      fontWeight: FontWeight.w400,
      fontSize: 14,
    ),
    labelText: placeholder,
    labelStyle: TextStyle(
      color: Colors.grey.shade600,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(
        color: Colors.grey.shade300,
        width: 1.0,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(
        color: Colors.grey.shade300,
        width: 1.0,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(
        color: Colors.blueAccent,
        width: 1.5,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(
        color: Colors.grey.shade200,
        width: 1.0,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 2.0, // Reduced height
    ),
    suffixIcon: suffix,
  );
}
