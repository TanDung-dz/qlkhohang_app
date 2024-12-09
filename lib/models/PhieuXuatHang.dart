class PhieuXuatHang {
  int? maPhieuXuatHang;
  DateTime? ngayXuat;
  double? phiVanChuyen;
  int? trangThai;
  bool? hide;

  int maNguoiDung;
  String? tenNguoiDung;

  int maKhachHang;
  String? tenKhachHang;

  PhieuXuatHang({
    this.maPhieuXuatHang,
    this.ngayXuat,
    this.phiVanChuyen,
    this.trangThai,
    this.hide,
    required this.maNguoiDung,
    this.tenNguoiDung,
    required this.maKhachHang,
    this.tenKhachHang,
  });

  // Factory constructor để chuyển đổi từ JSON sang đối tượng
  factory PhieuXuatHang.fromJson(Map<String, dynamic> json) {
    return PhieuXuatHang(
      maPhieuXuatHang: json['maPhieuXuatHang'],
      ngayXuat: json['ngayXuat'] != null ? DateTime.parse(json['ngayXuat']) : null,
      phiVanChuyen: (json['phiVanChuyen'] as num?)?.toDouble(),
      trangThai: json['trangThai'],
      hide: json['hide'],
      maNguoiDung: json['maNguoiDung'],
      tenNguoiDung: json['tenNguoiDung'],
      maKhachHang: json['maKhachHang'],
      tenKhachHang: json['tenKhachHang'],
    );
  }

  // Phương thức để chuyển đối tượng sang JSON
  Map<String, dynamic> toJson() {
    return {
      'maPhieuXuatHang': maPhieuXuatHang,
      'ngayXuat': ngayXuat?.toIso8601String(),
      'phiVanChuyen': phiVanChuyen,
      'trangThai': trangThai,
      'hide': hide,
      'maNguoiDung': maNguoiDung,
      'tenNguoiDung': tenNguoiDung,
      'maKhachHang': maKhachHang,
      'tenKhachHang': tenKhachHang,
    };
  }

  // Phương thức copyWith
  PhieuXuatHang copyWith({
    int? maPhieuXuatHang,
    DateTime? ngayXuat,
    double? phiVanChuyen,
    int? trangThai,
    bool? hide,
    int? maNguoiDung,
    String? tenNguoiDung,
    int? maKhachHang,
    String? tenKhachHang,
  }) {
    return PhieuXuatHang(
      maPhieuXuatHang: maPhieuXuatHang ?? this.maPhieuXuatHang,
      ngayXuat: ngayXuat ?? this.ngayXuat,
      phiVanChuyen: phiVanChuyen ?? this.phiVanChuyen,
      trangThai: trangThai ?? this.trangThai,
      hide: hide ?? this.hide,
      maNguoiDung: maNguoiDung ?? this.maNguoiDung,
      tenNguoiDung: tenNguoiDung ?? this.tenNguoiDung,
      maKhachHang: maKhachHang ?? this.maKhachHang,
      tenKhachHang: tenKhachHang ?? this.tenKhachHang,
    );
  }
}
