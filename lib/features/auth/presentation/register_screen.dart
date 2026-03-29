import 'package:bridgelingo/core/components/custom_text_field.dart';
import 'package:bridgelingo/core/components/gradient_button.dart';
import 'package:bridgelingo/features/auth/presentation/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

// Screen for user registration
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  // Triggers registration using provider
  void _register() {
    ref.read(authProvider.notifier).register(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider); // listens to auth state

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            // Allows scrolling on smaller screens
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(40),
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const Text('Start your journey to mastering Kinyarwanda!'),
                const Gap(40),

                // Name input
                CustomTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  icon: Icons.person_outline,
                ),
                const Gap(16),

                // Email input
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                ),
                const Gap(16),

                // Password input
                CustomTextField(
                  label: 'Password',
                  controller: _passwordController,
                  icon: Icons.lock_outlined,
                  isPassword: true,
                ),
                const Gap(32),

                // Submit button with loading state
                GradientButton(
                  text: 'Sign Up',
                  onTap: _register,
                  isLoading: authState.isLoading,
                ),
                const Gap(24),

                // Navigation to login screen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
