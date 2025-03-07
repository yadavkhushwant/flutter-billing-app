import 'package:flutter/material.dart';

DataColumn buildTableColumn(String label){
  return DataColumn(
    label: Expanded(
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}