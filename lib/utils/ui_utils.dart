import 'package:flutter/material.dart';

// Helper to decide if the screen is desktop.
bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 800;
