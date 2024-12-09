

class SanPham {
  final int maSanPham;
  final int maLoaiSanPham;
  final String? tenLoaiSanPham;
  final int maHangSanXuat;
  final String? tenHangSanXuat;
  final String? tenSanPham;
  final String? mota;
  final int? soLuong;
  final double? donGia;
  final double? khoiLuong;
  final String? kichThuoc;
  final String? xuatXu;
  final String? image;
  final String? maVach;
  final bool? hide;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;
  final bool? trangThai;

  SanPham({
    required this.maSanPham,
    required this.maLoaiSanPham,
    this.tenLoaiSanPham,
    required this.maHangSanXuat,
    this.tenHangSanXuat,
    this.tenSanPham,
    this.mota,
    this.soLuong,
    this.donGia,
    this.khoiLuong,
    this.kichThuoc,
    this.xuatXu,
    this.image,
    this.maVach,
    this.hide,
    this.ngayTao,
    this.ngayCapNhat,
    this.trangThai,
  });

  factory SanPham.fromJson(Map<String, dynamic> json) {
    return SanPham(
      maSanPham: json['maSanPham'] as int,
      maLoaiSanPham: json['maLoaiSanPham'] as int,
      tenLoaiSanPham: json['tenLoaiSanPham'] as String?,
      maHangSanXuat: json['maHangSanXuat'] as int,
      tenHangSanXuat: json['tenHangSanXuat'] as String?,
      tenSanPham: json['tenSanPham'] as String?,
      mota: json['mota'] as String?,
      soLuong: json['soLuong'] as int?,
      donGia: json['donGia'] != null ? (json['donGia'] as num).toDouble() : null,
      khoiLuong: json['khoiLuong'] != null ? (json['khoiLuong'] as num).toDouble() : null,
      kichThuoc: json['kichThuoc'] as String?,
      xuatXu: json['xuatXu'] as String?,
      image: json['image'] as String?,
      maVach: json['maVach'] as String?,
      hide: json['hide'] as bool?,
      ngayTao: json['ngayTao'] != null ? DateTime.parse(json['ngayTao']) : null,
      ngayCapNhat: json['ngayCapNhat'] != null ? DateTime.parse(json['ngayCapNhat']) : null,
      trangThai: json['trangThai'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maSanPham': maSanPham,
      'maLoaiSanPham': maLoaiSanPham,
      'tenLoaiSanPham': tenLoaiSanPham,
      'maHangSanXuat': maHangSanXuat,
      'tenHangSanXuat': tenHangSanXuat,
      'tenSanPham': tenSanPham,
      'mota': mota,
      'soLuong': soLuong,
      'donGia': donGia,
      'khoiLuong': khoiLuong,
      'kichThuoc': kichThuoc,
      'xuatXu': xuatXu,
      'image': image,
      'maVach': maVach,
      'hide': hide,
      'ngayTao': ngayTao?.toIso8601String(),
      'ngayCapNhat': ngayCapNhat?.toIso8601String(),
      'trangThai': trangThai,
    };
  }
}