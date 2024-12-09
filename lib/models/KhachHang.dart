class KhachHang {
  int maKhachHang;
  String? tenKhachHang;
  String? soDt;
  String? diachi;
  String? email;
  int maLoai;
  bool? hide;
  String? tenLoai;

  // Constructor
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

  // Factory constructor để chuyển từ JSON sang đối tượng
  factory KhachHang.fromJson(Map<String, dynamic> json) {
    return KhachHang(
      maKhachHang: json['maKhachHang'],
      tenKhachHang: json['tenKhachHang'],
      soDt: json['soDt'],
      diachi: json['diachi'],
      email: json['email'],
      maLoai: json['maLoai'],
      hide: json['hide'],
      tenLoai: json['tenLoai'],
    );
  }

  // Phương thức để chuyển đối tượng thành JSON
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
