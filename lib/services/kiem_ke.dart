import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Config/api_config.dart';


class KiemKeService {
  final String baseUrl = ApiConfig.baseUrl;

  // Lấy danh sách phiếu kiểm kê
  Future<List<dynamic>> getInventoryChecks() async {
    final response = await http.get(Uri.parse('$baseUrl/api/KiemKe/Get'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load inventory checks');
    }
  }

  // Lấy thông tin chi tiết của một phiếu kiểm kê
  Future<dynamic> getInventoryCheckById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/KiemKe/GetById/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load inventory check');
    }
  }

  // Tạo một phiếu kiểm kê mới
  Future<dynamic> createInventoryCheck(Map<String, dynamic> newInventoryCheckDto) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/KiemKe/CreateInventoryCheck'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(newInventoryCheckDto),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create inventory check');
    }
  }

  // Cập nhật thông tin của một phiếu kiểm kê
  Future<void> updateInventoryCheck(int id, Map<String, dynamic> updatedInventoryCheckDto) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/KiemKe/UpdateInventoryCheck/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(updatedInventoryCheckDto),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update inventory check');
    }
  }

  // Xóa một phiếu kiểm kê
  Future<void> deleteInventoryCheck(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/KiemKe/DeleteInventoryCheck/$id'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete inventory check');
    }
  }

  // Tìm kiếm phiếu kiểm kê
  Future<List<dynamic>> searchInventoryChecks(String keyword) async {
    final response = await http.get(Uri.parse('$baseUrl/api/KiemKe/Search/$keyword'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search inventory checks');
    }
  }
}
