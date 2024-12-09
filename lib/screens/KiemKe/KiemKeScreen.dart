import 'package:flutter/material.dart';
import '../../models/KiemKe.dart';
import '../../services/kiem_ke.dart';
import 'ChiTietKiemKe.dart';

class KiemKeScreen extends StatefulWidget {
  @override
  _KiemKeScreenState createState() => _KiemKeScreenState();
}

class _KiemKeScreenState extends State<KiemKeScreen> {
  final KiemKeService _kiemKeService = KiemKeService();
  List<KiemKe> _kiemKeList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKiemKeList();
  }

  Future<void> _fetchKiemKeList() async {
    try {
      final response = await _kiemKeService.getInventoryChecks();
      setState(() {
        _kiemKeList = response.map<KiemKe>((json) => KiemKe.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Lỗi tải danh sách phiếu kiểm kê: $e', isError: true);
    }
  }

  Future<void> _deleteKiemKe(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận'),
        content: Text('Bạn có chắc muốn xóa phiếu kiểm kê này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _kiemKeService.deleteInventoryCheck(id);
      setState(() {
        _kiemKeList.removeWhere((item) => item.maKiemKe == id);
      });
      _showMessage('Xóa phiếu kiểm kê thành công');
    } catch (e) {
      _showMessage('Lỗi khi xóa: $e', isError: true);
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
        title: Text('Danh Sách Phiếu Kiểm Kê'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchKiemKeList,
        child: _kiemKeList.isEmpty
            ? Center(child: Text('Không có phiếu kiểm kê nào'))
            : ListView.builder(
          itemCount: _kiemKeList.length,
          itemBuilder: (context, index) {
            final kiemKe = _kiemKeList[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text('Phiếu #${kiemKe.maKiemKe}'),
                subtitle: Text('Ngày kiểm kê: ${kiemKe.ngayKiemKe}'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => ChiTietKiemKeScreen(kiemKeId: kiemKe.maKiemKe!),
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // IconButton(
                    //   icon: Icon(Icons.edit, color: Colors.blue),
                    //   onPressed: () async {
                    //     final result = await Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //         builder: (ctx) => SuaKiemKeScreen(kiemKe: kiemKe),
                    //       ),
                    //     );
                    //     if (result == true) {
                    //       _fetchKiemKeList();
                    //     }
                    //   },
                    // ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteKiemKe(kiemKe.maKiemKe!),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
