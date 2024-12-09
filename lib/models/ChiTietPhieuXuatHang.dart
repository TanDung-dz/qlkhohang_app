class ChiTietPhieuXuatHang {
  int maPhieuXuatHang;
  int maSanPham;
  String? tenSanPham;
  int? soLuong;
  double? donGiaXuat;
  int? trangThai;
  List<String>? images;

  ChiTietPhieuXuatHang({
    required this.maPhieuXuatHang,
    required this.maSanPham,
    this.tenSanPham,
    this.soLuong,
    this.donGiaXuat,
    this.trangThai,
    this.images,
  });

  // Phương thức copyWith
  ChiTietPhieuXuatHang copyWith({
    int? maPhieuXuatHang,
    int? maSanPham,
    String? tenSanPham,
    int? soLuong,
    double? donGiaXuat,
    int? trangThai,
    List<String>? images,
  }) {
    return ChiTietPhieuXuatHang(
      maPhieuXuatHang: maPhieuXuatHang ?? this.maPhieuXuatHang,
      maSanPham: maSanPham ?? this.maSanPham,
      tenSanPham: tenSanPham ?? this.tenSanPham,
      soLuong: soLuong ?? this.soLuong,
      donGiaXuat: donGiaXuat ?? this.donGiaXuat,
      trangThai: trangThai ?? this.trangThai,
      images: images ?? this.images,
    );
  }

  // Chuyển đổi từ JSON sang object
  factory ChiTietPhieuXuatHang.fromJson(Map<String, dynamic> json) {
    return ChiTietPhieuXuatHang(
      maPhieuXuatHang: json['maPhieuXuatHang'] as int,
      maSanPham: json['maSanPham'] as int,
      tenSanPham: json['tenSanPham'] as String?,
      soLuong: json['soLuong'] as int?,
      donGiaXuat: (json['donGiaXuat'] as num?)?.toDouble(),
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

  // Chuyển đổi từ object sang JSON
  Map<String, dynamic> toJson() {
    return {
      'maPhieuXuatHang': maPhieuXuatHang,
      'maSanPham': maSanPham,
      'tenSanPham': tenSanPham,
      'soLuong': soLuong,
      'donGiaXuat': donGiaXuat,
      'trangThai': trangThai,
      'images': images,
    };
  }
}
