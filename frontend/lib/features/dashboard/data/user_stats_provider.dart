import 'package:bridgelingo/core/network/dio_client.dart';
import 'package:bridgelingo/features/auth/presentation/auth_provider.dart';
import 'package:bridgelingo/features/dashboard/data/user_stats.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final userStatsProvider = FutureProvider.autoDispose<UserStats>((ref) async {
  final dio = ref.watch(dioProvider).dio;
  const storage = FlutterSecureStorage();
  
  final userId = await storage.read(key: 'user_id');
  if (userId == null) {
    throw Exception('User ID not found');
  }

  final response = await dio.get('/progress/stats/$userId');
  return UserStats.fromJson(response.data);
});
