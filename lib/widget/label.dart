import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  final String label;
  final bool? required;
  final Color? color;
  const Label(this.label, {Key? key, this.required, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            if (required == true)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
