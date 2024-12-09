import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:qlkhohang_app/models/PhieuXuatHang.dart';

import '../config/api_config.dart';


class PhieuXuatService {
  final String _baseUrl = ApiConfig.baseUrl;

  Future<List<PhieuXuatHang>> getAllPhieuXuat() async {
    try {
      final url = Uri.parse('$_baseUrl/api/PhieuXuatHang/Get');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('Response body: ${response.body}'); // In ra response để kiểm tra
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => PhieuXuatHang.fromJson(e)).toList();
      } else {
        throw HttpException('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error parsing data: $e'); // In ra lỗi chi tiết
      throw Exception('Failed to load PhieuXuatHang: $e');
    }
  }

  // Get by ID
  Future<PhieuXuatHang> getPhieuXuatById(int id) async {
    final url = Uri.parse('$_baseUrl/api/PhieuXuatHang/GetById/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return PhieuXuatHang.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load PhieuXuatHang');
    }
  }

// Search
  Future<List<PhieuXuatHang>> searchPhieuXuat(String keyword) async {
    final url = Uri.parse('$_baseUrl/api/PhieuXuatHang/Search/$keyword');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => PhieuXuatHang.fromJson(e)).toList();
    } else {
      throw Exception('Failed to search PhieuXuatHang');
    }
  }

  // Thêm phiếu Xuat hàng
  Future<bool> createPhieuXuat(PhieuXuatHang phieuXuat) async {
    final url = Uri.parse('$_baseUrl/api/PhieuXuatHang/CreateExportOrder');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(phieuXuat.toJson()),
    );

    return response.statusCode == 201;
  }

  // Cập nhật phiếu Xuat hàng
  Future<bool> updatePhieuXuat(int id, PhieuXuatHang phieuXuat) async {
    final url = Uri.parse('$_baseUrl/api/PhieuXuatHang/UpdateExportOrder/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(phieuXuat.toJson()),
    );

    return response.statusCode == 204;
  }

  // Xóa phiếu Xuat hàng
  Future<bool> deletePhieuXuat(int id) async {
    final url = Uri.parse('$_baseUrl/api/PhieuXuatHang/DeleteExportOrder/$id');
    final response = await http.delete(url);

    return response.statusCode == 204;
  }
}

