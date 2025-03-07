import 'package:flutter/material.dart';

Widget buildInfoText(String label, String? value) {
  return RichText(
    text: TextSpan(
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      children: [
        TextSpan(
          text: "$label: ",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: value?.isNotEmpty == true ? value : 'N/A',
        ),
      ],
    ),
  );
}