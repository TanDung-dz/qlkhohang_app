import 'package:flutter/material.dart';

import '../BaoCaoPhieuNhap/DanhSachPhieuNhapScreen.dart';

import '../BaoCoPhieuPhieuXuat/DanhSachPhieuXuatScreen.dart';
import '../KiemKe/KiemKeScreen.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReportCard(
          title: 'Các Danh sách phiếu nhập kho',
          subtitle: 'Thống kê nhập kho theo thời gian',
          icon: Icons.input,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DanhSachPhieuNhapScreen(),
              ),
            );
          },
        ),
        _buildReportCard(
          title: 'Các danh sách phiếu xuất kho',
          subtitle: 'Thống kê xuất kho theo thời gian',
          icon: Icons.output,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  DanhSachPhieuXuatScreen(),
              ),
            );
          },
        ),
        _buildReportCard(
          title: 'Báo cáo tồn kho',
          subtitle: 'Thống kê hàng tồn kho hiện tại',
          icon: Icons.inventory,
          onTap: () {
            print('Điều hướng tới báo cáo tồn kho.');
          },
        ),
        _buildReportCard(
          title: 'Báo cáo giá trị kho',
          subtitle: 'Thống kê giá trị hàng hóa trong kho',
          icon: Icons.monetization_on,
          onTap: () {
            print('Điều hướng tới báo cáo giá trị kho.');
          },
        ),
        _buildReportCard(
          title: 'Báo cáo kiểm kê',
          subtitle: 'Thống kê kiểm kê hàng hóa trong kho',
          icon: Icons.checklist,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  KiemKeScreen(), // Điều hướng tới màn hình kiểm kê
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          icon,
          size: 40,
          color: Colors.blue,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
