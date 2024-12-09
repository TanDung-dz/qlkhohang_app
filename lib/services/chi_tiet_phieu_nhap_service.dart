import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/ChiTietPhieuNhapHang.dart';

class ChiTietPhieuNhapHangService {
  final String _baseUrl = ApiConfig.baseUrl;

  // Lấy danh sách tất cả chi tiết phiếu nhập hàng
  Future<List<ChiTietPhieuNhapHang>> getAllDetails() async {
    final url = Uri.parse('$_baseUrl/api/ChiTietPhieuNhapHang/Get');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ChiTietPhieuNhapHang.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load details');
    }
  }

  // Lấy chi tiết phiếu nhập hàng theo mã phiếu
  Future<List<ChiTietPhieuNhapHang>> getDetailsByPhieuNhapId(int id) async {
    final url = Uri.parse('$_baseUrl/api/ChiTietPhieuNhapHang/GetById/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ChiTietPhieuNhapHang.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load details for receipt ID: $id');
    }
  }

  // Lấy chi tiết phiếu nhập hàng theo mã phiếu và mã sản phẩm
  Future<ChiTietPhieuNhapHang> getDetailByIds(int phieuNhapId, int sanPhamId) async {
    final url = Uri.parse('$_baseUrl/api/ChiTietPhieuNhapHang/GetDetail/$phieuNhapId/$sanPhamId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ChiTietPhieuNhapHang.fromJson(data);
    } else {
      throw Exception('Failed to load detail for receipt ID: $phieuNhapId and product ID: $sanPhamId');
    }
  }

  // Tạo mới chi tiết phiếu nhập hàng (bao gồm tải ảnh lên)
  Future<bool> createDetail(ChiTietPhieuNhapHang detail, {File? imageFile}) async {
    final url = Uri.parse('$_baseUrl/api/ChiTietPhieuNhapHang/uploadfile');
    final request = http.MultipartRequest('POST', url);

    request.fields['maPhieuNhapHang'] = detail.maPhieuNhapHang.toString();
    request.fields['maSanPham'] = detail.maSanPham.toString();
    request.fields['soLuong'] = detail.soLuong.toString();
    request.fields['donGiaNhap'] = detail.donGiaNhap.toString();
    request.fields['trangThai'] = detail.trangThai.toString();

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('img', imageFile.path),
      );
    }

    final response = await request.send();
    return response.statusCode == 201;
  }

  // Cập nhật chi tiết phiếu nhập hàng (bao gồm ảnh)
  Future<bool> updateDetail(int phieuNhapId, int sanPhamId, ChiTietPhieuNhapHang detail, {File? imageFile}) async {
    final url = Uri.parse('$_baseUrl/api/ChiTietPhieuNhapHang/$phieuNhapId/$sanPhamId');
    final request = http.MultipartRequest('PUT', url);

    request.fields['maPhieuNhapHang'] = detail.maPhieuNhapHang.toString();
    request.fields['maSanPham'] = detail.maSanPham.toString();
    request.fields['soLuong'] = detail.soLuong.toString();
    request.fields['donGiaNhap'] = detail.donGiaNhap.toString();
    request.fields['trangThai'] = detail.trangThai.toString();

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('img', imageFile.path),
      );
    }

    try {
      final response = await request.send();
      if (response.statusCode == 204) {
        return true; // Cập nhật thành công
      } else {
        // Lấy thông tin chi tiết về lỗi
        final responseBody = await response.stream.bytesToString();
        print("Error: ${response.statusCode} - ${responseBody}");
        return false;
      }
    } catch (e) {
      print("An error occurred: $e");
      return false;
    }
  }



  // Xóa chi tiết phiếu nhập hàng
  Future<bool> deleteDetail(int maPhieuNhap, int maSanPham) async {
    final url = Uri.parse('$_baseUrl/api/ChiTietPhieuNhapHang/$maPhieuNhap/$maSanPham');
    final response = await http.delete(url);

    return response.statusCode == 204;
  }

  // Thêm phương thức upload chi tiết phiếu nhập với ảnh
  Future<bool> uploadChiTietWithImage(int maPhieuNhapHang, int maSanPham, File imageFile) async {
    final url = Uri.parse('$_baseUrl/api/ChiTietPhieuNhapHang/CreateDetailWithImage/uploadfile');
    final request = http.MultipartRequest('POST', url);

    request.fields['maPhieuNhapHang'] = maPhieuNhapHang.toString();
    request.fields['maSanPham'] = maSanPham.toString();

    // Thêm ảnh vào request
    request.files.add(
      await http.MultipartFile.fromPath('img', imageFile.path),
    );

    final response = await request.send();

    // Kiểm tra phản hồi từ server
    return response.statusCode == 200;
  }
}
