import 'package:flutter/material.dart';

class TealiumButton extends StatelessWidget {
  const TealiumButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.disabled = false,
  });

  final String title;
  final Function onPressed;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: disabled ? null : () => onPressed(),
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
        backgroundColor: disabled
            ? WidgetStateProperty.all<Color>(Colors.grey)
            : WidgetStateProperty.all<Color>(Colors.blue),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: disabled
                ? const BorderSide(color: Colors.grey)
                : const BorderSide(color: Colors.blue),
          ),
        ),
      ),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }
}
