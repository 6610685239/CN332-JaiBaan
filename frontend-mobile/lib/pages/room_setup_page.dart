import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main_dashboard.dart';

class RoomSetupPage extends StatefulWidget {
  final String googleId;
  final String email;
  final String name;
  final String picture;

  const RoomSetupPage({
    super.key,
    required this.googleId,
    required this.email,
    required this.name,
    required this.picture,
  });

  @override
  State<RoomSetupPage> createState() => _RoomSetupPageState();
}

class _RoomSetupPageState extends State<RoomSetupPage> {
  final _roomController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String get apiUrl {
    if (kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return 'http://localhost:3000/api/auth/google/complete';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/auth/google/complete';
    }
    return 'http://localhost:3000/api/auth/google/complete';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'googleId': widget.googleId,
              'email': widget.email,
              'name': widget.name,
              'picture': widget.picture,
              'roomNumber': _roomController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_data', jsonEncode(data['user']));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainDashboardPage()),
          );
        }
      } else {
        final msg = jsonDecode(response.body)['message'] ?? 'Setup failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $msg'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot connect to server: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(width: double.infinity, height: double.infinity, color: const Color(0xFFFDF0E7)),

          Positioned.fill(
            child: Stack(
              children: [
                Positioned(
                  top: size.height * 0.175,
                  left: size.width * 0.03,
                  child: Container(
                    width: 180, height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        const Color(0xFFF05053).withOpacity(0.7),
                        const Color(0xFFF05053).withOpacity(0.0),
                      ]),
                    ),
                  ),
                ),
                Positioned(
                  top: size.height * 0.175,
                  right: size.width * 0.03,
                  child: Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        const Color(0xFFF05053).withOpacity(0.6),
                        const Color(0xFFF05053).withOpacity(0.0),
                      ]),
                    ),
                  ),
                ),
                Positioned(
                  bottom: size.height * 0.2,
                  left: size.width * 0.15,
                  child: Container(
                    width: 180, height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        const Color(0xFFF05053).withOpacity(0.5),
                        const Color(0xFFF05053).withOpacity(0.0),
                      ]),
                    ),
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(color: Colors.transparent),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/logo.png', height: 100),
                        const SizedBox(height: 8),
                        Text(
                          '"Bringing heart back to the neighborhood."',
                          style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic, fontSize: 12),
                        ),
                        const SizedBox(height: 36),

                        // Avatar
                        if (widget.picture.isNotEmpty)
                          CircleAvatar(
                            radius: 36,
                            backgroundImage: NetworkImage(widget.picture),
                          ),
                        if (widget.picture.isNotEmpty) const SizedBox(height: 12),

                        Text(
                          'Welcome, ${widget.name.isNotEmpty ? widget.name.split(' ')[0] : 'there'}!',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'One last step — enter your room number\nto complete your registration.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
                        ),
                        const SizedBox(height: 32),

                        // Room Number field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: TextFormField(
                            controller: _roomController,
                            enabled: !_isLoading,
                            validator: (v) => (v == null || v.isEmpty) ? 'Please enter your room number' : null,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.home_outlined, color: Colors.grey[400], size: 20),
                              hintText: 'Room Number',
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(color: Colors.red, width: 1.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(color: Colors.red, width: 2.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Confirm button
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFF9A082), Color(0xFFFF7B7B)]),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFFF9A082).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : const Text('CONFIRM & ENTER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
