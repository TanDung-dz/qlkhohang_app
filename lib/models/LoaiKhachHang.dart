import 'KhachHang.dart';

class LoaiKhachHang {
  int maLoai;
  String? tenLoai;
  double? chietKhauXuatHang;
  double? chiPhiVanChuyen;
  bool? hide;
  List<KhachHang> khachHangs;

  LoaiKhachHang({
    required this.maLoai,
    this.tenLoai,
    this.chietKhauXuatHang,
    this.chiPhiVanChuyen,
    this.hide,
    this.khachHangs = const [],
  });

  // Tạo đối tượng từ JSON
  factory LoaiKhachHang.fromJson(Map<String, dynamic> json) {
    return LoaiKhachHang(
      maLoai: json['maLoai'],
      tenLoai: json['tenLoai'],
      chietKhauXuatHang: json['chietKhauXuatHang'],
      chiPhiVanChuyen: json['chiPhiVanChuyen'],
      hide: json['hide'],
      khachHangs: json['khachHangs'] != null
          ? (json['khachHangs'] as List)
          .map((e) => KhachHang.fromJson(e))
          .toList()
          : [],
    );
  }

  // Chuyển đối tượng Dart sang JSON
  Map<String, dynamic> toJson() {
    return {
      'maLoai': maLoai,
      'tenLoai': tenLoai,
      'chietKhauXuatHang': chietKhauXuatHang,
      'chiPhiVanChuyen': chiPhiVanChuyen,
      'hide': hide,
      'khachHangs': khachHangs.map((e) => e.toJson()).toList(),
    };
  }
}
