import 'package:flutter/material.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildDashboardCard(
          title: 'Tổng sản phẩm',
          value: '150',
          icon: Icons.inventory_2,
          color: Colors.blue,
        ),
        _buildDashboardCard(
          title: 'Sắp hết hàng',
          value: '12',
          icon: Icons.warning,
          color: Colors.orange,
        ),
        _buildDashboardCard(
          title: 'Đơn nhập kho',
          value: '25',
          icon: Icons.input,
          color: Colors.green,
        ),
        _buildDashboardCard(
          title: 'Đơn xuất kho',
          value: '18',
          icon: Icons.output,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}