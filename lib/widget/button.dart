import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Define button types
enum ButtonType { primary, secondary }

class Button extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? leadingIcon;
  final ButtonType type;

  const Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.type = ButtonType.primary, // Default to primary
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(Get.context!).colorScheme;

    // Define styles based on button type
    // final isPrimary = type == ButtonType.primary;
    // final backgroundColor = isPrimary ? colorScheme.primary : Colors.transparent;
    // final disabledBackgroundColor = isPrimary ? colorScheme.primary.withAlpha(180) : Colors.transparent;
    // final borderColor = isPrimary ? Colors.transparent : colorScheme.primary;
    // final foregroundColor = isPrimary ? Colors.white : colorScheme.primary;

    // Define styles based on button type
    final isPrimary = type == ButtonType.primary;
    final backgroundColor = isPrimary ? colorScheme.primary : colorScheme.surface;
    final disabledBackgroundColor = isPrimary ? colorScheme.primary.withAlpha(180) : Colors.transparent;
    final borderColor = isPrimary ? Colors.transparent : colorScheme.primary;
    final foregroundColor = isPrimary ? Colors.white : colorScheme.primary;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        disabledBackgroundColor: disabledBackgroundColor,
        splashFactory: InkSplash.splashFactory,
        enableFeedback: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Matches input fields
          side: BorderSide(color: borderColor, width: 1.5), // Adds border for secondary button
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: isPrimary ? 2 : 0, // Remove elevation for secondary button
        minimumSize: const Size(24, 48),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null && !isLoading) ...[
            Icon(
              leadingIcon,
              color: foregroundColor,
            ),
            const SizedBox(width: 8),
          ],
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
          if (!isLoading)
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: foregroundColor,
              ),
            ),
        ],
      ),
    );
  }
}
