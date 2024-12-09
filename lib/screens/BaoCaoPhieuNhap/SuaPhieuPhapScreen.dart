import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../Models/NhaCungCap.dart';
import '../../models/PhieuNhapHang.dart';
import '../../models/ChiTietPhieuNhapHang.dart';
import '../../services/nha_cung_cap.dart';
import '../../services/phieu_nhap_service.dart';
import '../../services/chi_tiet_phieu_nhap_service.dart';

class SuaPhieuNhapScreen extends StatefulWidget {
  final PhieuNhapHang phieuNhap;

  const SuaPhieuNhapScreen({Key? key, required this.phieuNhap}) : super(key: key);

  @override
  _SuaPhieuNhapScreenState createState() => _SuaPhieuNhapScreenState();
}

class _SuaPhieuNhapScreenState extends State<SuaPhieuNhapScreen> {
  final _phieuNhapService = PhieuNhapService();
  final _chiTietService = ChiTietPhieuNhapHangService();
  List<NhaCungCap> _nhaCungCapList = [];
  late PhieuNhapHang _currentPhieuNhap;
  List<ChiTietPhieuNhapHang> _chiTietList = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currentPhieuNhap = widget.phieuNhap;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final results = await Future.wait([
        NhaCungCapService.getNhaCungCapList(),
        _chiTietService.getDetailsByPhieuNhapId(_currentPhieuNhap.maPhieuNhapHang!)
      ]);

      setState(() {
        _nhaCungCapList = results[0] as List<NhaCungCap>;
        _chiTietList = results[1] as List<ChiTietPhieuNhapHang>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Lỗi tải dữ liệu: $e', isError: true);
    }
  }

  Future<void> _fetchChiTietPhieuNhap() async {
    try {
      final list = await _chiTietService.getDetailsByPhieuNhapId(_currentPhieuNhap.maPhieuNhapHang!);
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
        final success = await _chiTietService.uploadChiTietWithImage(
            _chiTietList[index].maPhieuNhapHang,
            _chiTietList[index].maSanPham,
            File(pickedFile.path)
        );

        if (success) {
          await _fetchChiTietPhieuNhap();
        } else {
          _showMessage('Lỗi upload ảnh', isError: true);
        }
      } catch (e) {
        _showMessage('Lỗi: $e', isError: true);
      }
    }
  }

  Widget _buildPhieuNhapForm() {
    return Form(
      key: _formKey,
      child: Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin phiếu nhập',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),

              // Dropdown nhà cung cấp
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Nhà cung cấp',
                  border: OutlineInputBorder(),
                ),
                value: _currentPhieuNhap.maNhaCungCap,
                items: _nhaCungCapList.map((supplier) {
                  return DropdownMenuItem<int>(
                    value: supplier.maNhaCungCap,
                    child: Text(supplier.tenNhaCungCap ?? 'Không có tên'),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    final supplier = _nhaCungCapList.firstWhere(
                            (s) => s.maNhaCungCap == newValue
                    );
                    setState(() {
                      _currentPhieuNhap = _currentPhieuNhap.copyWith(
                          maNhaCungCap: newValue,
                          tenNhaCungCap: supplier.tenNhaCungCap
                      );
                    });
                  }
                },
                validator: (value) => value == null ? 'Vui lòng chọn nhà cung cấp' : null,
              ),

              SizedBox(height: 16),

              // Trạng thái phiếu nhập
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Trạng thái',
                  border: OutlineInputBorder(),
                ),
                value: _currentPhieuNhap.trangThai,
                items: [
                  DropdownMenuItem(value: 0, child: Text('Chờ xử lý')),
                  DropdownMenuItem(value: 1, child: Text('Đang xử lý')),
                  DropdownMenuItem(value: 2, child: Text('Hoàn thành')),
                  DropdownMenuItem(value: 3, child: Text('Đã hủy')),
                ],
                onChanged: (value) {
                  setState(() {
                    _currentPhieuNhap = _currentPhieuNhap.copyWith(trangThai: value);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChiTietCard(ChiTietPhieuNhapHang chiTiet, int index) {
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
                      _chiTietList[index] = _chiTietList[index].copyWith(
                          tenSanPham: value
                      );
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
                    print("Changing quantity to: $value"); // Log để debug
                    if (value.isNotEmpty && int.tryParse(value) != null) {
                      setState(() {
                        _chiTietList[index] = _chiTietList[index].copyWith(
                            soLuong: int.parse(value)
                        );
                      });
                      print("Updated state quantity: ${_chiTietList[index].soLuong}"); // Log để debug
                    }
                  },
                ),

                SizedBox(height: 16),

                // Trạng thái chi tiết
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Trạng thái',
                    border: OutlineInputBorder(),
                  ),
                  value: chiTiet.trangThai ?? 0,
                  items: [
                    DropdownMenuItem(value: 0, child: Text('Chưa nhập')),
                    DropdownMenuItem(value: 1, child: Text('Đã nhập')),
                    DropdownMenuItem(value: 2, child: Text('Đang xử lý')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _chiTietList[index] = _chiTietList[index].copyWith(
                          trangThai: value
                      );
                    });
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

  Widget _buildImageSection(ChiTietPhieuNhapHang chiTiet, int index) {
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

  Future<void> _updatePhieuNhap() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      // Cập nhật phiếu nhập
      final updatePhieuNhapSuccess = await _phieuNhapService.updatePhieuNhap(
          _currentPhieuNhap.maPhieuNhapHang!,
          _currentPhieuNhap
      );

      if (!updatePhieuNhapSuccess) {
        _showMessage('Cập nhật phiếu nhập không thành công', isError: true);
        return;
      }

      // Cập nhật từng chi tiết
      bool hasError = false;
      for (var chiTiet in _chiTietList) {
        print("Updating detail - maSanPham: ${chiTiet.maSanPham}, soLuong: ${chiTiet.soLuong}");

        final success = await _chiTietService.updateDetail(
            chiTiet.maPhieuNhapHang,
            chiTiet.maSanPham,
            chiTiet
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
        title: Text('Sửa Phiếu Nhập #${_currentPhieuNhap.maPhieuNhapHang}'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _updatePhieuNhap,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildPhieuNhapForm(),
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