// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login/login_screen.dart';
import '../tabs/dashboard_tab.dart';
import '../tabs/inventory_tab.dart';
import '../tabs/reports_tab.dart';
import '../tabs/settings_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();

  void _logout() {
    _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  final List<Widget> _tabs = const [
    DashboardTab(),
    InventoryTab(),
    ReportsTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final isManager = _authService.isManager();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Quản lý kho hàng'),
            if (isManager)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Chip(
                  label: Text('Quản lý'),
                  backgroundColor: Colors.blue,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Kho hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Báo cáo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}