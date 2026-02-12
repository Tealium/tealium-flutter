import 'package:flutter/material.dart';

class TealiumButton extends StatelessWidget {
  const TealiumButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  final String title;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed(),
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
        backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: const BorderSide(color: Colors.blue),
          ),
        ),
      ),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
