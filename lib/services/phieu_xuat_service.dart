import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qlkhohang_app/models/PhieuXuatHang.dart';

import '../config/api_config.dart';


class PhieuXuatService {
  final String _baseUrl = ApiConfig.baseUrl;

  // Lấy danh sách tất cả các phiếu Xuat hàng
  Future<List<PhieuXuatHang>> getAllPhieuXuat() async {
    final url = Uri.parse('$_baseUrl/api/PhieuXuatHang/Get');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => PhieuXuatHang.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load PhieuXuatHang');
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
