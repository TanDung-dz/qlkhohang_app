import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/NguoiDung.dart';
import '../config/api_config.dart';

class AuthService {
  String get baseUrl => ApiConfig.baseUrl;

  static NguoiDung? _currentUser;

  Future<NguoiDung?> login(String username, String password) async {
    try {
      // Tạo URL với query parameters
      final url = Uri.parse('$baseUrl/api/NguoiDung/Login/login')
          .replace(queryParameters: {
        'username': username,
        'password': password,
      });

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        _currentUser = NguoiDung.fromJson(userData);
        return _currentUser;
      } else {
        // Xử lý các trường hợp lỗi
        if (response.statusCode == 404) {
          throw Exception('Username không tồn tại.');
        } else if (response.statusCode == 401) {
          throw Exception('Mật khẩu không đúng.');
        }
        throw Exception('Đăng nhập thất bại: ${response.body}');
      }
    } catch (e) {
      throw Exception('Đăng nhập thất bại: $e');
    }
  }

  void logout() {
    _currentUser = null;
  }

  bool isLoggedIn() {
    return _currentUser != null;
  }

  bool isManager() {
    return _currentUser?.quyen == 1;
  }

  NguoiDung? get currentUser => _currentUser;
}