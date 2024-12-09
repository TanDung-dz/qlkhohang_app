import 'package:flutter/material.dart';
import 'package:qlkhohang_app/models/PhieuXuatHang.dart';
import '../../services/phieu_xuat_service.dart';
import 'SuaPhieuXuatScreen.dart';

class DanhSachPhieuXuatScreen extends StatefulWidget {
  @override
  _DanhSachPhieuXuatScreenState createState() => _DanhSachPhieuXuatScreenState();
}

class _DanhSachPhieuXuatScreenState extends State<DanhSachPhieuXuatScreen> {
  final PhieuXuatService _service = PhieuXuatService();
  List<PhieuXuatHang> _phieuXuatList = [];
  bool _isLoading = true;

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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error fetching data: $e');
    }
  }

  Future<void> _deletePhieuXuat(int id) async {
    try {
      final success = await _service.deletePhieuXuat(id);
      if (success) {
        setState(() {
          _phieuXuatList.removeWhere((item) => item.maPhieuXuatHang == id);
        });
      } else {
        _showErrorDialog('Failed to delete');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
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
        title: Text('Danh Sách Phiếu Xuất Hàng'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _phieuXuatList.length,
        itemBuilder: (context, index) {
          final phieuXuat = _phieuXuatList[index];
          return Card(
            child: ListTile(
              title: Text('Phiếu #${phieuXuat.maPhieuXuatHang}'),
              subtitle: Text('Ngày Xuất: ${phieuXuat.ngayXuat}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SuaPhieuXuatScreen(phieuXuat: phieuXuat),
                        ),
                      );
                      // Kiểm tra nếu sửa thành công, cập nhật danh sách
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Thêm chức năng thêm phiếu nhập ở đây
        },
      ),
    );
  }
}
