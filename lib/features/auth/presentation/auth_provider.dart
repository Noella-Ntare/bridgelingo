import 'package:bridgelingo/core/router/app_router.dart';
import 'package:bridgelingo/features/auth/data/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider), ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(const AsyncData(null));

  // --- Email/Password Login ---
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _repository.loginWithEmail(email: email, password: password);
      state = const AsyncData(null);
      _ref.read(routerProvider).go('/dashboard');
    } on Exception catch (e, st) {
      state = AsyncError(_friendlyError(e), st);
    }
  }

  // --- Email/Password Register ---
  Future<void> register(String fullName, String email, String password) async {
    state = const AsyncLoading();
    try {
      await _repository.registerWithEmail(
        fullName: fullName,
        email: email,
        password: password,
      );
      state = const AsyncData(null);
      _ref.read(routerProvider).go('/dashboard');
    } on Exception catch (e, st) {
      state = AsyncError(_friendlyError(e), st);
    }
  }

  // --- Google Sign-In ---
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      await _repository.signInWithGoogle();
      state = const AsyncData(null);
      _ref.read(routerProvider).go('/dashboard');
    } on Exception catch (e, st) {
      state = AsyncError(_friendlyError(e), st);
    }
  }

  // --- Forgot Password ---
  Future<void> forgotPassword(String email) async {
    state = const AsyncLoading();
    try {
      await _repository.sendPasswordResetEmail(email);
      state = const AsyncData(null);
    } on Exception catch (e, st) {
      state = AsyncError(_friendlyError(e), st);
    }
  }

  // --- Logout ---
  Future<void> logout() async {
    await _repository.signOut();
    _ref.read(routerProvider).go('/login');
  }

  // --- Convert Firebase errors to readable messages ---
  String _friendlyError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'network-request-failed':
          return 'No internet connection.';
        default:
          return e.message ?? 'An error occurred.';
      }
    }
    return e.toString();
  }
}