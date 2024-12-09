import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'AccountInfoPage.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Thông tin tài khoản'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountInfoPage())
            );
          },
        ),
        const ListTile(
          leading: Icon(Icons.notifications),
          title: Text('Thông báo'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        const ListTile(
          leading: Icon(Icons.security),
          title: Text('Bảo mật'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        const ListTile(
          leading: Icon(Icons.language),
          title: Text('Ngôn ngữ'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        const ListTile(
          leading: Icon(Icons.help),
          title: Text('Trợ giúp'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        const ListTile(
          leading: Icon(Icons.info),
          title: Text('Về ứng dụng'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
      ],
    );
  }
}