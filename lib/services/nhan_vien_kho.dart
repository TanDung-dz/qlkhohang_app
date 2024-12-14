import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Config/api_config.dart';
import '../Models/NhanVienKho.dart';

class NhanVienKhoService {
  // Lấy URL base từ ApiConfig
  static String get baseUrl => ApiConfig.baseUrl;

  // 1. Lấy danh sách nhân viên kho
  static Future<List<NhanVienKho>> getNhanVienKhoList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/NhanVienKho/Get'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => NhanVienKho.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load NhanVienKho list');
      }
    } catch (e) {
      throw Exception('Error fetching NhanVienKho: $e');
    }
  }

  // 2. Lấy thông tin chi tiết nhân viên kho theo ID
  static Future<NhanVienKho> getNhanVienKhoById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/NhanVienKho/GetById/$id'));

      if (response.statusCode == 200) {
        return NhanVienKho.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('NhanVienKho not found');
      } else {
        throw Exception('Failed to load NhanVienKho');
      }
    } catch (e) {
      throw Exception('Error fetching NhanVienKho: $e');
    }
  }

  // 3. Thêm nhân viên kho mới (bao gồm ảnh)
  static Future<NhanVienKho> addNhanVienKho(NhanVienKho nhanVienKho, String? imagePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/NhanVienKho/uploadfile'));

      // Thêm dữ liệu từ model
      request.fields['TenNhanVien'] = nhanVienKho.tenNhanVien ?? '';
      request.fields['Email'] = nhanVienKho.email ?? '';
      request.fields['Sdt'] = nhanVienKho.sdt ?? '';
      request.fields['NamSinh'] =
      request.fields['NamSinh'] = nhanVienKho.namSinh?.toString() ?? '';


      // Thêm file ảnh nếu có
      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('Img', imagePath));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        final respStr = await response.stream.bytesToString();
        return NhanVienKho.fromJson(json.decode(respStr));
      } else {
        throw Exception('Failed to add NhanVienKho');
      }
    } catch (e) {
      throw Exception('Error adding NhanVienKho: $e');
    }
  }

  // 4. Cập nhật nhân viên kho
  static Future<NhanVienKho> updateNhanVienKho(NhanVienKho nhanVienKho, String? imagePath) async {
    try {
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/api/NhanVienKho/${nhanVienKho.maNhanVienKho}'));

      // Thêm dữ liệu từ model
      request.fields['TenNhanVien'] = nhanVienKho.tenNhanVien ?? '';
      request.fields['Email'] = nhanVienKho.email ?? '';
      request.fields['Sdt'] = nhanVienKho.sdt ?? '';
      request.fields['NamSinh'] = nhanVienKho.namSinh?.toString() ?? '';


      // Thêm file ảnh mới nếu có
      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('Img', imagePath));
      }

      final response = await request.send();

      if (response.statusCode == 204) {
        return nhanVienKho; // Trả về model sau khi cập nhật
      } else {
        throw Exception('Failed to update NhanVienKho');
      }
    } catch (e) {
      throw Exception('Error updating NhanVienKho: $e');
    }
  }

  // 5. Xóa (ẩn) nhân viên kho theo ID
  static Future<void> deleteNhanVienKho(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/NhanVienKho/$id'));

      if (response.statusCode != 204) {
        throw Exception('Failed to delete NhanVienKho');
      }
    } catch (e) {
      throw Exception('Error deleting NhanVienKho: $e');
    }
  }

  // 6. Tìm kiếm nhân viên kho theo từ khóa
  static Future<List<NhanVienKho>> searchNhanVienKho(String keyword) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/NhanVienKho/Search/$keyword'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => NhanVienKho.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search NhanVienKho');
      }
    } catch (e) {
      throw Exception('Error searching NhanVienKho: $e');
    }
  }
}
