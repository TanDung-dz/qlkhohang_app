import 'package:flutter/material.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  // Danh sách sản phẩm (có thể thay đổi)
  final List<Map<String, dynamic>> _products = [
    {'id': 1, 'name': 'Sản phẩm A', 'quantity': 30},
    {'id': 2, 'name': 'Sản phẩm B', 'quantity': 20},
    {'id': 3, 'name': 'Sản phẩm C', 'quantity': 50},
    {'id': 4, 'name': 'Sản phẩm D', 'quantity': 0},
    {'id': 5, 'name': 'Sản phẩm E', 'quantity': 40},
  ];

  // Hàm tính tổng số lượng sản phẩm
  int _getTotalQuantity() {
    return _products.fold<int>(0, (sum, product) => sum + (product['quantity'] as int));
  }

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
          value: '${_getTotalQuantity()}', // Hiển thị tổng số sản phẩm
          icon: Icons.inventory_2,
          color: Colors.blue,
        ),
        _buildDashboardCard(
          title: 'Sắp hết hàng',
          value: '12', // Dữ liệu mẫu, cập nhật nếu cần
          icon: Icons.warning,
          color: Colors.orange,
        ),
        _buildDashboardCard(
          title: 'Đơn nhập kho',
          value: '25', // Dữ liệu mẫu, cập nhật nếu cần
          icon: Icons.input,
          color: Colors.green,
        ),
        _buildDashboardCard(
          title: 'Đơn xuất kho',
          value: '18', // Dữ liệu mẫu, cập nhật nếu cần
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
