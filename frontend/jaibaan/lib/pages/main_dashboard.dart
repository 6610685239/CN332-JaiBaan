import 'package:flutter/material.dart';

class MainDashboardPage extends StatelessWidget {
  const MainDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("JaiBaan Dashboard"),
        backgroundColor: const Color(0xFFF9A082),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home_work, size: 100, color: Color(0xFFFF7B7B)),
            const SizedBox(height: 20),
            const Text(
              "ยินดีต้อนรับคุณ Parunchai!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text("ระบบบริหารจัดการบ้านจัดสรร JaiBaan พร้อมใช้งานแล้ว"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
              child: const Text("LOGOUT"),
            ),
          ],
        ),
      ),
    );
  }
}
