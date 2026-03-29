import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UserStats: Data model for user dashboard statistics
///
/// Aggregates user progress metrics:
/// - totalXp: Experience points earned
/// - lessonsCompleted: Number of finished lessons
/// - streakDays: Consecutive login days (motivation metric)
/// - challengeLevel: Current difficulty level achieved
class UserStats {
  final int totalXp;
  final int lessonsCompleted;
  final int streakDays;
  final int challengeLevel;

  UserStats({
    required this.totalXp,
    required this.lessonsCompleted,
    required this.streakDays,
    required this.challengeLevel,
  });
}

/// userStatsProvider: FutureProvider that fetches user stats from Firestore
///
/// Features:
/// - autoDispose: Cleans up when no longer watched (memory efficient)
/// - Real-time aggregation from Firestore collections
/// - Requires authenticated user (throws if not logged in)
/// - Used by DashboardScreen to show user progress summary
///
/// Architecture: Data layer provider that abstracts Firebase queries
/// Consumers use AsyncValue pattern to handle loading/error/data states
final userStatsProvider = FutureProvider.autoDispose<UserStats>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) throw Exception('Not logged in');

  final firestore = FirebaseFirestore.instance;

  // Count completed lessons
  final progressSnap = await firestore
      .collection('users')
      .doc(uid)
      .collection('progress')
      .get();

  final lessonsCompleted = progressSnap.docs.length;
  final totalXp = lessonsCompleted * 50;

  // Get challenge level
  final challengeSnap = await firestore
      .collection('users')
      .doc(uid)
      .collection('challenge_results')
      .where('success', isEqualTo: true)
      .get();

  final challengeLevel = challengeSnap.docs.isEmpty
      ? 1
      : challengeSnap.docs.length + 1;

  // Get user doc for streak
  final userDoc = await firestore.collection('users').doc(uid).get();
  final streakDays = (userDoc.data()?['streakDays'] as int?) ?? 1;

  return UserStats(
    totalXp: totalXp,
    lessonsCompleted: lessonsCompleted,
    streakDays: streakDays,
    challengeLevel: challengeLevel,
  );
});
