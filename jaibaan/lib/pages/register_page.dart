import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers ตามผังใหม่
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _roomController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
   
  Future<void> _submitRegister() async {
    if (_formKey.currentState!.validate()) {
      // หมายเหตุ: เปลี่ยน localhost เป็น IP เครื่องคอมคุณถ้าใช้มือถือจริงเทส
      final url = Uri.parse('http://localhost:3000/api/register');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "username": _usernameController.text,
            "password": _passwordController.text,
            "firstName": _firstNameController.text,
            "lastName": _lastNameController.text,
            "phoneNumber": _phoneController.text,
            "roomNumber": _roomController.text,
            "email": _emailController.text,
          }),
        );
        if (_passwordController.text != _confirmPasswordController.text) {
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('รหัสผ่านไม่ตรงกัน')),
            );
            return; // หยุดการทำงาน ไม่ส่งข้อมูลไป Backend
        }   
        if (response.statusCode == 201 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ส่งคำขอสำเร็จ! รอนิติอนุมัติ')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${e.toString()}")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDF0E7), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 80),
                Image.asset('assets/images/logo.png', height: 100),
                const SizedBox(height: 30),
                Text("Join our neighborhood", 
                  style: TextStyle(color: Colors.grey[700], fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),

                // Group 1: Account Info
                _buildField(Icons.person_outline, "Username", _usernameController),
                const SizedBox(height: 15),
                _buildField(Icons.lock_outline, "Password", _passwordController, isObscure: true),
                const SizedBox(height: 15),
                _buildField(Icons.lock_outline, "Confirm Password", _confirmPasswordController, isObscure: true),
                const SizedBox(height: 15),
                _buildField(Icons.email_outlined, "Email", _emailController),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("Personal Details", style: TextStyle(color: Colors.grey)),
                ),

                // Group 2: Personal Info
                _buildField(Icons.badge_outlined, "First Name", _firstNameController),
                const SizedBox(height: 15),
                _buildField(Icons.badge_outlined, "Last Name", _lastNameController),
                const SizedBox(height: 15),
                _buildField(Icons.phone_outlined, "Phone Number", _phoneController),
                const SizedBox(height: 15),
                _buildField(Icons.home_outlined, "House Number", _roomController),

                const SizedBox(height: 40),

                // Register Button (Gradient Style)
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF9A082), Color(0xFFFF7B7B)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ElevatedButton(
                    onPressed: _submitRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text("REGISTER",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(IconData icon, String hint, TextEditingController controller, {bool isObscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}