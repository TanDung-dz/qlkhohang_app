import 'package:flutter/material.dart';
import '../../models/ChiTietKiemKe.dart';
import '../../services/chi_tiet_kiem_ke.dart';
import '../../services/kiem_ke.dart';


class ChiTietKiemKeScreen extends StatelessWidget {
  final int kiemKeId;

  const ChiTietKiemKeScreen({Key? key, required this.kiemKeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _kiemKeService = KiemKeService();
    final _chiTietKiemKeService = ChiTietKiemKeService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi Tiết Phiếu Kiểm Kê #$kiemKeId'),
      ),
      body: Column(
        children: [
          // Thông tin phiếu kiểm kê
          FutureBuilder<dynamic>(
            future: _kiemKeService.getInventoryCheckById(kiemKeId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('Không tìm thấy dữ liệu phiếu kiểm kê.'));
              }

              final kiemKe = snapshot.data;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mã phiếu: ${kiemKe['maKiemKe']}', style: const TextStyle(fontSize: 16)),
                    Text('Ngày kiểm kê: ${kiemKe['ngayKiemKe']}', style: const TextStyle(fontSize: 16)),
                    Text('Người tạo: ${kiemKe['tenNguoiDung'] ?? 'Không rõ'}', style: const TextStyle(fontSize: 16)),
                    const Divider(),
                  ],
                ),
              );
            },
          ),

          // Danh sách chi tiết sản phẩm kiểm kê
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _chiTietKiemKeService.getDetailsById(kiemKeId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có chi tiết sản phẩm.'));
                }

                final chiTietList = snapshot.data!
                    .map((e) => ChiTietKiemKeDto.fromJson(e))
                    .toList();

                return ListView.builder(
                  itemCount: chiTietList.length,
                  itemBuilder: (context, index) {
                    final chiTiet = chiTietList[index];
                    return _buildChiTietCard(chiTiet);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChiTietCard(ChiTietKiemKeDto chiTiet) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              chiTiet.tenSanPham ?? 'Không có tên',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Số lượng tồn: ${chiTiet.soLuongTon ?? 0}', style: const TextStyle(fontSize: 14)),
                Text('Số lượng thực tế: ${chiTiet.soLuongThucTe ?? 0}', style: const TextStyle(fontSize: 14)),
                Text('Nguyên nhân: ${chiTiet.nguyenNhan ?? 'Không có'}', style: const TextStyle(fontSize: 14)),
                Text('Trạng thái: ${_getTrangThaiText(chiTiet.trangThai)}',
                    style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey)),
              ],
            ),
          ),

          // Danh sách hình ảnh (nếu có)
          if (chiTiet.images != null && chiTiet.images!.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: chiTiet.images!.length,
                itemBuilder: (context, index) {
                  final imageUrl = chiTiet.images![index];
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: _buildImage(imageUrl),
                  );
                },
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Không có hình ảnh.', style: TextStyle(color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return Image.network(
      imageUrl,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 50),
    );
  }

  String _getTrangThaiText(int? trangThai) {
    switch (trangThai) {
      case 0:
        return 'Chưa kiểm kê';
      case 1:
        return 'Đã kiểm kê';
      case 2:
        return 'Đang xử lý';
      default:
        return 'Không xác định';
    }
  }
}
