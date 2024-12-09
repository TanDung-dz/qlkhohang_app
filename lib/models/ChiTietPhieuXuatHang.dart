import 'dart:io';

class ChiTietPhieuXuatHang {
  int maSanPham;
  String? tenSanPham;
  int maPhieuXuatHang;
  int? soLuong;
  double? donGiaXuat;
  double? tienMat;
  double? nganHang;
  int? trangThai;
  String? image; // URL hoặc base64 của ảnh
  File? img; // Dùng để nhận file ảnh tải lên trong Flutter

  // Constructor
  ChiTietPhieuXuatHang({
    required this.maSanPham,
    required this.maPhieuXuatHang,
    this.tenSanPham,
    this.soLuong,
    this.donGiaXuat,
    this.tienMat,
    this.nganHang,
    this.trangThai,
    this.image,
    this.img,
  });

  // Factory constructor để chuyển từ JSON sang đối tượng
  factory ChiTietPhieuXuatHang.fromJson(Map<String, dynamic> json) {
    return ChiTietPhieuXuatHang(
      maSanPham: json['maSanPham'],
      maPhieuXuatHang: json['maPhieuXuatHang'],
      tenSanPham: json['tenSanPham'],
      soLuong: json['soLuong'],
      donGiaXuat: json['donGiaXuat'] != null ? (json['donGiaXuat'] as num).toDouble() : null,
      tienMat: json['tienMat'] != null ? (json['tienMat'] as num).toDouble() : null,
      nganHang: json['nganHang'] != null ? (json['nganHang'] as num).toDouble() : null,
      trangThai: json['trangThai'],
      image: json['image'],
    );
  }

  // Phương thức để chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'maSanPham': maSanPham,
      'maPhieuXuatHang': maPhieuXuatHang,
      'tenSanPham': tenSanPham,
      'soLuong': soLuong,
      'donGiaXuat': donGiaXuat,
      'tienMat': tienMat,
      'nganHang': nganHang,
      'trangThai': trangThai,
      'image': image,
    };
  }
}
