/// Core Providers Barrel File
/// 
/// This file exports all application-wide Riverpod providers for easier importing.
/// Centralizes provider imports to improve code organization and discoverability.
/// 
/// Usage:
///   import 'package:bridgelingo/core/providers/providers.dart';
///   
///   // Instead of:
///   import 'package:bridgelingo/features/auth/presentation/auth_provider.dart';
///   import 'package:bridgelingo/features/dashboard/data/user_stats_provider.dart';

// Auth Providers
export 'package:bridgelingo/features/auth/presentation/auth_provider.dart'
    show authProvider, AuthNotifier;

// Dashboard Providers  
export 'package:bridgelingo/features/dashboard/data/user_stats_provider.dart'
    show userStatsProvider;

// Common AsyncValue extension for handling states uniformly
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extension on AsyncValue for uniform state handling across the app
/// 
/// Usage:
///   final authState = ref.watch(authProvider);
///   authState.whenOrNull(
///     loading: () => CircularProgressIndicator(),
///     error: (err, st) => ErrorWidget(error: err),
///     data: (_) => DashboardScreen(),
///   );
extension AsyncValueUI<T> on AsyncValue<T> {
  /// Returns true if in loading state
  bool get isLoading => this is AsyncLoading;

  /// Returns true if error occurred
  bool get hasError => this is AsyncError;

  /// Returns the error message safely, or empty string if no error
  String get errorMessage {
    return maybeWhen(
      error: (error, _) => error.toString(),
      orElse: () => '',
    );
  }
}
