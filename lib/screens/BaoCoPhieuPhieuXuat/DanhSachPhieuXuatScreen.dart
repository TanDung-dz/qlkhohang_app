import 'package:flutter/material.dart';
import '../../models/PhieuXuatHang.dart';
import '../../services/phieu_xuat_service.dart';
import 'ChiTietPhieuXuat.dart';
import 'SuaPhieuXuatScreen.dart';

class DanhSachPhieuXuatScreen extends StatefulWidget {
  @override
  _DanhSachPhieuXuatScreenState createState() => _DanhSachPhieuXuatScreenState();
}

class _DanhSachPhieuXuatScreenState extends State<DanhSachPhieuXuatScreen> {
  final PhieuXuatService _service = PhieuXuatService();
  List<PhieuXuatHang> _phieuXuatList = [];
  List<PhieuXuatHang> _filteredPhieuXuatList = [];
  bool _isLoading = true;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchPhieuXuatList();
  }

  Future<void> _fetchPhieuXuatList() async {
    try {
      final list = await _service.getAllPhieuXuat();
      setState(() {
        _phieuXuatList = list;
        _filteredPhieuXuatList = list; // Khởi tạo danh sách ban đầu
        _isLoading = false;
      });
    } catch (e) {
      _showErrorDialog('Không thể tải dữ liệu: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterPhieuXuatByDate() {
    if (_startDate != null && _endDate != null) {
      setState(() {
        _filteredPhieuXuatList = _phieuXuatList.where((phieu) {
          final ngayXuat = phieu.ngayXuat;
          if (ngayXuat == null) return false;
          return ngayXuat.isAfter(_startDate!) && ngayXuat.isBefore(_endDate!);
        }).toList();
      });
    }
  }

  Future<void> _deletePhieuXuat(int id) async {
    try {
      final success = await _service.deletePhieuXuat(id);
      if (success) {
        setState(() {
          _phieuXuatList.removeWhere((item) => item.maPhieuXuatHang == id);
          _filteredPhieuXuatList.removeWhere((item) => item.maPhieuXuatHang == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xóa phiếu xuất thành công')),
        );
      } else {
        _showErrorDialog('Không thể xóa phiếu xuất');
      }
    } catch (e) {
      _showErrorDialog('Lỗi khi xóa: $e');
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
        title: Text('Lỗi'),
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
        title: Text('Danh Sách Phiếu Xuất Hàng'),
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
                  onPressed: _filterPhieuXuatByDate,
                  child: Text('Tìm kiếm'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: _fetchPhieuXuatList,
              child: ListView.builder(
                itemCount: _filteredPhieuXuatList.length,
                itemBuilder: (context, index) {
                  final phieuXuat = _filteredPhieuXuatList[index];
                  return Card(
                    child: ListTile(
                      title: Text('Phiếu #${phieuXuat.maPhieuXuatHang}'),
                      subtitle: Text(
                        'Ngày xuất: ${phieuXuat.ngayXuat?.toLocal().toString().split('.')[0] ?? 'N/A'}\nKhách hàng: ${phieuXuat.tenKhachHang ?? 'Không rõ'}',
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChiTietPhieuXuatScreen(
                              phieuXuatId: phieuXuat.maPhieuXuatHang!, // Sử dụng đúng tham số phieuXuatId
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
                                  builder: (context) =>
                                      SuaPhieuXuatScreen(phieuXuat: phieuXuat),
                                ),
                              );
                              if (result == true) {
                                _fetchPhieuXuatList();
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletePhieuXuat(phieuXuat.maPhieuXuatHang!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
