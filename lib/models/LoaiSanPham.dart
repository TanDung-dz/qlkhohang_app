import 'package:qlkhohang_app/models/SanPham.dart';

class LoaiSanPham {
  final int maLoaiSanPham;
  final String? tenLoaiSanPham;
  final bool? hide;
  final List<SanPham> sanPhams;

  LoaiSanPham({
    required this.maLoaiSanPham,
    this.tenLoaiSanPham,
    this.hide,
    this.sanPhams = const [],
  });

  // Parse từ JSON
  factory LoaiSanPham.fromJson(Map<String, dynamic> json) {
    return LoaiSanPham(
      maLoaiSanPham: json['maLoaiSanPham'] as int,
      tenLoaiSanPham: json['tenLoaiSanPham'],
      hide: json['hide'] as bool?,
      sanPhams: json['sanPhams'] != null
          ? (json['sanPhams'] as List)
          .map((item) => SanPham.fromJson(item))
          .toList()
          : [],
    );
  }

  // Chuyển về JSON
  Map<String, dynamic> toJson() {
    return {
      'maLoaiSanPham': maLoaiSanPham,
      'tenLoaiSanPham': tenLoaiSanPham,
      'hide': hide,
      'sanPhams': sanPhams.map((sanPham) => sanPham.toJson()).toList(),
    };
  }
}
