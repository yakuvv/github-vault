import 'package:dio/dio.dart';
import '../models/credential.dart';
import 'storage_service.dart';

class ApiService {
  // FIXED: Pointing to your local backend terminal address
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/api'));
  final StorageService _storage = StorageService();

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ));
  }

  Future<List<Credential>> fetchCredentials(String type) async {
    final response = await _dio.get('/credentials', queryParameters: {'type': type});
    final List data = response.data['credentials'];
    return data.map((json) => Credential.fromJson(json)).toList();
  }

  Future<String> revealSecret(String id) async {
    final response = await _dio.post('/credentials/$id/reveal');
    return response.data['encryptedValue'];
  }

  Future<void> deleteCredential(String id) async {
    await _dio.delete('/credentials/$id');
  }
}