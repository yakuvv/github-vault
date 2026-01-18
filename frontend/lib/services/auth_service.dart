import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'storage_service.dart';

class AuthService extends ChangeNotifier {
  // These variables MUST be defined here inside the class
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3000/api'));
  final StorageService _storage = StorageService();
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  AuthService() {
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await _storage.getToken();
    if (token != null) {
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      if (response.data == null) return false;

      // Robust type checking to fix the "String is not a subtype of int" error
      final dynamic successValue = response.data['success'];
      bool isSuccess = false;

      if (successValue is bool) {
        isSuccess = successValue;
      } else if (successValue is String) {
        isSuccess = successValue.toLowerCase() == 'true';
      } else if (successValue is int) {
        isSuccess = successValue == 1 || successValue == 200;
      }

      if (isSuccess) {
        final token = response.data['token'];
        if (token != null) {
          await _storage.saveToken(token.toString());
          _isAuthenticated = true;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Login Error Detail: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    _isAuthenticated = false;
    notifyListeners();
  }
}