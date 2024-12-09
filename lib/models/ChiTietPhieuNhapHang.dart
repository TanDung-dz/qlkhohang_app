class ChiTietPhieuNhapHang {
  int maPhieuNhapHang;
  int maSanPham;
  String? tenSanPham;
  int? soLuong;
  double? donGiaNhap;
  int? trangThai;
  List<String>? images;

  ChiTietPhieuNhapHang({
    required this.maPhieuNhapHang,
    required this.maSanPham,
    this.tenSanPham,
    this.soLuong,
    this.donGiaNhap,
    this.trangThai,
    this.images,
  });

  // Phương thức copyWith
  ChiTietPhieuNhapHang copyWith({
    int? maPhieuNhapHang,
    int? maSanPham,
    String? tenSanPham,
    int? soLuong,
    double? donGiaNhap,
    int? trangThai,
    List<String>? images,
  }) {
    return ChiTietPhieuNhapHang(
      maPhieuNhapHang: maPhieuNhapHang ?? this.maPhieuNhapHang,
      maSanPham: maSanPham ?? this.maSanPham,
      tenSanPham: tenSanPham ?? this.tenSanPham,
      soLuong: soLuong ?? this.soLuong,
      donGiaNhap: donGiaNhap ?? this.donGiaNhap,
      trangThai: trangThai ?? this.trangThai,
      images: images ?? this.images,
    );
  }

  // Hàm chuyển đổi từ JSON
  factory ChiTietPhieuNhapHang.fromJson(Map<String, dynamic> json) {
    return ChiTietPhieuNhapHang(
      maPhieuNhapHang: json['maPhieuNhapHang'] as int,
      maSanPham: json['maSanPham'] as int,
      tenSanPham: json['tenSanPham'] as String?,
      soLuong: json['soLuong'] as int?,
      donGiaNhap: (json['donGiaNhap'] as num?)?.toDouble(),
      trangThai: json['trangThai'] as int?,
      images: [
        json['image'] as String?,
        json['image2'] as String?,
        json['image3'] as String?,
        json['image4'] as String?,
        json['image5'] as String?,
        json['image6'] as String?,
      ].whereType<String>().toList(),
    );
  }
}
