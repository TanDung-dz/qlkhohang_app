class ChiTietKiemKe {
  final int maKiemKe;
  final int maSanPham;
  final String? tenSanPham;
  final int? soLuongTon;
  final int? soLuongThucTe;
  final int? trangThai;
  final String? nguyenNhan;
  final List<String> images;

  ChiTietKiemKe({
    required this.maKiemKe,
    required this.maSanPham,
    this.tenSanPham,
    this.soLuongTon,
    this.soLuongThucTe,
    this.trangThai,
    this.nguyenNhan,
    List<String>? images,
  }) : images = images ?? []; // Khởi tạo mảng images mặc định là rỗng nếu null.

  // Phương thức copyWith
  ChiTietKiemKe copyWith({
    int? maKiemKe,
    int? maSanPham,
    String? tenSanPham,
    int? soLuongTon,
    int? soLuongThucTe,
    int? trangThai,
    String? nguyenNhan,
    List<String>? images,
  }) {
    return ChiTietKiemKe(
      maKiemKe: maKiemKe ?? this.maKiemKe,
      maSanPham: maSanPham ?? this.maSanPham,
      tenSanPham: tenSanPham ?? this.tenSanPham,
      soLuongTon: soLuongTon ?? this.soLuongTon,
      soLuongThucTe: soLuongThucTe ?? this.soLuongThucTe,
      trangThai: trangThai ?? this.trangThai,
      nguyenNhan: nguyenNhan ?? this.nguyenNhan,
      images: images ?? this.images,
    );
  }

  // Phương thức chuyển đổi từ JSON
  factory ChiTietKiemKe.fromJson(Map<String, dynamic> json) {
    return ChiTietKiemKe(
      maKiemKe: json['maKiemKe'] is int
          ? json['maKiemKe'] as int
          : int.tryParse(json['maKiemKe'].toString()) ?? 0,
      maSanPham: json['maSanPham'] is int
          ? json['maSanPham'] as int
          : int.tryParse(json['maSanPham'].toString()) ?? 0,
      tenSanPham: json['tenSanPham']?.toString(),
      soLuongTon: json['soLuongTon'] is int
          ? json['soLuongTon'] as int
          : int.tryParse(json['soLuongTon']?.toString() ?? ''),
      soLuongThucTe: json['soLuongThucTe'] is int
          ? json['soLuongThucTe'] as int
          : int.tryParse(json['soLuongThucTe']?.toString() ?? ''),
      trangThai: json['trangThai'] is int
          ? json['trangThai'] as int
          : int.tryParse(json['trangThai']?.toString() ?? ''),
      nguyenNhan: json['nguyenNhan']?.toString(),
      images: [
        json['image']?.toString(),
        json['image2']?.toString(),
        json['image3']?.toString(),
        json['image4']?.toString(),
        json['image5']?.toString(),
        json['image6']?.toString(),
      ].whereType<String>().where((url) => url.isNotEmpty).toList(), // Lọc URL không rỗng
    );
  }


  // Phương thức chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    return {
      'maKiemKe': maKiemKe,
      'maSanPham': maSanPham,
      'tenSanPham': tenSanPham,
      'soLuongTon': soLuongTon,
      'soLuongThucTe': soLuongThucTe,
      'trangThai': trangThai,
      'nguyenNhan': nguyenNhan,
      'images': images, // Chuyển cả danh sách images
    };
  }
}
