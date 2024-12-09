class NhaCungCap {
  int maNhaCungCap;
  String? tenNhaCungCap;
  String? diaChi;
  String? email;
  String? sdt;
  String? image; // URL hoặc base64 của ảnh
  bool? hide;

  NhaCungCap({
    required this.maNhaCungCap,
    this.tenNhaCungCap,
    this.diaChi,
    this.email,
    this.sdt,
    this.image,
    this.hide,
  });

  // Factory constructor để chuyển từ JSON sang đối tượng
  factory NhaCungCap.fromJson(Map<String, dynamic> json) {
    return NhaCungCap(
      maNhaCungCap: json['maNhaCungCap'],
      tenNhaCungCap: json['tenNhaCungCap'],
      diaChi: json['diaChi'],
      email: json['email'],
      sdt: json['sdt'],
      image: json['image'],
      hide: json['hide'],
    );
  }

  // Phương thức để chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'maNhaCungCap': maNhaCungCap,
      'tenNhaCungCap': tenNhaCungCap,
      'diaChi': diaChi,
      'email': email,
      'sdt': sdt,
      'image': image,
      'hide': hide,
    };
  }
}
