class KiemKe {
  int? maKiemKe;
  DateTime? ngayKiemKe;
  int? trangThai;
  bool? hide;

  int maNhanVienKho;
  String? tenNhanVienKho;

  KiemKe({
    this.maKiemKe,
    this.ngayKiemKe,
    this.trangThai,
    this.hide,
    required this.maNhanVienKho,
    this.tenNhanVienKho,
  });

  // Factory constructor để chuyển đổi từ JSON sang đối tượng
  factory KiemKe.fromJson(Map<String, dynamic> json) {
    return KiemKe(
      maKiemKe: json['maKiemKe'],
      ngayKiemKe: json['ngayKiemKe'] != null ? DateTime.parse(json['ngayKiemKe']) : null,
      trangThai: json['trangThai'],
      hide: json['hide'],
      maNhanVienKho: json['maNhanVienKho'],
      tenNhanVienKho: json['tenNhanVienKho'],
    );
  }

  // Phương thức để chuyển đối tượng sang JSON
  Map<String, dynamic> toJson() {
    return {
      'maKiemKe': maKiemKe,
      'ngayKiemKe': ngayKiemKe?.toIso8601String(),
      'trangThai': trangThai,
      'hide': hide,
      'maNhanVienKho': maNhanVienKho,
      'tenNhanVienKho': tenNhanVienKho,
    };
  }

  // Phương thức copyWith
  KiemKe copyWith({
    int? maKiemKe,
    DateTime? ngayKiemKe,
    int? trangThai,
    bool? hide,
    int? maNhanVienKho,
    String? tenNhanVienKho,
  }) {
    return KiemKe(
      maKiemKe: maKiemKe ?? this.maKiemKe,
      ngayKiemKe: ngayKiemKe ?? this.ngayKiemKe,
      trangThai: trangThai ?? this.trangThai,
      hide: hide ?? this.hide,
      maNhanVienKho: maNhanVienKho ?? this.maNhanVienKho,
      tenNhanVienKho: tenNhanVienKho ?? this.tenNhanVienKho,
    );
  }
}