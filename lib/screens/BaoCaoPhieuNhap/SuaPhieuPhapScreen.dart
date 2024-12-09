import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../Models/NhaCungCap.dart';
import '../../models/PhieuNhapHang.dart';
import '../../models/ChiTietPhieuNhapHang.dart';
import '../../services/nha_cung_cap.dart';
import '../../services/phieu_nhap_service.dart';
import '../../services/chi_tiet_phieu_nhap_service.dart';

class SuaPhieuNhapScreen extends StatefulWidget {
  final PhieuNhapHang phieuNhap;

  const SuaPhieuNhapScreen({Key? key, required this.phieuNhap})
      : super(key: key);

  @override
  _SuaPhieuNhapScreenState createState() => _SuaPhieuNhapScreenState();
}

class _SuaPhieuNhapScreenState extends State<SuaPhieuNhapScreen> {
  final PhieuNhapService _service = PhieuNhapService();
  final ChiTietPhieuNhapHangService _chiTietService = ChiTietPhieuNhapHangService();

  late TextEditingController _phiVanChuyenController;
  late TextEditingController _tenNguoiDungController;

  late List<NhaCungCap> _nhaCungCapList = [];
  late List<ChiTietPhieuNhapHang> _chiTietList = [];
  NhaCungCap? _selectedNhaCungCap;

  bool _isLoading = true;
  bool _isChiTietLoading = true;
  String? _errorMessage;

  late DateTime _selectedDate;
  late int _selectedTrangThai;

  @override
  void initState() {
    super.initState();
    _phiVanChuyenController = TextEditingController(
        text: widget.phieuNhap.phiVanChuyen?.toString() ?? '');
    _tenNguoiDungController =
        TextEditingController(text: widget.phieuNhap.tenNguoiDung ?? '');
    _loadNhaCungCapList();
    _loadChiTietPhieuNhap();
    _selectedDate = widget.phieuNhap.ngayNhap ?? DateTime.now();
    _selectedTrangThai = widget.phieuNhap.trangThai ?? 0;
  }

  Future<void> _loadNhaCungCapList() async {
    try {
      final nhaCungCapList = await NhaCungCapService.getNhaCungCapList();
      setState(() {
        _nhaCungCapList = nhaCungCapList;
        _selectedNhaCungCap = _nhaCungCapList.firstWhere(
              (ncc) => ncc.maNhaCungCap == widget.phieuNhap.maNhaCungCap,
          orElse: () => _nhaCungCapList.first,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải danh sách nhà cung cấp: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadChiTietPhieuNhap() async {
    try {
      final chiTietList = await _chiTietService.getDetailsByPhieuNhapId(
          widget.phieuNhap.maPhieuNhapHang!);
      setState(() {
        _chiTietList = chiTietList;
        _isChiTietLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải chi tiết phiếu nhập: $e';
        _isChiTietLoading = false;
      });
    }
  }

  Future<void> _updatePhieuNhap() async {
    setState(() => _errorMessage = null);

    // Validate inputs
    if (_phiVanChuyenController.text.isEmpty ||
        double.tryParse(_phiVanChuyenController.text) == null ||
        double.parse(_phiVanChuyenController.text) < 0) {
      setState(() => _errorMessage = 'Phí vận chuyển không hợp lệ.');
      return;
    }

    if (_tenNguoiDungController.text
        .trim()
        .isEmpty) {
      setState(() => _errorMessage = 'Tên người dùng không được để trống.');
      return;
    }

    if (_selectedNhaCungCap == null) {
      setState(() => _errorMessage = 'Hãy chọn nhà cung cấp.');
      return;
    }

    try {
      final updatedPhieuNhap = PhieuNhapHang(
        maPhieuNhapHang: widget.phieuNhap.maPhieuNhapHang,
        ngayNhap: _selectedDate,
        phiVanChuyen: double.tryParse(_phiVanChuyenController.text),
        trangThai: _selectedTrangThai,
        hide: widget.phieuNhap.hide,
        maNguoiDung: widget.phieuNhap.maNguoiDung,
        tenNguoiDung: _tenNguoiDungController.text,
        maNhaCungCap: _selectedNhaCungCap!.maNhaCungCap,
        tenNhaCungCap: _selectedNhaCungCap!.tenNhaCungCap,
      );

      final success = await _service.updatePhieuNhap(
        updatedPhieuNhap.maPhieuNhapHang!,
        updatedPhieuNhap,
      );

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _errorMessage = 'Cập nhật thất bại.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Lỗi: $e');
    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _updateChiTietPhieuNhap(ChiTietPhieuNhapHang chiTiet) async {
    try {
      final success = await _chiTietService.updateDetail(
        chiTiet.maPhieuNhapHang, // ID phiếu nhập hàng
        chiTiet.maSanPham,       // ID sản phẩm
        chiTiet,                 // Chi tiết phiếu nhập hàng với ảnh mới
      );
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cập nhật chi tiết thất bại: ${chiTiet.tenSanPham}')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cập nhật thành công: ${chiTiet.tenSanPham}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi cập nhật chi tiết: $e')));
    }
  }

  Widget _buildChiTietRow(ChiTietPhieuNhapHang chiTiet) {
    final TextEditingController soLuongController =
    TextEditingController(text: chiTiet.soLuong?.toString());
    final TextEditingController donGiaNhapController =
    TextEditingController(text: chiTiet.donGiaNhap?.toString());

    File? selectedImage;

    Future<void> _pickImage() async {
      final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
          chiTiet.image = pickedFile.path;
        });
        // Cập nhật chi tiết phiếu nhập sau khi chọn ảnh
        _updateChiTietPhieuNhap(chiTiet);
      }
    }


    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sản Phẩm: ${chiTiet.tenSanPham ?? "Không xác định"}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: soLuongController,
              decoration: InputDecoration(
                labelText: 'Số Lượng',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                chiTiet.soLuong = int.tryParse(value);
                _updateChiTietPhieuNhap(chiTiet);
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: donGiaNhapController,
              decoration: InputDecoration(
                labelText: 'Đơn Giá Nhập',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                chiTiet.donGiaNhap = double.tryParse(value);
                _updateChiTietPhieuNhap(chiTiet);
              },
            ),
            const SizedBox(height: 8),
            if (selectedImage != null || chiTiet.image != null)
              Image.file(
                selectedImage ?? File(chiTiet.image!),
                height: 100,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Chọn Ảnh'),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa Phiếu Nhập Hàng'),
        backgroundColor: Colors.blue[600],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Card thông tin phiếu nhập
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_errorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      TextField(
                        controller: _phiVanChuyenController,
                        decoration: InputDecoration(
                          labelText: 'Phí Vận Chuyển',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.local_shipping),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'))
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _tenNguoiDungController,
                        decoration: InputDecoration(
                          labelText: 'Tên Người Dùng',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<NhaCungCap>(
                        value: _selectedNhaCungCap,
                        decoration: InputDecoration(
                          labelText: 'Nhà Cung Cấp',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.business),
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedNhaCungCap = newValue;
                            _errorMessage = null;
                          });
                        },
                        items: _nhaCungCapList.map((ncc) {
                          return DropdownMenuItem<NhaCungCap>(
                            value: ncc,
                            child: Text(ncc.tenNhaCungCap ?? 'Không tên'),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _selectDate,
                        child: Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 10),
                              Text('Ngày Nhập: ${_selectedDate.toString().split(' ')[0]}'),
                            ]
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedTrangThai,
                        decoration: InputDecoration(
                          labelText: 'Trạng Thái',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.report_problem),
                        ),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text(
                              'Chưa Hoàn Thành')),
                          DropdownMenuItem(value: 1, child: Text('Hoàn Thành')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedTrangThai = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          await _updatePhieuNhap();  // Update the receipt
                          for (var chiTiet in _chiTietList) {
                            await _updateChiTietPhieuNhap(chiTiet);  // Update each detail
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Cập nhật phiếu nhập và chi tiết thành công!')),
                          );
                          Navigator.of(context).pop(true);  // Optionally navigate back after updating
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cập nhật Phiếu Nhập và Chi Tiết',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),

                    ],
                  ),
                ),
              ),

              // Card chi tiết phiếu nhập
              const SizedBox(height: 16),
              Text(
                'Chi Tiết Phiếu Nhập',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600]
                ),
              ),
              const SizedBox(height: 8),
              _isChiTietLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _chiTietList.isEmpty
                  ? Center(
                child: Text(
                  'Không có chi tiết phiếu nhập',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
                  : Column(
                children: _chiTietList
                    .map((chiTiet) => _buildChiTietRow(chiTiet))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );}

  @override
  void dispose() {
    _phiVanChuyenController.dispose();
    _tenNguoiDungController.dispose();
    super.dispose();
  }
}