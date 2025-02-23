import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // After a delay, navigate to the main home screen.
    Future.delayed(const Duration(milliseconds: 1500), () {
      Get.offAllNamed("/home");
    });

    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.primaryContainer,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 16.0),
            Text(
              'Billing Software by Khushwant',
              style: TextStyle(
                fontSize: 24.0,
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
