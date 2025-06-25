import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เข้าสู่ระบบ')),
      body: const Center(
        child: Text('หน้าเข้าสู่ระบบ (ยังไม่ทำ)'),
      ),
    );
  }
}
