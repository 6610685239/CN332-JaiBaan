import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dwmvazfegxsckwlfsqzu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR3bXZhemZlZ3hzY2t3bGZzcXp1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA3MTI5MDcsImV4cCI6MjA4NjI4ODkwN30.dq6137IMP1qPdZpTRoorz4hl9TRqd_wkVTw2cO5ishM',
  );

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
