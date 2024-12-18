import 'dart:convert'; // Để chuyển đổi giữa JSON và đối tượng Dart
import 'package:http/http.dart' as http; // Để thực hiện các yêu cầu HTTP
import '../Config/api_config.dart';
import '../Models/KhachHang.dart';

class KhachHangService {
  // Sử dụng ApiConfig.baseUrl để lấy URL đúng dựa trên môi trường
  static String get baseUrl => ApiConfig.baseUrl;

  // 1. Lấy danh sách khách hàng
  static Future<List<KhachHang>> getKhachHangList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/KhachHang/Get'));
      print('Raw response: ${response.body}'); // Debug response

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('Decoded data: $data'); // Debug decoded data

        final List<KhachHang> khachHangList = data.map((item) {
          print('Processing item: $item'); // Debug individual items
          return KhachHang.fromJson(item as Map<String, dynamic>);
        }).toList();

        print('Processed list: $khachHangList'); // Debug final list
        return khachHangList;
      } else {
        throw Exception('Failed to load KhachHang: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error in getKhachHangList: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error fetching KhachHang: $e');
    }
  }

  // 2. Thêm khách hàng
  static Future<KhachHang> addKhachHang(KhachHang khachHang) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/KhachHang/CreateCustomer'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(khachHang.toJson()),
      );

      if (response.statusCode == 201) {
        return KhachHang.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add KhachHang');
      }
    } catch (e) {
      throw Exception('Error adding KhachHang: $e');
    }
  }

  // 3. Sửa khách hàng
  static Future<KhachHang> updateKhachHang(KhachHang khachHang) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/KhachHang/UpdateCustomer/${khachHang.maKhachHang}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(khachHang.toJson()),
      );

      if (response.statusCode == 200) {
        return KhachHang.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update KhachHang');
      }
    } catch (e) {
      throw Exception('Error updating KhachHang: $e');
    }
  }

  // 4. Xóa khách hàng
  static Future<void> deleteKhachHang(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/KhachHang/DeleteCustomer/$id'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete KhachHang');
      }
    } catch (e) {
      throw Exception('Error deleting KhachHang: $e');
    }
  }
}
