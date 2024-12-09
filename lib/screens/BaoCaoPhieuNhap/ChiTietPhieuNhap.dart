import 'package:flutter/material.dart';
import '../../models/PhieuNhapHang.dart';
import '../../models/ChiTietPhieuNhapHang.dart';
import '../../services/chi_tiet_phieu_nhap_service.dart';
import '../../services/phieu_nhap_service.dart';

class ChiTietPhieuNhapScreen extends StatelessWidget {
  final int phieuNhapId;
  final String tenNguoiDung;

  const ChiTietPhieuNhapScreen({
    Key? key,
    required this.phieuNhapId,
    required this.tenNguoiDung,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _phieuNhapService = PhieuNhapService();
    final _chiTietService = ChiTietPhieuNhapHangService();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi Tiết Phiếu Nhập #$phieuNhapId',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.deepPurple.shade100,
            ],
          ),
        ),
        child: Column(
          children: [
            // Thông tin phiếu nhập
            FutureBuilder<PhieuNhapHang>(
              future: _phieuNhapService.getPhieuNhapById(phieuNhapId),
              builder: (context, snapshotPhieu) {
                if (snapshotPhieu.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    ),
                  );
                } else if (snapshotPhieu.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshotPhieu.error}',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  );
                } else if (!snapshotPhieu.hasData) {
                  return const Center(
                    child: Text('Không tìm thấy dữ liệu phiếu nhập.'),
                  );
                }

                final phieuNhap = snapshotPhieu.data!;
                return Container(
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.shade100,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.person, 'Người dùng', phieuNhap.tenNguoiDung ?? 'N/A'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.business, 'Nhà cung cấp', phieuNhap.tenNhaCungCap ?? 'N/A'),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                          Icons.calendar_today,
                          'Ngày nhập',
                          phieuNhap.ngayNhap?.toString().split('.')[0] ?? 'N/A'
                      ),
                    ],
                  ),
                );
              },
            ),
            // Danh sách chi tiết sản phẩm
            Expanded(
              child: FutureBuilder<List<ChiTietPhieuNhapHang>>(
                future: _chiTietService.getDetailsByPhieuNhapId(phieuNhapId),
                builder: (context, snapshotChiTiet) {
                  if (snapshotChiTiet.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                      ),
                    );
                  } else if (snapshotChiTiet.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshotChiTiet.error}',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    );
                  } else if (!snapshotChiTiet.hasData || snapshotChiTiet.data!.isEmpty) {
                    return const Center(
                      child: Text('Không có chi tiết sản phẩm.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshotChiTiet.data!.length,
                    itemBuilder: (context, index) {
                      final chiTiet = snapshotChiTiet.data![index];
                      return _buildChiTietCard(chiTiet);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChiTietCard(ChiTietPhieuNhapHang chiTiet) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.shade100,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              chiTiet.tenSanPham ?? 'Không có tên',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade800,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Số lượng', '${chiTiet.soLuong ?? 0}'),
                  _buildDetailRow(
                      'Trạng thái',
                      _getTrangThaiText(chiTiet.trangThai),
                      color: _getTrangThaiColor(chiTiet.trangThai)
                  ),
                ],
              ),
            ),
          ),
          // Danh sách hình ảnh
          if (chiTiet.images != null && chiTiet.images!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
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
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Không có hình ảnh.',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.error, size: 50, color: Colors.red),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple.shade200),
              ),
            );
          },
        ),
      ),
    );
  }

  // Hàm chuyển đổi trạng thái thành text
  String _getTrangThaiText(int? trangThai) {
    switch (trangThai) {
      case 0:
        return 'Chưa nhập';
      case 1:
        return 'Đã nhập';
      case 2:
        return 'Đang xử lý';
      default:
        return 'Không xác định';
    }
  }

  // Hàm chuyển đổi trạng thái thành màu sắc
  Color _getTrangThaiColor(int? trangThai) {
    switch (trangThai) {
      case 0:
        return Colors.orange.shade700;
      case 1:
        return Colors.green.shade700;
      case 2:
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}