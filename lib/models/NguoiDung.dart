class NguoiDung {
  int maNguoiDung;
  String? tenDangNhap;
  String? matKhau;
  String? tenNguoiDung;
  String? email;
  String? sdt;
  String? anh; // URL hoặc base64 của ảnh
  DateTime? ngayDk;
  int? quyen;
  bool? hide;

  NguoiDung({
    required this.maNguoiDung,
    this.tenDangNhap,
    this.matKhau,
    this.tenNguoiDung,
    this.email,
    this.sdt,
    this.anh,
    this.ngayDk,
    this.quyen,
    this.hide,
  });

  // Chuyển JSON sang đối tượng
  factory NguoiDung.fromJson(Map<String, dynamic> json) {
    return NguoiDung(
      maNguoiDung: json['maNguoiDung'],
      tenDangNhap: json['tenDangNhap'],
      matKhau: json['matKhau'],
      tenNguoiDung: json['tenNguoiDung'],
      email: json['email'],
      sdt: json['sdt'],
      anh: json['anh'],
      ngayDk: json['ngayDk'] != null ? DateTime.parse(json['ngayDk']) : null,
      quyen: json['quyen'],
      hide: json['hide'],
    );
  }

  // Chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'maNguoiDung': maNguoiDung,
      'tenDangNhap': tenDangNhap,
      'matKhau': matKhau,
      'tenNguoiDung': tenNguoiDung,
      'email': email,
      'sdt': sdt,
      'anh': anh,
      'ngayDk': ngayDk?.toIso8601String(),
      'quyen': quyen,
      'hide': hide,
    };
  }
}
