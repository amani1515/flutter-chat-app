import 'package:flutter/material.dart';
class MyButton extends StatelessWidget { // Corrected spelling in the class name
  final void Function()? onTap;
  final String text;

  const MyButton({super.key,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(
          child: Text( // Removed const from here
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
