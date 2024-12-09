class ChiTietPhieuNhapHang {
  int maPhieuNhapHang;
  int maSanPham;
  String? tenSanPham;
  int? soLuong;
  double? donGiaNhap;
  int? trangThai;
  String? image; // URL hoặc base64 cho ảnh
  // Trường img không có kiểu tương tự trong Dart, vì vậy cần xử lý file ảnh riêng nếu cần

  ChiTietPhieuNhapHang({
    required this.maPhieuNhapHang,
    required this.maSanPham,
    this.tenSanPham,
    this.soLuong,
    this.donGiaNhap,
    this.trangThai,
    this.image,
  });

  // Factory constructor để chuyển từ JSON sang đối tượng
  factory ChiTietPhieuNhapHang.fromJson(Map<String, dynamic> json) {
    return ChiTietPhieuNhapHang(
      maPhieuNhapHang: json['maPhieuNhapHang'],
      maSanPham: json['maSanPham'],
      tenSanPham: json['tenSanPham'],
      soLuong: json['soLuong'],
      donGiaNhap: (json['donGiaNhap'] as num?)?.toDouble(),
      trangThai: json['trangThai'],
      image: json['image'],
    );
  }

  // Phương thức để chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'maPhieuNhapHang': maPhieuNhapHang,
      'maSanPham': maSanPham,
      'tenSanPham': tenSanPham,
      'soLuong': soLuong,
      'donGiaNhap': donGiaNhap,
      'trangThai': trangThai,
      'image': image,
    };
  }
}
