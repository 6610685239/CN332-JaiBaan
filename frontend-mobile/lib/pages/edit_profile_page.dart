import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String? token;
  const EditProfilePage({super.key, required this.userData, this.token});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _nickname;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;

  String _gender = '';
  String _country = 'Thailand';
  bool _saving = false;
  final _formKey = GlobalKey<FormState>();

  String get baseUrl {
    if (kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  @override
  void initState() {
    super.initState();
    final d = widget.userData;
    _firstName = TextEditingController(text: d['firstName'] ?? '');
    _lastName  = TextEditingController(text: d['lastName'] ?? '');
    _nickname  = TextEditingController(text: d['nickname'] ?? '');
    _email     = TextEditingController(text: d['email'] ?? '');
    _phone     = TextEditingController(text: d['phoneNumber'] ?? '');
    _address   = TextEditingController(text: d['address'] ?? '');
    _gender    = d['gender'] ?? '';
    _country   = d['country'] ?? 'Thailand';
  }

  @override
  void dispose() {
    _firstName.dispose(); _lastName.dispose(); _nickname.dispose();
    _email.dispose(); _phone.dispose(); _address.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF4F6FA),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF05053), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final prefs = await SharedPreferences.getInstance();
    final token = widget.token ?? prefs.getString('auth_token') ?? '';

    try {
      final res = await http.put(
        Uri.parse('$baseUrl/api/user/settings'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'name': _firstName.text.trim(),
          'lastName': _lastName.text.trim(),
          'nickname': _nickname.text.trim(),
          'email': _email.text.trim(),
          'phone': _phone.text.trim(),
          'gender': _gender,
          'country': _country,
          'address': _address.text.trim(),
        }),
      );

      if (res.statusCode == 200) {
        final updated = (jsonDecode(res.body) as Map)['user'] as Map<String, dynamic>;
        await prefs.setString('user_data', jsonEncode({...widget.userData, ...updated}));
        if (mounted) Navigator.pop(context, updated);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save. Please try again.')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1A1A1A)),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Edit profile',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // Full name
            TextFormField(
              controller: _firstName,
              decoration: _dec('Full name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            // Last name
            TextFormField(
              controller: _lastName,
              decoration: _dec('Last name'),
            ),
            const SizedBox(height: 12),
            // Nick name
            TextFormField(
              controller: _nickname,
              decoration: _dec('Nick name'),
            ),
            const SizedBox(height: 12),
            // Email
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: _dec('Email'),
            ),
            const SizedBox(height: 12),
            // Phone with flag
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: _dec('Phone number').copyWith(
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Text('🇹🇭', style: const TextStyle(fontSize: 20)),
                ),
                prefixIconConstraints: const BoxConstraints(),
              ),
            ),
            const SizedBox(height: 12),
            // Country + Gender row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _country,
                    decoration: _dec('Country'),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                    items: const [
                      DropdownMenuItem(value: 'Thailand', child: Text('Thailand')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (v) => setState(() => _country = v ?? 'Thailand'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _gender.isEmpty ? null : _gender,
                    decoration: _dec('Gender'),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                    hint: Text('Gender', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (v) => setState(() => _gender = v ?? ''),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Address
            TextFormField(
              controller: _address,
              decoration: _dec('Address'),
              maxLines: 2,
              minLines: 1,
            ),
            const SizedBox(height: 28),
            // Submit button
            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF05053),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'SUBMIT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
