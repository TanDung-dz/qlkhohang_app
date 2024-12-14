import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../models/ChiTietKiemKe.dart';
import '../../models/KiemKe.dart';
import '../../services/chi_tiet_kiem_ke.dart';
import '../../services/kiem_ke.dart';


class ThemKiemKeScreen extends StatefulWidget {
  @override
  _ThemKiemKeScreenState createState() => _ThemKiemKeScreenState();
}

class _ThemKiemKeScreenState extends State<ThemKiemKeScreen> {
  final _kiemKeService = KiemKeService();
  final _chiTietService = ChiTietKiemKeService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late KiemKe _newKiemKe;
  List<ChiTietKiemKe> _chiTietList = [];

  // Thêm controller để lưu thông tin form
  final TextEditingController _soLuongThucTeController = TextEditingController();
  final TextEditingController _nguyenNhanController = TextEditingController();
  List<XFile> _capturedImages = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo phiếu kiểm kê mới
    _newKiemKe = KiemKe(
      maKiemKe: 0, // Sẽ được server tạo
      ngayKiemKe: DateTime.now(),
      maNhanVienKho: 1, // Thay bằng ID nhân viên thực tế
      trangThai: 0,
    );
  }

  Future<void> _captureImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        setState(() {
          _capturedImages.add(photo);
        });
      }
    } catch (e) {
      _showMessage('Lỗi khi chụp ảnh: $e', isError: true);
    }
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _capturedImages.length + 1, // +1 cho nút thêm ảnh
      itemBuilder: (context, index) {
        if (index == _capturedImages.length) {
          // Nút thêm ảnh
          return InkWell(
            onTap: _captureImage,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add_a_photo, size: 40),
            ),
          );
        }

        // Hiển thị ảnh đã chụp
        return Stack(
          children: [
            Image.file(
              File(_capturedImages[index].path),
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _capturedImages.removeAt(index);
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createKiemKe() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      // Tạo phiếu kiểm kê mới
      final kiemKeResponse = await _kiemKeService.createInventoryCheck({
        'ngayKiemKe': _newKiemKe.ngayKiemKe?.toIso8601String(),
        'maNhanVienKho': _newKiemKe.maNhanVienKho,
        'trangThai': _newKiemKe.trangThai,
      });

      // Lấy mã kiểm kê mới được tạo
      final int maKiemKe = kiemKeResponse['maKiemKe'];

      // Tạo chi tiết kiểm kê với ảnh
      for (var chiTiet in _chiTietList) {
        await _chiTietService.createDetail(
          maSanPham: chiTiet.maSanPham!,
          maKiemKe: maKiemKe,
          soLuongTon: chiTiet.soLuongTon ?? 0,
          soLuongThucTe: int.parse(_soLuongThucTeController.text),
          trangThai: chiTiet.trangThai ?? 0,
          nguyenNhan: _nguyenNhanController.text,
          images: _capturedImages,
        );
      }

      _showMessage('Tạo phiếu kiểm kê thành công');
      Navigator.of(context).pop(true);
    } catch (e) {
      _showMessage('Lỗi khi tạo phiếu kiểm kê: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm Phiếu Kiểm Kê'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _createKiemKe,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form nhập thông tin
              TextFormField(
                controller: _soLuongThucTeController,
                decoration: InputDecoration(
                  labelText: 'Số lượng thực tế',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value?.isEmpty ?? true ? 'Vui lòng nhập số lượng' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nguyenNhanController,
                decoration: InputDecoration(
                  labelText: 'Nguyên nhân (nếu có)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),

              // Phần chụp và hiển thị ảnh
              Text(
                'Ảnh sản phẩm',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              _buildImageGrid(),
            ],
          ),
        ),
      ),
    );
  }
}