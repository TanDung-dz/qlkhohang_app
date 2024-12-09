// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';  // Thêm import để sử dụng DateFormat
// import '../../Dtos/PhieuNhapHangDto.dart';
// import '../../services/phieu_nhap_service.dart';
//
// class PhieuNhapFormScreen extends StatefulWidget {
//   final PhieuNhapHang? phieu;
//
//   PhieuNhapFormScreen({this.phieu});
//
//   @override
//   _PhieuNhapFormScreenState createState() => _PhieuNhapFormScreenState();
// }
//
// class _PhieuNhapFormScreenState extends State<PhieuNhapFormScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final service = PhieuNhapService();
//
//   late TextEditingController _maPhieuController;
//   late TextEditingController _nhaCungCapController;
//   late TextEditingController _ngayNhapController;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.phieu != null) {
//       _maPhieuController = TextEditingController(text: widget.phieu!.maPhieuNhapHang.toString());  // Đảm bảo maPhieuNhapHang là String
//       _nhaCungCapController = TextEditingController(text: widget.phieu!.tenNhaCungCap);
//       _ngayNhapController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(widget.phieu!.ngayNhap));  // Định dạng ngày
//     } else {
//       _maPhieuController = TextEditingController();
//       _nhaCungCapController = TextEditingController();
//       _ngayNhapController = TextEditingController();
//     }
//   }
//
//   @override
//   void dispose() {
//     _maPhieuController.dispose();
//     _nhaCungCapController.dispose();
//     _ngayNhapController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.phieu == null ? 'Thêm Phiếu Nhập' : 'Sửa Phiếu Nhập'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _maPhieuController,
//                 decoration: InputDecoration(labelText: 'Mã Phiếu Nhập'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Vui lòng nhập mã phiếu nhập';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _nhaCungCapController,
//                 decoration: InputDecoration(labelText: 'Nhà Cung Cấp'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Vui lòng nhập tên nhà cung cấp';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _ngayNhapController,
//                 decoration: InputDecoration(labelText: 'Ngày Nhập'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Vui lòng nhập ngày nhập';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     final phieuNhapData = {
//                       'maPhieuNhapHang': _maPhieuController.text,
//                       'tenNhaCungCap': _nhaCungCapController.text,
//                       'ngayNhap': _ngayNhapController.text,  // Cần định dạng ngày đúng
//                     };
//
//                     if (widget.phieu == null) {
//                       // Gọi phương thức tạo phiếu nhập mới
//                       await service.createPhieuNhap(phieuNhapData.cast<String, PhieuNhapHang>());
//                     } else {
//                       // Gọi phương thức cập nhật phiếu nhập
//                       await service.updatePhieuNhap(widget.phieu!.maPhieuNhapHang.toString() as int, phieuNhapData.cast<String, PhieuNhapHang>());
//                     }
//
//                     Navigator.pop(context);
//                   }
//                 },
//                 child: Text(widget.phieu == null ? 'Thêm Mới' : 'Cập Nhật'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
