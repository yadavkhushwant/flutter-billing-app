import 'package:flutter/material.dart';

ListTile renderDenseListTile(String title, String? subtitle) {
  return ListTile(
    dense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0.0),
    minVerticalPadding: 0,
    visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
    title: Text(title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    subtitle: Text(subtitle ?? '', style: const TextStyle(fontSize: 16)),
  );
}
