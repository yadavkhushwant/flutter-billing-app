import 'package:billing_application/widget/main_scaffold.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      child: const Text("Home"),
    );
  }
}
