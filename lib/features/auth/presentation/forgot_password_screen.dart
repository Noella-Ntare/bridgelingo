import 'package:bridgelingo/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

// Screen for handling password reset via email
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController(); // stores email input
  final _formKey = GlobalKey<FormState>(); // form validation key
  bool _isLoading = false; // shows loader when request is in progress
  bool _emailSent = false; // switches UI after successful request

  // Handles form submission
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Call auth repository to send reset email
      await ref.read(authRepositoryProvider)
          .sendPasswordResetEmail(_emailController.text.trim());

      if (mounted) setState(() => _emailSent = true);
    } catch (e) {
      // Show error message if request fails
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        // Switch between form and success message
        child: _emailSent ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  // Form UI for entering email
  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_reset, size: 80, color: Color(0xFF006B54)),
          const Gap(24),
          const Text(
            'Enter your email and we will send you a password reset link.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const Gap(32),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            // Basic email validation
            validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
          ),
          const Gap(24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : _submit, // disable when loading
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Send Reset Link'),
            ),
          ),
          const Gap(16),
          TextButton(
            onPressed: () => context.go('/login'), // navigate back to login
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  // Success UI shown after email is sent
  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mark_email_read, size: 80, color: Color(0xFF006B54)),
        const Gap(24),
        const Text(
          'Email Sent!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Gap(16),
        Text(
          'We sent a password reset link to ${_emailController.text}. Check your inbox.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
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
    );
  }
}
