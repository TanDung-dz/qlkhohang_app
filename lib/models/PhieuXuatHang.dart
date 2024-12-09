class PhieuXuatHang {
  int maPhieuXuatHang;
  DateTime? ngayXuat;
  String? hinhThucThanhToan;
  String? phiVanChuyen;
  int? trangThai;
  bool? hide;

  // Thông tin cơ bản về người dùng và khách hàng
  int maNguoiDung;
  String? tenNguoiDung;

  int maKhachHang;
  String? tenKhachHang;

  // Constructor
  PhieuXuatHang({
    required this.maPhieuXuatHang,
    this.ngayXuat,
    this.hinhThucThanhToan,
    this.phiVanChuyen,
    this.trangThai,
    this.hide,
    required this.maNguoiDung,
    this.tenNguoiDung,
    required this.maKhachHang,
    this.tenKhachHang,
  });

  // Factory constructor để chuyển từ JSON sang đối tượng
  factory PhieuXuatHang.fromJson(Map<String, dynamic> json) {
    return PhieuXuatHang(
      maPhieuXuatHang: json['maPhieuXuatHang'],
      ngayXuat: json['ngayXuat'] != null ? DateTime.parse(json['ngayXuat']) : null,
      hinhThucThanhToan: json['hinhThucThanhToan'],
      phiVanChuyen: json['phiVanChuyen'],
      trangThai: json['trangThai'],
      hide: json['hide'],
      maNguoiDung: json['maNguoiDung'],
      tenNguoiDung: json['tenNguoiDung'],
      maKhachHang: json['maKhachHang'],
      tenKhachHang: json['tenKhachHang'],
    );
  }

  // Phương thức để chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'maPhieuXuatHang': maPhieuXuatHang,
      'ngayXuat': ngayXuat?.toIso8601String(),
      'hinhThucThanhToan': hinhThucThanhToan,
      'phiVanChuyen': phiVanChuyen,
      'trangThai': trangThai,
      'hide': hide,
      'maNguoiDung': maNguoiDung,
      'tenNguoiDung': tenNguoiDung,
      'maKhachHang': maKhachHang,
      'tenKhachHang': tenKhachHang,
    };
  }
}
