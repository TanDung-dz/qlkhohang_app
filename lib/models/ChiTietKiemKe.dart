import 'dart:io';

class ChiTietKiemKe {
  int maKiemKe;
  int maSanPham;
  String? tenSanPham;
  int? soLuongTon;
  int? soLuongThucTe;
  int? trangThai;
  String? nguyenNhan;
  String? anh; // URL hoặc base64 của ảnh
  File? img;  // Dùng để nhận file ảnh tải lên trong Flutter

  // Constructor
  ChiTietKiemKe({
    required this.maKiemKe,
    required this.maSanPham,
    this.tenSanPham,
    this.soLuongTon,
    this.soLuongThucTe,
    this.trangThai,
    this.nguyenNhan,
    this.anh,
    this.img,
  });

  // Factory constructor để chuyển từ JSON sang đối tượng
  factory ChiTietKiemKe.fromJson(Map<String, dynamic> json) {
    return ChiTietKiemKe(
      maKiemKe: json['maKiemKe'],
      maSanPham: json['maSanPham'],
      tenSanPham: json['tenSanPham'],
      soLuongTon: json['soLuongTon'],
      soLuongThucTe: json['soLuongThucTe'],
      trangThai: json['trangThai'],
      nguyenNhan: json['nguyenNhan'],
      anh: json['anh'],
    );
  }

  // Phương thức để chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'maKiemKe': maKiemKe,
      'maSanPham': maSanPham,
      'tenSanPham': tenSanPham,
      'soLuongTon': soLuongTon,
      'soLuongThucTe': soLuongThucTe,
      'trangThai': trangThai,
      'nguyenNhan': nguyenNhan,
      'anh': anh,
    };
  }
}
