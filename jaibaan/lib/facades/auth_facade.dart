import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthFacade {
  final String baseUrl = "https://your-node-api-on-render.com"; //

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // connect Node.js Backend API
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        body: jsonEncode({'username': username, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // เก็บ Token
        return {'success': true, 'token': data['token']};
      } else {
        return {'success': false, 'message': 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> signInWithDiscord() async {
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.discord,
      redirectTo: kIsWeb ? null : 'io.supabase.jaibaan://login-callback/',
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
    );
  }
}
