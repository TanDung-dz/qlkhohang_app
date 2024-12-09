class Blog {
  int blogId;
  String? anh; // URL hoặc base64 của ảnh
  String? mota;
  String? link;
  bool? hide;
  int maNguoiDung;
  String? tenNguoiDung;

  // Constructor
  Blog({
    required this.blogId,
    this.anh,
    this.mota,
    this.link,
    this.hide,
    required this.maNguoiDung,
    this.tenNguoiDung,
  });

  // Factory constructor để chuyển từ JSON sang đối tượng
  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      blogId: json['blogId'],
      anh: json['anh'],
      mota: json['mota'],
      link: json['link'],
      hide: json['hide'],
      maNguoiDung: json['maNguoiDung'],
      tenNguoiDung: json['tenNguoiDung'],
    );
  }

  // Phương thức để chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'blogId': blogId,
      'anh': anh,
      'mota': mota,
      'link': link,
      'hide': hide,
      'maNguoiDung': maNguoiDung,
      'tenNguoiDung': tenNguoiDung,
    };
  }
}
