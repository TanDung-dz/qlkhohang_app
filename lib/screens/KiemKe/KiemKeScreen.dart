import 'package:flutter/material.dart';

class KiemKeScreen extends StatelessWidget {
  const KiemKeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo kiểm kê'),
      ),
      body: Center(
        child: const Text(
          'Nội dung báo cáo kiểm kê sẽ hiển thị tại đây.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
