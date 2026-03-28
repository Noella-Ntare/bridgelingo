import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
// Conditional import if needed, but for now we just wrap usage
import 'package:path_provider/path_provider.dart';

class AppDatabase {
  static Database? _database;

  // Simple in-memory cache for web
  final Map<String, dynamic> _webCache = {};

  Future<Database?> get database async {
    if (kIsWeb) return null; // No SQLite on web for this demo
    if (_database != null) return _database!;
    _database = await _initDB('bridgelingo.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path, 
      version: 1, 
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE courses (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      data TEXT NOT NULL
    )
    ''');
  }

  Future<void> cacheCourses(List<dynamic> coursesJson) async {
    if (kIsWeb) {
      // Basic web handling - just ignore or use in-memory if expanded
      return; 
    }
    
    final db = await database;
    if (db == null) return;

    final batch = db.batch();
    await db.delete('courses'); // Clear old cache
    
    for (var course in coursesJson) {
      batch.insert('courses', {
        'id': course['id'],
        'title': course['title'],
        'description': course['description'],
        'data': jsonEncode(course),
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedCourses() async {
    if (kIsWeb) {
      return [];
    }

    final db = await database;
    if (db == null) return [];

    final maps = await db.query('courses');
    return maps.map((row) => jsonDecode(row['data'] as String) as Map<String, dynamic>).toList();
  }
}

