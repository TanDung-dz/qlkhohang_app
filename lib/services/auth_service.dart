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

        // Xử lý URL ảnh
        if (userData['anh'] != null && !userData['anh'].startsWith('http')) {
          userData['anh'] = '$baseUrl${userData['anh']}';
        }

        _currentUser = NguoiDung.fromJson(userData);
        return _currentUser;
      } else {
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

  // Thêm phương thức để lấy thông tin người dùng chi tiết
  Future<NguoiDung?> getUserById(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/NguoiDung/GetById/$id');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);

        // Xử lý URL ảnh
        if (userData['anh'] != null && !userData['anh'].startsWith('http')) {
          userData['anh'] = '$baseUrl${userData['anh']}';
        }

        return NguoiDung.fromJson(userData);
      } else {
        throw Exception('Không thể lấy thông tin người dùng');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
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