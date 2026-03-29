import 'package:bridgelingo/features/dashboard/domain/course_model.dart';
import 'package:bridgelingo/features/dashboard/domain/certificate_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

final coursesProvider = FutureProvider<List<Course>>((ref) async {
  return ref.watch(courseRepositoryProvider).getCourses();
});

class CourseRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CourseRepository(this._firestore, this._auth);

  String? get _userId => _auth.currentUser?.uid;

  // --- READ all courses with user progress ---
  Future<List<Course>> getCourses() async {
    final snapshot = await _firestore.collection('courses').get();

    return Future.wait(snapshot.docs.map((doc) async {
      final data = doc.data();

      // Get lessons subcollection
      final lessonsSnap = await _firestore
          .collection('courses')
          .doc(doc.id)
          .collection('lessons')
          .orderBy('orderIndex')
          .get();

      final lessons = lessonsSnap.docs.map((l) {
        return Lesson(
          id: l.id,
          title: l['title'] ?? '',
          content: l['content'] ?? '',
          orderIndex: l['orderIndex'] ?? 0,
        );
      }).toList();

      // Get user progress for this course
      double progress = 0.0;
      if (_userId != null) {
        final progressDoc = await _firestore
            .collection('users')
            .doc(_userId)
            .collection('progress')
            .doc(doc.id)
            .get();
        if (progressDoc.exists) {
          progress = (progressDoc['progress'] as num?)?.toDouble() ?? 0.0;
        }
      }

      return Course(
        id: doc.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        level: data['level'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        lessons: lessons,
        progress: progress,
      );
    }).toList());
  }

  // --- CREATE a new course (admin use) ---
  Future<void> addCourse(Map<String, dynamic> courseData) async {
    await _firestore.collection('courses').add({
      ...courseData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- UPDATE course progress for current user ---
  Future<void> updateProgress(String courseId, double progress) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('progress')
        .doc(courseId)
        .set({
      'courseId': courseId,
      'progress': progress,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // --- DELETE user progress for a course ---
  Future<void> resetProgress(String courseId) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('progress')
        .doc(courseId)
        .delete();
  }

  // --- READ user certificates ---
  Future<List<Certificate>> getUserCertificates() async {
    if (_userId == null) return [];
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('certificates')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Certificate(
        id: doc.id,
        courseId: data['courseId'] ?? '',
        courseName: data['courseName'] ?? '',
        issuedAt: (data['issuedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  // --- CREATE certificate when course completed ---
  Future<void> generateCertificate(String courseId, String courseName) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('certificates')
        .add({
      'courseId': courseId,
      'courseName': courseName,
      'issuedAt': FieldValue.serverTimestamp(),
    });
  }

  // --- READ challenges from Firestore ---
  Future<List<Map<String, dynamic>>> getChallenges(int level) async {
    final snapshot = await _firestore
        .collection('challenges')
        .where('level', isEqualTo: level)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // --- CREATE challenge result ---
  Future<void> saveChallengeResult(int level, bool success) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('challenge_results')
        .add({
      'level': level,
      'success': success,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }
}