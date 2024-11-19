import 'dart:convert';

class NguoiDung {
  final int maNguoiDung;
  final String? tenDangNhap;
  final String? matKhau;
  final String? tenNguoiDung;
  final String? email;
  final int? sdt;
  final DateTime? ngayDk;
  final int? quyen;

  NguoiDung({
    required this.maNguoiDung,
    required this.tenDangNhap,
    required this.matKhau,
    required this.tenNguoiDung,
    required this.email,
    required this.sdt,
    required this.ngayDk,
    required this.quyen,
  });

  factory NguoiDung.fromJson(Map<String, dynamic> json) {
    return NguoiDung(
      maNguoiDung: json['maNguoiDung'] as int,
      tenDangNhap: json['tenDangNhap'],
      matKhau: json['matKhau'],
      tenNguoiDung: json['tenNguoiDung'],
      email: json['email'],
      sdt: json['sdt'],
      ngayDk: json['ngayDk'] != null ? DateTime.parse(json['ngayDk']) : null,
      quyen: json['quyen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maNguoiDung': maNguoiDung,
      'tenDangNhap': tenDangNhap,
      'matKhau': matKhau,
      'tenNguoiDung': tenNguoiDung,
      'email': email,
      'sdt': sdt,
      'ngayDk': ngayDk?.toIso8601String(),
      'quyen': quyen,
    };
  }
}
