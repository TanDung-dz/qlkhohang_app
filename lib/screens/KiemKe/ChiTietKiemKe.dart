import 'package:flutter/material.dart';
import '../../models/ChiTietKiemKe.dart';
import '../../services/chi_tiet_kiem_ke.dart';
import '../../services/kiem_ke.dart';


class ChiTietKiemKeScreen extends StatefulWidget {
  final int kiemKeId;

  const ChiTietKiemKeScreen({Key? key, required this.kiemKeId}) : super(key: key);

  @override
  _ChiTietKiemKeScreenState createState() => _ChiTietKiemKeScreenState();
}

class _ChiTietKiemKeScreenState extends State<ChiTietKiemKeScreen> {
  late Future<Map<String, dynamic>> _combinedData;

  final ChiTietKiemKeService _chiTietKiemKeService = ChiTietKiemKeService();
  final KiemKeService _kiemKeService = KiemKeService();

  @override
  void initState() {
    super.initState();
    _combinedData = _loadCombinedData();
  }

  Future<Map<String, dynamic>> _loadCombinedData() async {
    try {
      final kiemKeDetails = await _kiemKeService.getInventoryCheckById(widget.kiemKeId);
      final chiTietDetails = await _chiTietKiemKeService.getDetailsById(widget.kiemKeId);

      return {
        'kiemKeDetails': kiemKeDetails,
        'chiTietDetails': chiTietDetails,
      };
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Kiểm Kê'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _combinedData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi khi tải dữ liệu: ${snapshot.error}'),
            );
          }

          if (snapshot.hasData) {
            final kiemKeDetails = snapshot.data!['kiemKeDetails'];
            final List<ChiTietKiemKe> chiTietDetails = snapshot.data!['chiTietDetails'];

            return _buildBody(kiemKeDetails, chiTietDetails);
          }

          return const Center(child: Text('Không có dữ liệu.'));
        },
      ),
    );
  }

  Widget _buildBody(dynamic kiemKeDetails, List<ChiTietKiemKe> chiTietDetails) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị thông tin tổng quan của phiếu kiểm kê
            _buildKiemKeDetails(kiemKeDetails),

            const SizedBox(height: 16.0),

            // Hiển thị danh sách chi tiết kiểm kê
            const Text(
              'Danh sách chi tiết kiểm kê:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: chiTietDetails.length,
              itemBuilder: (context, index) {
                return _buildChiTietItem(chiTietDetails[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKiemKeDetails(dynamic kiemKeDetails) {
    if (kiemKeDetails == null || kiemKeDetails.isEmpty) {
      return const Center(
        child: Text('Không có thông tin kiểm kê', style: TextStyle(fontSize: 16.0)),
      );
    }

    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tên phiếu kiểm kê: ${kiemKeDetails['tenKiemKe'] ?? 'Không xác định'}',
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text('Ngày kiểm kê: ${kiemKeDetails['ngayKiemKe'] ?? 'Không xác định'}'),
            Text('Trạng thái: ${kiemKeDetails['trangThai'] ?? 'Không xác định'}'),
            const SizedBox(height: 8.0),
            // Hiển thị tên nhân viên kho
            Text('Tên nhân viên kho: ${kiemKeDetails['tenNhanVienKho'] ?? 'Không xác định'}'),
          ],
        ),
      ),
    );
  }


  Widget _buildChiTietItem(ChiTietKiemKe chiTiet) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(chiTiet.tenSanPham ?? 'Sản phẩm không xác định'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Số lượng tồn: ${chiTiet.soLuongTon ?? 'N/A'}'),
            Text('Số lượng thực tế: ${chiTiet.soLuongThucTe ?? 'N/A'}'),
            Text('Trạng thái: ${chiTiet.trangThai ?? 'N/A'}'),
            if (chiTiet.nguyenNhan != null) Text('Nguyên nhân: ${chiTiet.nguyenNhan}'),
            const SizedBox(height: 8.0),
            // Hiển thị danh sách ảnh
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

}
