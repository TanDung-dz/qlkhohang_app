// import 'package:flutter/material.dart';
// import '../../Dtos/PhieuNhapHangDto.dart';
//
// class PhieuNhapDetailScreen extends StatelessWidget {
//   final PhieuNhapHang phieu;
//
//   PhieuNhapDetailScreen({required this.phieu});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chi Tiết Phiếu Nhập'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Mã Phiếu: ${phieu.maPhieuNhapHang}', style: TextStyle(fontSize: 20)),
//             Text('Nhà Cung Cấp: ${phieu.tenNhaCungCap}', style: TextStyle(fontSize: 20)),
//             Text('Ngày Nhập: ${phieu.ngayNhap.toLocal()}', style: TextStyle(fontSize: 20)),
//             // Thêm thông tin chi tiết khác nếu cần
//           ],
//         ),
//       ),
//     );
//   }
// }
