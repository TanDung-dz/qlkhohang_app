class NhanVienKho {
  final int maNhanVienKho;
  final String? tenNhanVien;
  final String? email;
  final String? sdt;
  final String? namSinh; // Lưu dưới dạng String ISO-8601
  final String? hinhAnh; // URL hoặc base64 của ảnh
  final bool hide;

  const NhanVienKho({
    required this.maNhanVienKho,
    this.tenNhanVien,
    this.email,
    this.sdt,
    this.namSinh,
    this.hinhAnh,
    this.hide = false,
  });

  // Factory constructor để chuyển JSON thành đối tượng
  factory NhanVienKho.fromJson(Map<String, dynamic> json) {
    return NhanVienKho(
      maNhanVienKho: json['maNhanVienKho'] as int? ?? 0, // Mặc định là 0 nếu null
      tenNhanVien: json['tenNhanVien'] as String?, // Sử dụng as String?
      email: json['email'] as String?, // Sử dụng as String?
      sdt: json['sdt'] as String?, // Sử dụng as String?
      namSinh: json['namSinh'] != null ? json['namSinh'].toString() : null, // Đảm bảo trả về String
      hinhAnh: json['hinhAnh'] as String?, // Sử dụng as String?
      hide: json['hide'] as bool? ?? false, // Mặc định là false nếu null
    );
  }


  // Phương thức chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'maNhanVienKho': maNhanVienKho,
      'tenNhanVien': tenNhanVien,
      'email': email,
      'sdt': sdt,
      'namSinh': namSinh,
      'hinhAnh': hinhAnh,
      'hide': hide,
    };
  }

  // Phương thức copyWith để tạo bản sao đối tượng với các giá trị được thay đổi
  NhanVienKho copyWith({
    int? maNhanVienKho,
    String? tenNhanVien,
    String? email,
    String? sdt,
    String? namSinh,
    String? hinhAnh,
    bool? hide,
  }) {
    return NhanVienKho(
      maNhanVienKho: maNhanVienKho ?? this.maNhanVienKho,
      tenNhanVien: tenNhanVien ?? this.tenNhanVien,
      email: email ?? this.email,
      sdt: sdt ?? this.sdt,
      namSinh: namSinh ?? this.namSinh,
      hinhAnh: hinhAnh ?? this.hinhAnh,
      hide: hide ?? this.hide,
    );
  }
}
