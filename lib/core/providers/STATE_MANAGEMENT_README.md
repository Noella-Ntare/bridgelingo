# State Management Architecture Guide

## Overview

BridgeLingo uses **Riverpod** for reactive state management. This guide documents the patterns and architecture decisions.

## Why Riverpod?

- ✅ **Compile-safe**: No string-based provider names (unlike Provider)
- ✅ **Testable**: Easy to override providers in tests
- ✅ **Efficient**: Automatic dependency tracking and caching
- ✅ **Scoped**: autoDispose cleans up unused providers
- ✅ **Reactive**: Watches state changes automatically

## Riverpod Provider Types Used

### 1. StateNotifierProvider (Mutable State)
**Used for**: Authentication, user session, app settings

```dart
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider), ref);
});

// AuthNotifier: Business logic class that extends StateNotifier
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  Future<void> login(String email, String password) async {
    state = const AsyncLoading(); // Update UI with loading state
    try {
      await _repository.loginWithEmail(email: email, password: password);
      state = const AsyncData(null); // Success
    } catch (e) {
      state = AsyncError(e, st); // Error state
    }
  }
}
```

**Benefits**:
- Encapsulates state transitions in notifier class
- Supports complex business logic
- Automatically triggers UI rebuilds on state changes

---

### 2. FutureProvider (Async Data)
**Used for**: Fetching user stats, lessons, challenges from Firestore

```dart
final userStatsProvider = FutureProvider.autoDispose<UserStats>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) throw Exception('Not logged in');
  
  // Async operation: fetch from Firestore
  return UserStats(/* ... */);
});
```

**Benefits**:
- Handles async operations cleanly
- `autoDispose`: Cleans up when provider is no longer watched
- Consumers use `.when()` for loading/error/data states

---

### 3. Provider (Immutable Computed State)
**Used for**: Navigation, theme, derived data

```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [ /* ... */ ],
  );
});
```

**Benefits**:
- Lightweight, pure functions
- Cached results until dependencies change
- Used for computed values

---

## Consumer Patterns in UI

### 1. ConsumerWidget (Stateless)
```dart
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStatsAsync = ref.watch(userStatsProvider);
    
    return userStatsAsync.when(
      data: (stats) => /* Show stats */,
      loading: () => CircularProgressIndicator(),
      error: (err, st) => Text('Error: $err'),
    );
  }
}
```

### 2. ConsumerStatefulWidget (Stateful)
```dart
class ProfileScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    // Use authState...
  }
}
```

### 3. ref.listen() - Listen for Changes
```dart
ref.listen(authProvider, (previous, next) {
  if (next is AsyncError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${next.error}')),
    );
  }
});
```

---

## Project Structure

```
lib/
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   │   ├── auth_provider.dart        ← StateNotifierProvider
│   │   │   ├── login_screen.dart         ← ConsumerStatefulWidget
│   │   │   └── register_screen.dart      ← ConsumerStatefulWidget
│   │   └── data/
│   │       └── auth_repository.dart      ← Firebase operations
│   │
│   └── dashboard/
│       ├── data/
│       │   ├── user_stats_provider.dart  ← FutureProvider
│       │   └── course_repository.dart    ← Repository pattern
│       └── pages/
│           └── dashboard_screen.dart     ← ConsumerWidget
│
└── core/
    ├── providers/
    │   └── providers.dart                ← Barrel file (exports all)
    └── router/
        └── app_router.dart               ← Provider for routing
```

---

## State Management Flow

```
User Action (UI)
    ↓
ref.read(authProvider.notifier).login()
    ↓
AuthNotifier.login()
    ↓
state = AsyncLoading() → UI rebuilds (shows spinner)
    ↓
await _repository.loginWithEmail()
    ↓
state = AsyncData(null) or AsyncError()
    ↓
UI rebuilds → shows dashboard or error message
```

---

## Best Practices

### ✅ DO:
- Use StateNotifier for mutable state (auth, user input)
- Use FutureProvider with autoDispose for async data fetching
- Keep business logic in Notifier classes, not UI
- Use AsyncValue patterns for handling async states
- Export providers from barrel file (providers.dart)

### ❌ DON'T:
- Use setState() anywhere (outdated, less efficient)
- Store business logic in UI widgets
- Create providers inline in build methods
- Forget to handle error states in .when()
- Ignore loading states in UI

---

## Testing State Management

```dart
test('login success updates auth state', () async {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(MockAuthRepository()),
    ],
  );
  
  await container.read(authProvider.notifier).login('test@example.com', 'password');
  
  final state = container.read(authProvider);
  expect(state, const AsyncData(null));
});
```

---

## Resources

- [Riverpod Official Docs](https://riverpod.dev)
- [Flutter Riverpod Course](https://codewithandrea.com/courses/flutter-riverpod)
- Pattern: Clean Architecture + Riverpod = Testable, Scalable Code

---

**Last Updated**: March 29, 2026  
**Team**: BridgeLingo Development Team
