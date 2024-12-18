class KhachHang {
  int maKhachHang;
  String? tenKhachHang;
  String? soDt;
  String? diachi;
  String? email;
  int maLoai;
  bool? hide;
  String? tenLoai;

  KhachHang({
    required this.maKhachHang,
    this.tenKhachHang,
    this.soDt,
    this.diachi,
    this.email,
    required this.maLoai,
    this.hide,
    this.tenLoai,
  });

  factory KhachHang.fromJson(Map<String, dynamic> json) {
    return KhachHang(
      maKhachHang: json['maKhachHang'] as int,  // Ép kiểu rõ ràng
      tenKhachHang: json['tenKhachHang'] as String?,
      soDt: json['soDt'] as String?,
      diachi: json['diachi'] as String?,
      email: json['email'] as String?,
      maLoai: json['maLoai'] as int,  // Ép kiểu rõ ràng
      hide: json['hide'] as bool?,
      tenLoai: json['tenLoai'] as String?,
    );
  }

  // Phương thức toJson giữ nguyên
  Map<String, dynamic> toJson() {
    return {
      'maKhachHang': maKhachHang,
      'tenKhachHang': tenKhachHang,
      'soDt': soDt,
      'diachi': diachi,
      'email': email,
      'maLoai': maLoai,
      'hide': hide,
      'tenLoai': tenLoai,
    };
  }
}