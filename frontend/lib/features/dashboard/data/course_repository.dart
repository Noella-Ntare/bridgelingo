import 'dart:convert';
import 'package:bridgelingo/core/database/app_database.dart';
import 'package:bridgelingo/core/network/dio_client.dart';
import 'package:bridgelingo/features/dashboard/domain/certificate_model.dart';
import 'package:bridgelingo/features/dashboard/domain/course_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dbProvider = Provider((ref) => AppDatabase());

final courseRepositoryProvider = Provider((ref) => CourseRepository(
  ref.watch(dioProvider).dio,
  ref.watch(dbProvider),
));

final coursesProvider = FutureProvider<List<Course>>((ref) async {
  return ref.watch(courseRepositoryProvider).getCourses();
});

class CourseRepository {
  final Dio _dio;
  final AppDatabase _db;

  CourseRepository(this._dio, this._db);

  Dio get dio => _dio;

  Future<List<Course>> getCourses() async {
    try {
      // 1. Get UserId
      final userId = await const FlutterSecureStorage().read(key: 'user_id');
      if (userId == null) throw Exception("User not logged in");

      // 2. Attempt to fetch from Network
      final response = await _dio.get('/courses/my-progress/$userId');
      final courses = (response.data as List).map((e) => Course.fromJson(e)).toList();
      
      // 2. Save to Local Cache
      await _db.cacheCourses(response.data);
      
      return courses;
    } catch (e) {
      // 3. Fallback to Local Cache if Network Fails
      print('Network failed, loading from cache: $e');
      final cachedData = await _db.getCachedCourses();
      if (cachedData.isNotEmpty) {
        return cachedData.map((row) => Course(
          id: row['id'], 
          title: row['title'], 
          description: row['description'],
          level: 'OFFLINE',
          imageUrl: '',
          lessons: [] 
        )).toList();
      }
      rethrow; 
    }
  }

  Future<List<Certificate>> getUserCertificates(String userId) async {
    try {
      final response = await _dio.get('/certificates/user/$userId');
      return (response.data as List).map((e) => Certificate.fromJson(e)).toList();
    } catch (e) {
      return []; 
    }
  }

  Future<void> generateCertificate(String userId, String courseId) async {
    await _dio.post('/certificates/generate', data: {
      'userId': userId,
      'courseId': courseId,
    });
  }

  // --- Challenges ---
  
  Future<List<dynamic>> generateChallenge(int level) async {
    final response = await _dio.get('/challenges/generate/$level');
    return response.data as List;
  }

  Future<void> completeChallenge(String userId, int level, bool success) async {
    await _dio.post('/challenges/complete', data: {
      'userId': userId,
      'level': level,
      'success': success
    });
  }
}
