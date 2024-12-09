import 'package:flutter/material.dart';
import '../../models/PhieuNhapHang.dart';
import '../../services/phieu_nhap_service.dart';
import 'SuaPhieuPhapScreen.dart';


class DanhSachPhieuNhapScreen extends StatefulWidget {
  @override
  _DanhSachPhieuNhapScreenState createState() => _DanhSachPhieuNhapScreenState();
}

class _DanhSachPhieuNhapScreenState extends State<DanhSachPhieuNhapScreen> {
  final PhieuNhapService _service = PhieuNhapService();
  List<PhieuNhapHang> _phieuNhapList = [];
  bool _isLoading = true;

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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error fetching data: $e');
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _phieuNhapList.length,
        itemBuilder: (context, index) {
          final phieuNhap = _phieuNhapList[index];
          return Card(
            child: ListTile(
              title: Text('Phiếu #${phieuNhap.maPhieuNhapHang}'),
              subtitle: Text('Ngày Nhập: ${phieuNhap.ngayNhap}'),
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
                      // Kiểm tra nếu sửa thành công, cập nhật danh sách
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Thêm chức năng thêm phiếu nhập ở đây
        },
      ),
    );
  }
}
