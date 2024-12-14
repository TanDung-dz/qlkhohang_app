import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../models/KhachHang.dart';
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
  late PhieuXuatHang _currentPhieuXuat;
  List<ChiTietPhieuXuatHang> _chiTietList = [];
  List<KhachHang> _khachHangList = []; // Danh sách khách hàng
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currentPhieuXuat = widget.phieuXuat;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // Tải chi tiết phiếu xuất
      final chiTietList = await _chiTietService.getDetailsByPhieuXuatId(_currentPhieuXuat.maPhieuXuatHang!);
      // Tải danh sách khách hàng
      final khachHangList = await KhachHangService.getKhachHangList(); // Gọi API để lấy khách hàng

      setState(() {
        _chiTietList = chiTietList;
        _khachHangList = khachHangList.cast<KhachHang>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Lỗi tải dữ liệu: $e', isError: true);
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

  Future<void> _pickImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        final success = await _chiTietService.uploadImage(
          _chiTietList[index].maPhieuXuatHang!,
          _chiTietList[index].maSanPham!,
          File(pickedFile.path),
          'image', // Assuming the field name is 'image'
        );

        if (success) {
          await _fetchChiTietPhieuXuat();
        } else {
          _showMessage('Lỗi upload ảnh', isError: true);
        }
      } catch (e) {
        _showMessage('Lỗi: $e', isError: true);
      }
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

              // Trạng thái phiếu xuất
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

              const SizedBox(height: 16),

              // Chọn khách hàng
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Khách hàng',
                  border: OutlineInputBorder(),
                ),
                value: _currentPhieuXuat.maKhachHang, // Hiện khách hàng hiện tại
                items: _khachHangList
                    .map((khachHang) => DropdownMenuItem(
                  value: khachHang.maKhachHang,
                  child: Text(khachHang.tenKhachHang ?? 'Không có tên'),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _currentPhieuXuat = _currentPhieuXuat.copyWith(maKhachHang: value);
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
                SizedBox(height: 16),

                // Tên sản phẩm
                TextFormField(
                  initialValue: chiTiet.tenSanPham ?? 'Không có tên',
                  decoration: InputDecoration(
                    labelText: 'Tên sản phẩm',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _chiTietList[index] = _chiTietList[index].copyWith(tenSanPham: value);
                    });
                  },
                ),

                SizedBox(height: 16),

                // Số lượng
                TextFormField(
                  initialValue: chiTiet.soLuong?.toString() ?? '0',
                  decoration: InputDecoration(
                    labelText: 'Số lượng',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty && int.tryParse(value) != null) {
                      setState(() {
                        _chiTietList[index] = _chiTietList[index].copyWith(soLuong: int.parse(value));
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          _buildImageSection(chiTiet, index),
          SizedBox(height: 16),
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
        SizedBox(height: 8),
        if (chiTiet.images != null && chiTiet.images!.isNotEmpty)
          Container(
            height: 120,
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: chiTiet.images!.length,
              itemBuilder: (context, imgIndex) {
                return Card(
                  margin: EdgeInsets.only(right: 8),
                  child: Stack(
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
                        child: Material(
                          color: Colors.transparent,
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _chiTietList[index].images!.removeAt(imgIndex);
                              });
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        SizedBox(height: 8),
        Center(
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(index),
            icon: Icon(Icons.add_photo_alternate),
            label: Text('Thêm ảnh'),
          ),
        ),
      ],
    );
  }

  Future<void> _updatePhieuXuat() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      // Cập nhật phiếu xuất
      final updatePhieuXuatSuccess = await _phieuXuatService.updatePhieuXuat(
        _currentPhieuXuat.maPhieuXuatHang!,
        _currentPhieuXuat,
      );

      if (!updatePhieuXuatSuccess) {
        _showMessage('Cập nhật phiếu xuất không thành công', isError: true);
        return;
      }

      // Cập nhật từng chi tiết
      bool hasError = false;
      for (var chiTiet in _chiTietList) {
        final success = await _chiTietService.updateDetail(
          chiTiet.maPhieuXuatHang!,
          chiTiet.maSanPham!,
          chiTiet,
        );

        if (!success) {
          hasError = true;
          _showMessage('Lỗi cập nhật sản phẩm ${chiTiet.tenSanPham ?? ''}', isError: true);
        }
      }

      if (!hasError) {
        _showMessage('Cập nhật thành công');
        Navigator.of(context).pop(true);
      }
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
        duration: Duration(seconds: 2),
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
              icon: Icon(Icons.save),
              onPressed: _updatePhieuXuat,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildPhieuXuatForm(),
            SizedBox(height: 16),
            // Danh sách chi tiết
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
