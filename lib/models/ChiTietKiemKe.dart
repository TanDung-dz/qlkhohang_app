import 'dart:convert';

class ChiTietKiemKeDto {
  final int? maKiemKe;
  final int? maSanPham;
  final String? tenSanPham;
  final int? soLuongTon;
  final int? soLuongThucTe;
  final int? trangThai;
  final String? nguyenNhan;
  final String? anh;
  final String? anh2;
  final String? anh3;
  final String? anh4;
  final String? anh5;
  final String? anh6;
  final List<String>? images; // Danh sách URL ảnh tải lên

  ChiTietKiemKeDto({
    this.maKiemKe,
    this.maSanPham,
    this.tenSanPham,
    this.soLuongTon,
    this.soLuongThucTe,
    this.trangThai,
    this.nguyenNhan,
    this.anh,
    this.anh2,
    this.anh3,
    this.anh4,
    this.anh5,
    this.anh6,
    this.images,
  });

  factory ChiTietKiemKeDto.fromJson(Map<String, dynamic> json) {
    return ChiTietKiemKeDto(
      maKiemKe: json['maKiemKe'],
      maSanPham: json['maSanPham'],
      tenSanPham: json['tenSanPham'],
      soLuongTon: json['soLuongTon'],
      soLuongThucTe: json['soLuongThucTe'],
      trangThai: json['trangThai'],
      nguyenNhan: json['nguyenNhan'],
      anh: json['anh'],
      anh2: json['anh2'],
      anh3: json['anh3'],
      anh4: json['anh4'],
      anh5: json['anh5'],
      anh6: json['anh6'],
      images: List<String>.from(json['images'] ?? []),
    );
  }

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
      'anh2': anh2,
      'anh3': anh3,
      'anh4': anh4,
      'anh5': anh5,
      'anh6': anh6,
      'images': images,
    };
  }
}
