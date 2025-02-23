import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool? isLoading;
  final IconData? leadingIcon;

  Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading,
    this.leadingIcon,
  });

  final colorScheme = Theme.of(Get.context!).colorScheme;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading == true ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.inversePrimary,
        disabledBackgroundColor: colorScheme.primary.withAlpha(180),
        splashFactory: InkSplash.splashFactory,
        enableFeedback: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null && isLoading != true)
            Icon(
              leadingIcon,
              color: colorScheme.primary,
            ),
          if (isLoading == true)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(),
            ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
