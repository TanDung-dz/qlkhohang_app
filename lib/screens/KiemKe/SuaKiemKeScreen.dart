import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../Models/NhanVienKho.dart';
import '../../models/ChiTietKiemKe.dart';
import '../../models/KiemKe.dart';
import '../../services/chi_tiet_kiem_ke.dart';
import '../../services/kiem_ke.dart';
import '../../services/nhan_vien_kho.dart';

class SuaKiemKeScreen extends StatefulWidget {
  final KiemKe kiemKe;

  const SuaKiemKeScreen({Key? key, required this.kiemKe}) : super(key: key);

  @override
  _SuaKiemKeScreenState createState() => _SuaKiemKeScreenState();
}

class _SuaKiemKeScreenState extends State<SuaKiemKeScreen> {
  final KiemKeService _kiemKeService = KiemKeService();
  final ChiTietKiemKeService _chiTietService = ChiTietKiemKeService();
  final NhanVienKhoService _nhanVienKhoService = NhanVienKhoService();

  late KiemKe _currentKiemKe;
  List<NhanVienKho> _nhanVienKhoList = [];
  List<ChiTietKiemKe> _chiTietList = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currentKiemKe = widget.kiemKe;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final results = await Future.wait([
        NhanVienKhoService.getNhanVienKhoList(),
        _chiTietService.getDetailsById(_currentKiemKe.maKiemKe!)
      ]);

      setState(() {
        _nhanVienKhoList = results[0] as List<NhanVienKho>;
        _chiTietList = results[1] as List<ChiTietKiemKe>;
        _isLoading = false;
      });
    } catch (e) {
      _showMessage('Lỗi tải dữ liệu: $e', isError: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        final success = await _chiTietService.uploadImageForDetail(
          _chiTietList[index].maKiemKe,
          _chiTietList[index].maSanPham,
          File(pickedFile.path),
        );

        if (success) {
          _showMessage('Tải ảnh thành công');
          await _reloadChiTietKiemKe();
        } else {
          _showMessage('Lỗi tải ảnh', isError: true);
        }
      } catch (e) {
        _showMessage('Lỗi: $e', isError: true);
      }
    }
  }

  Future<void> _reloadChiTietKiemKe() async {
    try {
      final list = await _chiTietService.getDetailsById(_currentKiemKe.maKiemKe!);
      setState(() {
        _chiTietList = list.cast<ChiTietKiemKe>();
      });
    } catch (e) {
      _showMessage('Lỗi làm mới chi tiết: $e', isError: true);
    }
  }

  Future<void> _updateChiTietKiemKe(ChiTietKiemKe chiTiet) async {
    try {
      setState(() => _isLoading = true);

      // Sử dụng phương thức updateDetail từ service
      await _chiTietService.updateDetail(
        kiemKeId: chiTiet.maKiemKe,
        sanPhamId: chiTiet.maSanPham,
        soLuongTon: chiTiet.soLuongTon ?? 0,
        soLuongThucTe: chiTiet.soLuongThucTe ?? 0,
        trangThai: chiTiet.trangThai ?? 0,
        nguyenNhan: chiTiet.nguyenNhan ?? '',
        images: [], // Nếu không có ảnh mới, truyền mảng rỗng
      );

      _showMessage('Cập nhật chi tiết thành công');
      await _reloadChiTietKiemKe();
    } catch (e) {
      _showMessage('Lỗi cập nhật chi tiết: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }
  Future<void> _updateKiemKe() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      await _kiemKeService.updateInventoryCheck(
        _currentKiemKe.maKiemKe!,
        _currentKiemKe.toJson(),
      );

      _showMessage('Cập nhật thành công');
      Navigator.of(context).pop(true);
    } catch (e) {
      _showMessage('Lỗi: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildKiemKeForm() {
    return Form(
      key: _formKey,
      child: Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thông Tin Phiếu Kiểm Kê',
                  style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Nhân Viên Kho',
                  border: OutlineInputBorder(),
                ),
                value: _currentKiemKe.maNhanVienKho,
                items: _nhanVienKhoList.map((nhanVien) {
                  return DropdownMenuItem<int>(
                    value: nhanVien.maNhanVienKho,
                    child: Text(nhanVien.tenNhanVien ?? 'Không có tên'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _currentKiemKe = _currentKiemKe.copyWith(maNhanVienKho: value);
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn nhân viên kho';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChiTietCard(ChiTietKiemKe chiTiet, int index) {
    final soLuongThucTeController = TextEditingController(
      text: chiTiet.soLuongThucTe?.toString() ?? '',
    );
    final nguyenNhanController = TextEditingController(
      text: chiTiet.nguyenNhan ?? '',
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sản phẩm: ${chiTiet.tenSanPham ?? "Không có tên"}'),
            SizedBox(height: 8),
            Text('Số lượng tồn: ${chiTiet.soLuongTon ?? 0}'),
            SizedBox(height: 8),
            TextFormField(
              controller: soLuongThucTeController,
              decoration: InputDecoration(
                labelText: 'Số lượng thực tế',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số lượng thực tế';
                }
                return null;
              },
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: nguyenNhanController,
              decoration: InputDecoration(
                labelText: 'Nguyên nhân (nếu có)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(index),
                  icon: Icon(Icons.add_a_photo),
                  label: Text('Chọn ảnh'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final updatedChiTiet = chiTiet.copyWith(
                      soLuongThucTe: int.tryParse(soLuongThucTeController.text) ?? chiTiet.soLuongThucTe,
                      nguyenNhan: nguyenNhanController.text,
                    );
                    _updateChiTietKiemKe(updatedChiTiet);
                  },
                  child: Text('Lưu Chi Tiết'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sửa Phiếu Kiểm Kê #${_currentKiemKe.maKiemKe}'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateKiemKe,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildKiemKeForm(),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _chiTietList.length,
              itemBuilder: (context, index) {
                return _buildChiTietCard(_chiTietList[index], index);
              },
            ),
          ],
        ),
      ),
    );
  }
}