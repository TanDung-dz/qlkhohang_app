import 'package:flutter/material.dart';
import '../../models/NguoiDung.dart';
import '../../services/auth_service.dart';


class AccountInfoPage extends StatelessWidget {
  final AuthService _authService = AuthService();

  AccountInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    NguoiDung? currentUser = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Thông Tin Tài Khoản'),
      ),
      body: currentUser != null
          ? ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Ảnh đại diện
          CircleAvatar(
            radius: 80,
            backgroundImage: currentUser.anh != null
                ? NetworkImage(currentUser.anh!)
                : null,
            child: currentUser.anh == null
                ? Icon(Icons.person, size: 80)
                : null,
          ),
          SizedBox(height: 20),

          // Thông tin chi tiết
          _buildInfoTile('Tên Đăng Nhập', currentUser.tenDangNhap),
          _buildInfoTile('Tên Người Dùng', currentUser.tenNguoiDung),
          _buildInfoTile('Email', currentUser.email),
          _buildInfoTile('Số Điện Thoại', currentUser.sdt),
          _buildInfoTile('Ngày Đăng Ký',
              currentUser.ngayDk != null
                  ? currentUser.ngayDk.toString().split(' ')[0]
                  : 'Chưa có thông tin'),

          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _authService.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: Text('Đăng Xuất'),
          )
        ],
      )
          : Center(
        child: Text('Vui lòng đăng nhập'),
      ),
    );
  }

  // Hàm tạo tile thông tin
  Widget _buildInfoTile(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold)
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value ?? 'Chưa cập nhật'),
          ),
        ],
      ),
    );
  }
}