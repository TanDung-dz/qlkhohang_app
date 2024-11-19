import 'package:flutter/material.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReportCard(
          title: 'Báo cáo nhập kho',
          subtitle: 'Thống kê nhập kho theo thời gian',
          icon: Icons.input,
        ),
        _buildReportCard(
          title: 'Báo cáo xuất kho',
          subtitle: 'Thống kê xuất kho theo thời gian',
          icon: Icons.output,
        ),
        _buildReportCard(
          title: 'Báo cáo tồn kho',
          subtitle: 'Thống kê hàng tồn kho hiện tại',
          icon: Icons.inventory,
        ),
        _buildReportCard(
          title: 'Báo cáo giá trị kho',
          subtitle: 'Thống kê giá trị hàng hóa trong kho',
          icon: Icons.monetization_on,
        ),
      ],
    );
  }

  Widget _buildReportCard({
    required String title,
    required String subtitle,
    required IconData icon,
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
      ),
    );
  }
}