import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../Models/KhachHang.dart';
import '../../models/PhieuXuatHang.dart';
import '../../models/ChiTietPhieuXuatHang.dart';
import '../../services/khach_hang_service.dart';
import '../../services/phieu_xuat_service.dart';
import '../../services/chi_tiet_phieu_xuat_service.dart';

class SuaPhieuXuatScreen extends StatefulWidget {
  final PhieuXuatHang phieuXuat;

  const SuaPhieuXuatScreen({Key? key, required this.phieuXuat}) : super(key: key);

  @override
  _SuaPhieuXuatScreenState createState() => _SuaPhieuXuatScreenState();
}

class _SuaPhieuXuatScreenState extends State<SuaPhieuXuatScreen> {
  final _phieuXuatService = PhieuXuatService();
  final _chiTietService = ChiTietPhieuXuatHangService();
  final _formKey = GlobalKey<FormState>();

  late PhieuXuatHang _currentPhieuXuat;
  List<KhachHang> _khachHangList = [];
  List<ChiTietPhieuXuatHang> _chiTietList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentPhieuXuat = widget.phieuXuat;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final results = await Future.wait([
        KhachHangService.getKhachHangList(),
        _chiTietService.getDetailsByPhieuXuatId(_currentPhieuXuat.maPhieuXuatHang!)
      ]);

      setState(() {
        _khachHangList = results[0] as List<KhachHang>;
        _chiTietList = results[1] as List<ChiTietPhieuXuatHang>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Lỗi tải dữ liệu: $e', isError: true);
    }
  }

  Future<void> _pickImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        final success = await _chiTietService.uploadChiTietWithImage(
          _chiTietList[index].maPhieuXuatHang,  // Sử dụng maPhieuXuatHang
          _chiTietList[index].maSanPham,       // Sử dụng maSanPham
          File(pickedFile.path),               // File ảnh được chọn
        );

        if (success) {
          await _fetchChiTietPhieuXuat();      // Cập nhật dữ liệu chi tiết phiếu xuất
        } else {
          _showMessage('Lỗi upload ảnh', isError: true);
        }
      } catch (e) {
        _showMessage('Lỗi: $e', isError: true);
      }
    }
  }


  Future<void> _fetchChiTietPhieuXuat() async {
    try {
      final list = await _chiTietService.getDetailsByPhieuXuatId(_currentPhieuXuat.maPhieuXuatHang!);
      setState(() {
        _chiTietList = list;
      });
    } catch (e) {
      _showMessage('Lỗi tải chi tiết: $e', isError: true);
    }
  }

  Widget _buildPhieuXuatForm() {
    return Form(
      key: _formKey,
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin phiếu xuất',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Dropdown khách hàng
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Khách hàng',
                  border: OutlineInputBorder(),
                ),
                value: _currentPhieuXuat.maKhachHang,
                items: _khachHangList.map((khachHang) {
                  return DropdownMenuItem<int>(
                    value: khachHang.maKhachHang,
                    child: Text(khachHang.tenKhachHang ?? 'Không có tên'),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    final khachHang = _khachHangList.firstWhere((k) => k.maKhachHang == newValue);
                    setState(() {
                      _currentPhieuXuat = _currentPhieuXuat.copyWith(
                        maKhachHang: newValue,
                        tenKhachHang: khachHang.tenKhachHang,
                      );
                    });
                  }
                },
                validator: (value) => value == null ? 'Vui lòng chọn khách hàng' : null,
              ),

              const SizedBox(height: 16),

              // Dropdown trạng thái phiếu xuất
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Trạng thái',
                  border: OutlineInputBorder(),
                ),
                value: _currentPhieuXuat.trangThai,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Chờ xử lý')),
                  DropdownMenuItem(value: 1, child: Text('Đang xử lý')),
                  DropdownMenuItem(value: 2, child: Text('Hoàn thành')),
                  DropdownMenuItem(value: 3, child: Text('Đã hủy')),
                ],
                onChanged: (value) {
                  setState(() {
                    _currentPhieuXuat = _currentPhieuXuat.copyWith(trangThai: value);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChiTietCard(ChiTietPhieuXuatHang chiTiet, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chi tiết sản phẩm #${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),

                // Tên sản phẩm
                TextFormField(
                  initialValue: chiTiet.tenSanPham ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Tên sản phẩm',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _chiTietList[index] = chiTiet.copyWith(tenSanPham: value);
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Số lượng
                TextFormField(
                  initialValue: chiTiet.soLuong?.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Số lượng',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty && int.tryParse(value) != null) {
                      setState(() {
                        _chiTietList[index] = chiTiet.copyWith(soLuong: int.parse(value));
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          _buildImageSection(chiTiet, index),
        ],
      ),
    );
  }

  Widget _buildImageSection(ChiTietPhieuXuatHang chiTiet, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Hình ảnh sản phẩm',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        const SizedBox(height: 8),
        if (chiTiet.images != null && chiTiet.images!.isNotEmpty)
          Container(
            height: 120,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: chiTiet.images!.length,
              itemBuilder: (context, imgIndex) {
                return Stack(
                  children: [
                    Image.network(
                      chiTiet.images![imgIndex],
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            chiTiet.images!.removeAt(imgIndex);
                          });
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        Center(
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(index),
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Thêm ảnh'),
          ),
        ),
      ],
    );
  }

  Future<void> _updatePhieuXuat() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      final success = await _phieuXuatService.updatePhieuXuat(
        _currentPhieuXuat.maPhieuXuatHang!,
        _currentPhieuXuat,
      );

      if (!success) {
        throw Exception('Lỗi cập nhật phiếu xuất');
      }

      for (var chiTiet in _chiTietList) {
        final detailSuccess = await _chiTietService.updateDetail(
          chiTiet.maPhieuXuatHang!,
          chiTiet.maSanPham!,
          chiTiet,
        );

        if (!detailSuccess) {
          throw Exception('Lỗi cập nhật sản phẩm ${chiTiet.tenSanPham}');
        }
      }

      _showMessage('Cập nhật thành công');
      Navigator.of(context).pop(true);
    } catch (e) {
      _showMessage('Lỗi: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
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
        title: Text('Sửa Phiếu Xuất #${_currentPhieuXuat.maPhieuXuatHang}'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updatePhieuXuat,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildPhieuXuatForm(),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
