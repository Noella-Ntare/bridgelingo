import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final dioProvider = Provider((ref) => DioClient());

class DioClient {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  // For Android Emulator use 10.0.2.2
  // For Real Device/Web use your machine IP or localhost
  static const String baseUrl = 'http://192.168.1.67:8081/api'; 

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
            print('RESPONSE[${response.statusCode}] => DATA: ${response.data}');
            return handler.next(response);
        },
        onError: (DioException e, handler) async {
          print('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
          print('ERROR MESSAGE: ${e.message}');
          print('ERROR RESPONSE: ${e.response?.data}');
          if (e.response?.statusCode == 401) {
            // Handle token expiration / logout logic here if needed
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
