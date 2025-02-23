import 'package:flutter/material.dart';

class SquareIcon extends StatelessWidget {
  final IconData icon;

  const SquareIcon(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        icon,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
