import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../Config/api_config.dart';


class ChiTietKiemKeService {
  // URL của API
  String baseUrl = ApiConfig.baseUrl;

  // Lấy danh sách tất cả chi tiết kiểm kê
  Future<List<dynamic>> getAllDetails() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/ChiTietKiemKe/Get'));
      if (response.statusCode == 200) {
        return json.decode(response.body); // Trả về danh sách chi tiết kiểm kê
      } else {
        throw Exception('Failed to load details');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  // Lấy chi tiết kiểm kê theo mã kiểm kê
  Future<List<dynamic>> getDetailsById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/ChiTietKiemKe/GetById/$id'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load details for id: $id');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  // Lấy chi tiết kiểm kê theo mã kiểm kê và mã sản phẩm
  Future<Map<String, dynamic>> getDetail(int kiemKeId, int sanPhamId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/ChiTietKiemKe/GetDetail/$kiemKeId/$sanPhamId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load detail for $kiemKeId and $sanPhamId');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  // Tạo mới một chi tiết kiểm kê
  Future<Map<String, dynamic>> createDetail({
    required int maSanPham,
    required int maKiemKe,
    required int soLuongTon,
    required int soLuongThucTe,
    required int trangThai,
    required String nguyenNhan,
    required List<XFile> images,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/api/ChiTietKiemKe/CreateDetail');
      var request = http.MultipartRequest('POST', uri);

      // Thêm các tham số
      request.fields['MaSanPham'] = maSanPham.toString();
      request.fields['MaKiemKe'] = maKiemKe.toString();
      request.fields['SoLuongTon'] = soLuongTon.toString();
      request.fields['SoLuongThucTe'] = soLuongThucTe.toString();
      request.fields['TrangThai'] = trangThai.toString();
      request.fields['NguyenNhan'] = nguyenNhan;

      // Thêm ảnh (nếu có)
      for (var image in images) {
        var pic = await http.MultipartFile.fromPath('Images', image.path);
        request.files.add(pic);
      }

      // Gửi yêu cầu
      var response = await request.send();

      if (response.statusCode == 201) {
        var res = await response.stream.bytesToString();
        return json.decode(res); // Trả về chi tiết vừa tạo
      } else {
        throw Exception('Failed to create detail');
      }
    } catch (e) {
      throw Exception('Error creating detail: $e');
    }
  }

  // Cập nhật chi tiết kiểm kê
  Future<void> updateDetail({
    required int kiemKeId,
    required int sanPhamId,
    required int soLuongTon,
    required int soLuongThucTe,
    required int trangThai,
    required String nguyenNhan,
    required List<XFile> images,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/api/ChiTietKiemKe/UpdateDetail/$kiemKeId/$sanPhamId');
      var request = http.MultipartRequest('PUT', uri);

      // Thêm các tham số
      request.fields['SoLuongTon'] = soLuongTon.toString();
      request.fields['SoLuongThucTe'] = soLuongThucTe.toString();
      request.fields['TrangThai'] = trangThai.toString();
      request.fields['NguyenNhan'] = nguyenNhan;

      // Thêm ảnh (nếu có)
      for (var image in images) {
        var pic = await http.MultipartFile.fromPath('Images', image.path);
        request.files.add(pic);
      }

      // Gửi yêu cầu
      var response = await request.send();

      if (response.statusCode != 204) {
        throw Exception('Failed to update detail');
      }
    } catch (e) {
      throw Exception('Error updating detail: $e');
    }
  }

  // Xóa chi tiết kiểm kê
  Future<void> deleteDetail(int kiemKeId, int sanPhamId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/ChiTietKiemKe/DeleteDetail/$kiemKeId/$sanPhamId'));
      if (response.statusCode != 204) {
        throw Exception('Failed to delete detail');
      }
    } catch (e) {
      throw Exception('Error deleting detail: $e');
    }
  }
}
