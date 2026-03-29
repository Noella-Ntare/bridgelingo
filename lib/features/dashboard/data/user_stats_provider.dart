import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  final challengeLevel = challengeSnap.docs.isEmpty ? 1 : challengeSnap.docs.length + 1;

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
