import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/PhieuNhapHang.dart';

class PhieuNhapService {
  final String _baseUrl = ApiConfig.baseUrl;

  // Lấy danh sách tất cả các phiếu nhập hàng
  Future<List<PhieuNhapHang>> getAllPhieuNhap() async {
    final url = Uri.parse('$_baseUrl/api/PhieuNhapHang/Get');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => PhieuNhapHang.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load PhieuNhapHang');
    }
  }

  Future<PhieuNhapHang> getPhieuNhapById(int id) async {
    final url = Uri.parse('$_baseUrl/api/PhieuNhapHang/GetById/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return PhieuNhapHang.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load PhieuNhapHang details');
    }
  }


  // Thêm phiếu nhập hàng
  Future<bool> createPhieuNhap(PhieuNhapHang phieuNhap) async {
    final url = Uri.parse('$_baseUrl/api/PhieuNhapHang/CreateImportOrder');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(phieuNhap.toJson()),
    );

    return response.statusCode == 201;
  }

  // Cập nhật phiếu nhập hàng
  Future<bool> updatePhieuNhap(int id, PhieuNhapHang phieuNhap) async {
    final url = Uri.parse('$_baseUrl/api/PhieuNhapHang/UpdateImportOrder/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(phieuNhap.toJson()),
    );

    return response.statusCode == 204;
  }

  // Xóa phiếu nhập hàng
  Future<bool> deletePhieuNhap(int id) async {
    final url = Uri.parse('$_baseUrl/api/PhieuNhapHang/DeleteImportOrder/$id');
    final response = await http.delete(url);

    return response.statusCode == 204;
  }


}
