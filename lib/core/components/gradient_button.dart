import 'package:flutter/material.dart';

// Custom button with gradient background and loading state
class GradientButton extends StatelessWidget {
  final String text; // Button label
  final VoidCallback onTap; // Function triggered on tap
  final bool isLoading; // Shows loader instead of text when true

  const GradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false, // default: not loading
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // takes full width
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // Gradient background using theme colors
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.tertiary,
          ],
        ),
        // Soft shadow for depth
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent, // allows gradient to show
        child: InkWell(
          onTap: isLoading ? null : onTap, // disable tap when loading
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white) // loader
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
