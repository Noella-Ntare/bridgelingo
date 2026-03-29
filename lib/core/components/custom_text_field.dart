import 'package:flutter/material.dart';

// Reusable text field widget to keep UI consistent across the app
class CustomTextField extends StatelessWidget {
  final String label; // Text shown as the field label
  final TextEditingController controller; // Controls input value
  final bool isPassword; // Determines if text should be hidden
  final IconData icon; // Icon displayed at the start of the field

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.isPassword = false, // default: normal text field
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Adds background styling and rounded corners
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword, // hides text if it's a password field
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon), // icon inside the field
          border: InputBorder.none, // removes default border
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
