import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  int totalProducts = 0;
  int totalPhieuNhap = 0;
  int totalPhieuXuat = 0;
  int inventoryCount = 0;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    await Future.wait([
      fetchTotalProducts(),
      fetchTotalPhieuNhap(),
      fetchTotalPhieuXuat(),
      fetchInventoryCount(),
    ]);
  }

  Future<void> fetchTotalProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/SanPham/Get'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          totalProducts = data.length;
        });
      }
    } catch (e) {
      print('Lỗi tải tổng số sản phẩm: $e');
    }
  }

  Future<void> fetchTotalPhieuNhap() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/PhieuNhapHang/Get'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          totalPhieuNhap = data.length;
        });
      }
    } catch (e) {
      print('Lỗi tải tổng số phiếu nhập hàng: $e');
    }
  }

  Future<void> fetchTotalPhieuXuat() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/PhieuXuatHang/Get'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          totalPhieuXuat = data.length;
        });
      }
    } catch (e) {
      print('Lỗi tải tổng số phiếu xuất hàng: $e');
    }
  }

  Future<void> fetchInventoryCount() async {
    // Placeholder for actual inventory count API call
    setState(() {
      inventoryCount = 12; // Replace with actual API call
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchDashboardData,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Colors.white,
                elevation: 1,
                title: Text(
                  'Kho Hàng Quản Lý',
                  style: TextStyle(
                    color: Colors.blueGrey[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      switch (index) {
                        case 0:
                          return _buildDashboardCard(
                            title: 'Tổng Sản Phẩm',
                            value: '$totalProducts',
                            icon: Icons.inventory_2_outlined,
                            color: Colors.blue[700]!,
                            gradient: LinearGradient(
                              colors: [Colors.blue[700]!, Colors.blue[500]!],
                            ),
                          );
                        case 1:
                          return _buildDashboardCard(
                            title: 'Hàng Tồn Kho',
                            value: '$inventoryCount',
                            icon: Icons.warning_amber_outlined,
                            color: Colors.orange[700]!,
                            gradient: LinearGradient(
                              colors: [Colors.orange[700]!, Colors.orange[500]!],
                            ),
                          );
                        case 2:
                          return _buildDashboardCard(
                            title: 'Phiếu Nhập Kho',
                            value: '$totalPhieuNhap',
                            icon: Icons.input_outlined,
                            color: Colors.green[700]!,
                            gradient: LinearGradient(
                              colors: [Colors.green[700]!, Colors.green[500]!],
                            ),
                          );
                        case 3:
                          return _buildDashboardCard(
                            title: 'Phiếu Xuất Kho',
                            value: '$totalPhieuXuat',
                            icon: Icons.output_outlined,
                            color: Colors.red[700]!,
                            gradient: LinearGradient(
                              colors: [Colors.red[700]!, Colors.red[500]!],
                            ),
                          );
                        default:
                          return null;
                      }
                    },
                    childCount: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required LinearGradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Optional: Add navigation or detailed view
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}