import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Kiểm tra nếu đang chạy trên web
    if (kIsWeb) {
      return 'http://localhost:5084';  // URL cho web
    } else {
      return 'http://10.0.2.2:5084';   // URL cho Android emulator
      // return 'http://10.150.0.126:5084';
    }
  }
}