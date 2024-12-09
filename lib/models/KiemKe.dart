class KiemKe {
  int maKiemKe;
  DateTime? ngayKiemKe;
  bool? hide;
  // Thông tin cơ bản về nhân viên kho
  int maNhanVienKho;
  String? tenNhanVienKho;

  // Constructor
  KiemKe({
    required this.maKiemKe,
    this.ngayKiemKe,
    this.hide,
    required this.maNhanVienKho,
    this.tenNhanVienKho,
  });

  // Factory constructor để chuyển từ JSON sang đối tượng
  factory KiemKe.fromJson(Map<String, dynamic> json) {
    return KiemKe(
      maKiemKe: json['maKiemKe'],
      ngayKiemKe: json['ngayKiemKe'] != null ? DateTime.parse(json['ngayKiemKe']) : null,
      hide: json['hide'],
      maNhanVienKho: json['maNhanVienKho'],
      tenNhanVienKho: json['tenNhanVienKho'],
    );
  }

  // Phương thức để chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'maKiemKe': maKiemKe,
      'ngayKiemKe': ngayKiemKe?.toIso8601String(),
      'hide': hide,
      'maNhanVienKho': maNhanVienKho,
      'tenNhanVienKho': tenNhanVienKho,
    };
  }
}
