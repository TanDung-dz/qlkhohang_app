import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Models/KhachHang.dart';
import '../../models/PhieuXuatHang.dart';
import '../../services/khach_hang_service.dart';
import '../../services/phieu_xuat_service.dart';

class SuaPhieuXuatScreen extends StatefulWidget {
  final PhieuXuatHang phieuXuat;

  const SuaPhieuXuatScreen({Key? key, required this.phieuXuat}) : super(key: key);

  @override
  _SuaPhieuXuatScreenState createState() => _SuaPhieuXuatScreenState();
}

class _SuaPhieuXuatScreenState extends State<SuaPhieuXuatScreen> {
  final PhieuXuatService _service = PhieuXuatService();

  late TextEditingController _phiVanChuyenController;
  late TextEditingController _tenNguoiDungController;

  late List<KhachHang> _khachHangList = [];
  KhachHang? _selectedKhachHang;

  bool _isLoading = true;
  String? _errorMessage;

  late DateTime _selectedDate;
  late int _selectedTrangThai;

  @override
  void initState() {
    super.initState();
    _phiVanChuyenController = TextEditingController(
        text: widget.phieuXuat.phiVanChuyen?.toString() ?? '');
    _tenNguoiDungController =
        TextEditingController(text: widget.phieuXuat.tenNguoiDung ?? '');
    _loadKhachHangList();
    _selectedDate = widget.phieuXuat.ngayXuat ?? DateTime.now();
    _selectedTrangThai = widget.phieuXuat.trangThai ?? 0;
  }

  Future<void> _loadKhachHangList() async {
    try {
      final khachHangList = await KhachHangService.getKhachHangList();
      setState(() {
        _khachHangList = khachHangList;
        _selectedKhachHang = _khachHangList.isNotEmpty
            ? _khachHangList.firstWhere(
              (kh) => kh.maKhachHang == widget.phieuXuat.maKhachHang,
          orElse: () => _khachHangList.first,
        )
            : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải danh sách khách hàng: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePhieuXuat() async {
    setState(() => _errorMessage = null);

    // Validate inputs
    if (_phiVanChuyenController.text.isEmpty ||
        double.tryParse(_phiVanChuyenController.text) == null ||
        double.parse(_phiVanChuyenController.text) < 0) {
      setState(() => _errorMessage = 'Phí vận chuyển không hợp lệ.');
      return;
    }

    if (_tenNguoiDungController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Tên người dùng không được để trống.');
      return;
    }

    if (_selectedKhachHang == null) {
      setState(() => _errorMessage = 'Hãy chọn khách hàng.');
      return;
    }

    try {
      final updatedPhieuXuat = PhieuXuatHang(
        maPhieuXuatHang: widget.phieuXuat.maPhieuXuatHang,
        ngayXuat: _selectedDate,
        phiVanChuyen: _phiVanChuyenController.text,
        trangThai: _selectedTrangThai,
        hide: widget.phieuXuat.hide,
        maNguoiDung: widget.phieuXuat.maNguoiDung,
        tenNguoiDung: _tenNguoiDungController.text,
        maKhachHang: _selectedKhachHang!.maKhachHang,
        tenKhachHang: _selectedKhachHang!.tenKhachHang,
        hinhThucThanhToan: widget.phieuXuat.hinhThucThanhToan,
      );

      final success = await _service.updatePhieuXuat(
        updatedPhieuXuat.maPhieuXuatHang,
        updatedPhieuXuat,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa Phiếu Xuất Hàng'),
        backgroundColor: Colors.blue[600],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
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
                  DropdownButtonFormField<KhachHang>(
                    value: _selectedKhachHang,
                    decoration: InputDecoration(
                      labelText: 'Khách Hàng',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.people),
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedKhachHang = newValue;
                        _errorMessage = null;
                      });
                    },
                    items: _khachHangList.map((kh) {
                      return DropdownMenuItem<KhachHang>(
                        value: kh,
                        child: Text(kh.tenKhachHang ?? 'Không tên'),
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
                        Text('Ngày Xuất: ${_selectedDate.toString().split(' ')[0]}'),
                      ],
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
                      DropdownMenuItem(value: 0, child: Text('Chưa Hoàn Thành')),
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
                    onPressed: _updatePhieuXuat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Lưu Thay Đổi',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phiVanChuyenController.dispose();
    _tenNguoiDungController.dispose();
    super.dispose();
  }
}