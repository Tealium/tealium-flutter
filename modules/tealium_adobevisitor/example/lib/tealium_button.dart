import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TealiumButton extends StatelessWidget {
  TealiumButton({required this.title, required this.onPressed, this.disabled = false});
  final String title;
  final Function onPressed;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child: Text(title.toUpperCase(), style: TextStyle(fontSize: 14)),
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor: disabled ? MaterialStateProperty.all<Color>(Colors.grey) : MaterialStateProperty.all<Color>(Colors.blue),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: disabled ? BorderSide(color: Colors.grey) : BorderSide(color: Colors.blue)))),
        onPressed: () {
          if (!disabled) onPressed();
        });
  }
}
