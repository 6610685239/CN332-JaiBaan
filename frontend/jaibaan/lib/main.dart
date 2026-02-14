import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/main_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dwmvazfegxsckwlfsqzu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR3bXZhemZlZ3hzY2t3bGZzcXp1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA3MTI5MDcsImV4cCI6MjA4NjI4ODkwN30.dq6137IMP1qPdZpTRoorz4hl9TRqd_wkVTw2cO5ishM',
  );

  runApp(const JaiBaanApp());
}

class JaiBaanApp extends StatefulWidget {
  const JaiBaanApp({super.key});

  @override
  State<JaiBaanApp> createState() => _JaiBaanAppState();
}

class _JaiBaanAppState extends State<JaiBaanApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final Session? session = data.session;
      if (session != null) {
        _navigatorKey.currentState?.pushReplacementNamed('/main');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'JaiBaan',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/main': (context) => const MainDashboardPage(),
      },
      theme: ThemeData(primarySwatch: Colors.orange),
    );
  }
}
