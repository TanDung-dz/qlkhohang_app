import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/ChiTietPhieuXuatHang.dart';

class ChiTietPhieuXuatHangService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<bool> uploadImage(int maPhieuXuatHang, int maSanPham, File imageFile, String imageField) async {
    final url = Uri.parse('$baseUrl/api/ChiTietPhieuXuatHang/UploadImage');
    final request = http.MultipartRequest('POST', url);

    // Gửi thông tin cơ bản
    request.fields['maPhieuXuatHang'] = maPhieuXuatHang.toString();
    request.fields['maSanPham'] = maSanPham.toString();

    // Thêm file ảnh
    request.files.add(
      await http.MultipartFile.fromPath(imageField, imageFile.path),
    );

    try {
      final response = await request.send();

      // Kiểm tra phản hồi từ server
      return response.statusCode == 200;
    } catch (e) {
      print('Error uploading image: $e');
      return false;
    }
  }

  // Lấy danh sách tất cả chi tiết phiếu xuất hàng
  Future<List<ChiTietPhieuXuatHang>> getAllDetails() async {
    final url = Uri.parse('$baseUrl/api/ChiTietPhieuXuatHang/Get');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ChiTietPhieuXuatHang.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load details');
    }
  }

  // Lấy chi tiết phiếu xuất hàng theo mã phiếu xuất
  Future<List<ChiTietPhieuXuatHang>> getDetailsByPhieuXuatId(int id) async {
    final url = Uri.parse('$baseUrl/api/ChiTietPhieuXuatHang/GetById/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ChiTietPhieuXuatHang.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load details for export ID: $id');
    }
  }

  // Lấy chi tiết phiếu xuất hàng theo mã phiếu xuất và mã sản phẩm
  Future<ChiTietPhieuXuatHang> getDetailByIds(int phieuXuatId, int sanPhamId) async {
    final url = Uri.parse('$baseUrl/api/ChiTietPhieuXuatHang/GetDetail/$phieuXuatId/$sanPhamId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ChiTietPhieuXuatHang.fromJson(data);
    } else {
      throw Exception('Failed to load detail for export ID: $phieuXuatId and product ID: $sanPhamId');
    }
  }

  // Tạo mới chi tiết phiếu xuất hàng
  Future<bool> createDetail(ChiTietPhieuXuatHang detail) async {
    final url = Uri.parse('$baseUrl/api/ChiTietPhieuXuatHang/Create');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(detail.toJson()),
    );

    return response.statusCode == 201;
  }

  // Cập nhật chi tiết phiếu xuất hàng
  Future<bool> updateDetail(int phieuXuatId, int sanPhamId, ChiTietPhieuXuatHang detail) async {
    final url = Uri.parse('$baseUrl/api/ChiTietPhieuXuatHang/Update/$phieuXuatId/$sanPhamId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(detail.toJson()),
    );

    return response.statusCode == 204;
  }

  // Xóa chi tiết phiếu xuất hàng
  Future<bool> deleteDetail(int phieuXuatId, int sanPhamId) async {
    final url = Uri.parse('$baseUrl/api/ChiTietPhieuXuatHang/Delete/$phieuXuatId/$sanPhamId');
    final response = await http.delete(url);

    return response.statusCode == 204;
  }
}
