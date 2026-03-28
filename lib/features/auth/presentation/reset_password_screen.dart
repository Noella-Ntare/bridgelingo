import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read, size: 80, color: Color(0xFF006B54)),
            const Gap(24),
            const Text(
              'Check Your Email',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Gap(16),
            const Text(
              'We sent you a password reset link. Click the link in your email to set a new password, then come back and log in.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const Gap(32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go('/login'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: const Text('Back to Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}