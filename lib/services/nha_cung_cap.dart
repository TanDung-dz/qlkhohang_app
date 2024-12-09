import 'dart:convert'; // Để chuyển đổi giữa JSON và đối tượng Dart
import 'package:http/http.dart' as http; // Để thực hiện các yêu cầu HTTP
import '../Config/api_config.dart';
import '../Models/NhaCungCap.dart';


class NhaCungCapService {
  // Sử dụng ApiConfig.baseUrl để lấy URL đúng dựa trên môi trường
  static String get baseUrl => ApiConfig.baseUrl;

  // 1. Lấy danh sách nhà cung cấp
  static Future<List<NhaCungCap>> getNhaCungCapList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/NhaCungCap/Get'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => NhaCungCap.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load NhaCungCap');
      }
    } catch (e) {
      throw Exception('Error fetching NhaCungCap: $e');
    }
  }

  // 2. Thêm nhà cung cấp
  static Future<NhaCungCap> addNhaCungCap(NhaCungCap nhaCungCap) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/NhaCungCap/CreateSupplier'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(nhaCungCap.toJson()),
      );

      if (response.statusCode == 201) {
        return NhaCungCap.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add NhaCungCap');
      }
    } catch (e) {
      throw Exception('Error adding NhaCungCap: $e');
    }
  }

  // 3. Sửa nhà cung cấp
  static Future<NhaCungCap> updateNhaCungCap(NhaCungCap nhaCungCap) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/NhaCungCap/CreateSupplier/${nhaCungCap.maNhaCungCap}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(nhaCungCap.toJson()),
      );

      if (response.statusCode == 200) {
        return NhaCungCap.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update NhaCungCap');
      }
    } catch (e) {
      throw Exception('Error updating NhaCungCap: $e');
    }
  }

  // 4. Xóa nhà cung cấp
  static Future<void> deleteNhaCungCap(int maNhaCungCap) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/NhaCungCap/DeleteSupplier/{id}/$maNhaCungCap'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete NhaCungCap');
      }
    } catch (e) {
      throw Exception('Error deleting NhaCungCap: $e');
    }
  }
}
