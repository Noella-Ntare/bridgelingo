import 'package:bridgelingo/core/router/app_router.dart';
import 'package:bridgelingo/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider), ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;
  final Ref _ref;
  final _storage = const FlutterSecureStorage();

  AuthNotifier(this._repository, this._ref) : super(const AsyncData(null));

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final data = await _repository.login(email, password);
      await _saveSession(data);
      state = const AsyncData(null);
      _ref.read(routerProvider).go('/dashboard');
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> register(String fullName, String email, String password) async {
    state = const AsyncLoading();
    try {
      final data = await _repository.register(fullName, email, password);
      await _saveSession(data);
      state = const AsyncData(null);
      _ref.read(routerProvider).go('/dashboard');
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    _ref.read(routerProvider).go('/login');
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    await _storage.write(key: 'auth_token', value: data['token']);
    await _storage.write(key: 'user_id', value: data['userId']);
    await _storage.write(key: 'user_name', value: data['fullName']);
    await _storage.write(key: 'user_email', value: data['email']);
  }
}
