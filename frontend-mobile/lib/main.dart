import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const JaiBaanApp());
}

class JaiBaanApp extends StatelessWidget {
  const JaiBaanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JaiBaan',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: LoginPage(), // Login First
    );
  }
}
