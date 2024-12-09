import 'package:flutter/material.dart';
import '../../models/PhieuNhapHang.dart';
import '../../services/phieu_nhap_service.dart';

import 'ChiTietPhieuNhap.dart';
import 'SuaPhieuPhapScreen.dart';

class DanhSachPhieuNhapScreen extends StatefulWidget {
  @override
  _DanhSachPhieuNhapScreenState createState() => _DanhSachPhieuNhapScreenState();
}

class _DanhSachPhieuNhapScreenState extends State<DanhSachPhieuNhapScreen> {
  final PhieuNhapService _service = PhieuNhapService();
  List<PhieuNhapHang> _phieuNhapList = [];
  List<PhieuNhapHang> _filteredPhieuNhapList = [];
  bool _isLoading = true;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchPhieuNhapList();
  }

  Future<void> _fetchPhieuNhapList() async {
    try {
      final list = await _service.getAllPhieuNhap();
      setState(() {
        _phieuNhapList = list;
        _filteredPhieuNhapList = list; // Hiển thị danh sách ban đầu
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error fetching data: $e');
    }
  }

  void _filterPhieuNhapByDate() {
    if (_startDate != null && _endDate != null) {
      setState(() {
        _filteredPhieuNhapList = _phieuNhapList.where((phieu) {
          final ngayNhap = DateTime.parse(phieu.ngayNhap! as String); // Đảm bảo `ngayNhap` có định dạng ISO 8601
          return ngayNhap.isAfter(_startDate!) && ngayNhap.isBefore(_endDate!);
        }).toList();
      });
    }
  }

  Future<void> _deletePhieuNhap(int id) async {
    try {
      final success = await _service.deletePhieuNhap(id);
      if (success) {
        setState(() {
          _phieuNhapList.removeWhere((item) => item.maPhieuNhapHang == id);
        });
      } else {
        _showErrorDialog('Failed to delete');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách Phiếu Nhập Hàng'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text(_startDate == null
                        ? 'Chọn ngày bắt đầu'
                        : 'Từ: ${_startDate!.toLocal()}'.split(' ')[0]),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text(_endDate == null
                        ? 'Chọn ngày kết thúc'
                        : 'Đến: ${_endDate!.toLocal()}'.split(' ')[0]),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _filterPhieuNhapByDate,
                  child: Text('Tìm kiếm'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _filteredPhieuNhapList.length,
              itemBuilder: (context, index) {
                final phieuNhap = _filteredPhieuNhapList[index];
                return Card(
                  child: ListTile(
                    title: Text('Phiếu #${phieuNhap.maPhieuNhapHang}'),
                    subtitle: Text('Ngày Nhập: ${phieuNhap.ngayNhap}'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChiTietPhieuNhapScreen(
                            phieuNhapId: phieuNhap.maPhieuNhapHang!,
                            tenNguoiDung: phieuNhap.tenNguoiDung ?? 'Không rõ',
                          ),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SuaPhieuNhapScreen(phieuNhap: phieuNhap),
                              ),
                            );
                            if (result == true) {
                              _fetchPhieuNhapList();
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletePhieuNhap(phieuNhap.maPhieuNhapHang!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
