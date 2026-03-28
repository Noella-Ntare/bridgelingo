import 'package:bridgelingo/core/presentation/main_scaffold.dart';
import 'package:bridgelingo/features/auth/presentation/login_screen.dart';
import 'package:bridgelingo/features/auth/presentation/register_screen.dart';
import 'package:bridgelingo/features/auth/presentation/forgot_password_screen.dart';
import 'package:bridgelingo/features/auth/presentation/reset_password_screen.dart';
import 'package:bridgelingo/features/auth/presentation/welcome_screen.dart';
import 'package:bridgelingo/features/dashboard/dashboard_screen.dart';
import 'package:bridgelingo/features/lesson/lesson_list_screen.dart';
import 'package:bridgelingo/features/lesson/lesson_player_screen.dart';
import 'package:bridgelingo/features/dashboard/challenge_player_screen.dart';
import 'package:bridgelingo/features/dashboard/challenges_screen.dart';
import 'package:bridgelingo/features/dashboard/chat_screen.dart';
import 'package:bridgelingo/features/dashboard/edit_profile_screen.dart';
import 'package:bridgelingo/features/dashboard/profile_screen.dart';
import 'package:bridgelingo/features/settings/language_preferences_screen.dart';
import 'package:bridgelingo/features/settings/help_support_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // --- Public Routes ---
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // --- Authenticated Shell Route (Bottom Nav) ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // 1. Learn Branch (Home)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'course/:courseId',
                    builder: (context, state) {
                      final courseId = state.pathParameters['courseId']!;
                      final title = state.extra as String? ?? 'Lessons';
                      return LessonListScreen(courseId: courseId, courseTitle: title);
                    },
                  ),
                ],
              ),
            ],
          ),

          // 2. Challenges Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/challenges',
                builder: (context, state) => const ChallengesScreen(),
              ),
            ],
          ),

          // 3. Chat Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),

          // 4. Profile Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const LanguagePreferencesScreen(),
                  ),
                  GoRoute(
                    path: 'help',
                    builder: (context, state) => const HelpSupportScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // --- Full Screen Routes (Outside Shell) ---
      // Lesson Player should hide the nav bar
      GoRoute(
        path: '/lesson/:id',
        parentNavigatorKey: null, // Forces root navigator
        builder: (context, state) {
          final lessonId = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return LessonPlayerScreen(
            lessonId: lessonId,
            courseId: extra['courseId'] ?? '',
            isLastLesson: extra['isLastLesson'] ?? false,
          );
        },
      ),
      // Challenge Player should hide the nav bar
      GoRoute(
        path: '/challenge/play/:level',
        parentNavigatorKey: null,
        builder: (context, state) {
          final level = int.parse(state.pathParameters['level']!);
          return ChallengePlayerScreen(level: level);
        },
      ),
    ],
  );
});
