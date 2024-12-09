class PhieuNhapHang {
  int? maPhieuNhapHang;
  DateTime? ngayNhap;
  double? phiVanChuyen;
  int? trangThai;
  bool? hide;

  int maNguoiDung;
  String? tenNguoiDung;

  int maNhaCungCap;
  String? tenNhaCungCap;

  PhieuNhapHang({
    this.maPhieuNhapHang,
    this.ngayNhap,
    this.phiVanChuyen,
    this.trangThai,
    this.hide,
    required this.maNguoiDung,
    this.tenNguoiDung,
    required this.maNhaCungCap,
    this.tenNhaCungCap,
  });

  // Factory constructor để chuyển đổi từ JSON sang đối tượng
  factory PhieuNhapHang.fromJson(Map<String, dynamic> json) {
    return PhieuNhapHang(
      maPhieuNhapHang: json['maPhieuNhapHang'],
      ngayNhap: json['ngayNhap'] != null ? DateTime.parse(json['ngayNhap']) : null,
      phiVanChuyen: (json['phiVanChuyen'] as num?)?.toDouble(),
      trangThai: json['trangThai'],
      hide: json['hide'],
      maNguoiDung: json['maNguoiDung'],
      tenNguoiDung: json['tenNguoiDung'],
      maNhaCungCap: json['maNhaCungCap'],
      tenNhaCungCap: json['tenNhaCungCap'],
    );
  }

  // Phương thức để chuyển đối tượng sang JSON
  Map<String, dynamic> toJson() {
    return {
      'maPhieuNhapHang': maPhieuNhapHang,
      'ngayNhap': ngayNhap?.toIso8601String(),
      'phiVanChuyen': phiVanChuyen,
      'trangThai': trangThai,
      'hide': hide,
      'maNguoiDung': maNguoiDung,
      'tenNguoiDung': tenNguoiDung,
      'maNhaCungCap': maNhaCungCap,
      'tenNhaCungCap': tenNhaCungCap,
    };
  }

  // Phương thức copyWith
  PhieuNhapHang copyWith({
    int? maPhieuNhapHang,
    DateTime? ngayNhap,
    double? phiVanChuyen,
    int? trangThai,
    bool? hide,
    int? maNguoiDung,
    String? tenNguoiDung,
    int? maNhaCungCap,
    String? tenNhaCungCap,
  }) {
    return PhieuNhapHang(
      maPhieuNhapHang: maPhieuNhapHang ?? this.maPhieuNhapHang,
      ngayNhap: ngayNhap ?? this.ngayNhap,
      phiVanChuyen: phiVanChuyen ?? this.phiVanChuyen,
      trangThai: trangThai ?? this.trangThai,
      hide: hide ?? this.hide,
      maNguoiDung: maNguoiDung ?? this.maNguoiDung,
      tenNguoiDung: tenNguoiDung ?? this.tenNguoiDung,
      maNhaCungCap: maNhaCungCap ?? this.maNhaCungCap,
      tenNhaCungCap: tenNhaCungCap ?? this.tenNhaCungCap,
    );
  }
}
