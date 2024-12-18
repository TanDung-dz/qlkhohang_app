import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/ChiTietPhieuXuatHang.dart';

class ChiTietPhieuXuatHangService {
  final String _baseUrl = ApiConfig.baseUrl;

  // Lấy danh sách tất cả chi tiết phiếu xuất hàng
  Future<List<ChiTietPhieuXuatHang>> getAllDetails() async {
    final url = Uri.parse('$_baseUrl/api/ChiTietPhieuXuatHang/Get');
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
    final url = Uri.parse('$_baseUrl/api/ChiTietPhieuXuatHang/GetById/$id');
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
    final url = Uri.parse('$_baseUrl/api/ChiTietPhieuXuatHang/GetDetail/$phieuXuatId/$sanPhamId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ChiTietPhieuXuatHang.fromJson(data);
    } else {
      throw Exception('Failed to load detail for export ID: $phieuXuatId and product ID: $sanPhamId');
    }
  }

  // Tạo mới chi tiết phiếu xuất hàng
  Future<bool> createDetail(ChiTietPhieuXuatHang detail, {File? imageFile}) async {
    final url = Uri.parse('$_baseUrl/api/ChiTietPhieuXuatHang/uploadfile');
    final request = http.MultipartRequest('POST', url);

    request.fields['maPhieuXuatHang'] = detail.maPhieuXuatHang.toString();
    request.fields['maSanPham'] = detail.maSanPham.toString();
    request.fields['soLuong'] = detail.soLuong.toString();
    request.fields['donGiaXuat'] = detail.donGiaXuat.toString();
    request.fields['trangThai'] = detail.trangThai.toString();

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('img', imageFile.path),
      );
    }

    final response = await request.send();
    return response.statusCode == 201;
  }

  // Cập nhật chi tiết phiếu xuất hàng (bao gồm ảnh)
  Future<bool> updateDetail(int maPhieuXuat, int maSanPham, ChiTietPhieuXuatHang detail, {File? imageFile}) async {
    final url = Uri.parse('$_baseUrl/api/ChiTietPhieuXuatHang/UpdateDetail/$maPhieuXuat/$maSanPham');

    try {
      var request = http.MultipartRequest('PUT', url);

      request.fields.addAll({
        'maPhieuXuatHang': detail.maPhieuXuatHang.toString(),
        'maSanPham': detail.maSanPham.toString(),
        'soLuong': detail.soLuong.toString(),
        'trangThai': (detail.trangThai ?? 0).toString(),
        'tenSanPham': detail.tenSanPham ?? '',
      });

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('Images', imageFile.path),
        );
      }

      final response = await request.send();
      return response.statusCode == 204;
    } catch (e) {
      print("Error updating detail: $e");
      return false;
    }
  }

  // Xóa chi tiết phiếu xuất hàng
  Future<bool> deleteDetail(int maPhieuXuat, int maSanPham) async {
    final url = Uri.parse('$_baseUrl/api/ChiTietPhieuXuatHang/$maPhieuXuat/$maSanPham');
    final response = await http.delete(url);

    return response.statusCode == 204;
  }

  // Upload chi tiết phiếu xuất hàng với ảnh
  Future<bool> uploadChiTietWithImage(int maPhieuXuatHang, int maSanPham, File imageFile) async {
    final url = Uri.parse('$_baseUrl/api/ChiTietPhieuXuatHang/CreateDetailWithImage/uploadfile');
    final request = http.MultipartRequest('POST', url);

    request.fields['maPhieuXuatHang'] = maPhieuXuatHang.toString();
    request.fields['maSanPham'] = maSanPham.toString();

    request.files.add(
      await http.MultipartFile.fromPath('img', imageFile.path),
    );

    final response = await request.send();
    return response.statusCode == 200;
  }
}
