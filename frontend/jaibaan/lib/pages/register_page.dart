import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

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
   

  String get apiUrl {
    // ถ้าเป็น Web หรือรันบนคอม (Linux/Windows/Mac) ให้ใช้ localhost
    if (kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return 'http://localhost:3000/api/register';
    }
    
    // ถ้าเป็น Android (Emulator) ให้ใช้ 10.0.2.2
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/register'; 
    }
    
    // กรณีอื่นๆ (เช่น iOS Simulator)
    return 'http://localhost:3000/api/register';
  }

  Future<void> _submitRegister() async {
    if (_formKey.currentState!.validate()) {

      final url = Uri.parse(apiUrl);

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

        if (!mounted) return;

        if (_passwordController.text != _confirmPasswordController.text) {
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('รหัสผ่านไม่ตรงกัน')),
            );
            return; // หยุดการทำงาน ไม่ส่งข้อมูลไป Backend
        }   
        if (response.statusCode == 201 && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ส่งคำขอสำเร็จ!')),
            );
            Navigator.pop(context);
        }
        else {
          // กรณี Server ตอบกลับมาว่า Error (เช่น Username ซ้ำ)
          final msg = jsonDecode(response.body)['message'] ?? 'เกิดข้อผิดพลาด';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $msg')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Connection Error: ${e.toString()}")),
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
                Text("Create an account",
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),

                // Group 1: Account Info
                _buildField(
                  Icons.person_outline, 
                  "Username", 
                  _usernameController,
                  // เพิ่ม Validator สำหรับ Username
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'กรุณากรอก Username';
                    if (!RegExp(r"^[a-zA-Z0-9]+$").hasMatch(value)) {
                      return 'Username ต้องเป็นตัวอักษรหรือตัวเลขเท่านั้น';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                _buildField(Icons.lock_outline, "Password", _passwordController,
                    isObscure: true),
                const SizedBox(height: 15),
                
                // Confirm Password พร้อม Validator เช็คความเหมือน
                _buildField(
                  Icons.lock_outline, 
                  "Confirm Password", 
                  _confirmPasswordController,
                  isObscure: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'กรุณายืนยันรหัสผ่าน';
                    if (value != _passwordController.text) {
                      return 'รหัสผ่านไม่ตรงกัน'; // ขึ้นตัวแดงใต้ช่องนี้
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 15),
                _buildField(
                  Icons.email_outlined, 
                  "Email", 
                  _emailController,
                  // เพิ่ม Validator สำหรับ Email
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'กรุณากรอก Email';
                    if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                      return 'รูปแบบ Email ไม่ถูกต้อง';
                    }
                    return null;
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("Personal Details",
                      style: TextStyle(color: Colors.grey)),
                ),

                // Group 2: Personal Info
                _buildField(Icons.badge_outlined, "First Name", _firstNameController),
                const SizedBox(height: 15),
                _buildField(Icons.badge_outlined, "Last Name", _lastNameController),
                const SizedBox(height: 15),
                _buildField(Icons.phone_outlined, "Phone Number", _phoneController,validator: (value) {
                  if (value == null || value.isEmpty) return 'กรุณากรอกเบอร์โทรศัพท์';
                    // Regex: ขึ้นต้นด้วย 0 ตามด้วยตัวเลขอีก 9 ตัว (รวมเป็น 10 ตัว)
                  if (!RegExp(r'^0[0-9]{9}$').hasMatch(value)) {
                    return 'กรุณากรอกเบอร์มือถือ 10 หลัก (ไม่ต้องมีขีด)';
                  }
                  return null;
                  },
                ), 

                const SizedBox(height: 15),
                _buildField(Icons.home_outlined, "House Number", _roomController),

                const SizedBox(height: 40),

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
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildField(
    IconData icon, 
    String hint, 
    TextEditingController controller, 
    {
      bool isObscure = false, 
      String? Function(String?)? validator // รับฟังก์ชัน Validator เข้ามา
    }
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        // ถ้ามีการส่ง validator มาให้ใช้ตัวนั้น ถ้าไม่มีให้ใช้เช็คค่าว่างเป็น default
        validator: validator ?? (value) => (value == null || value.isEmpty) ? 'กรุณากรอกข้อมูล $hint' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          // ปรับขอบเวลา Error ให้เป็นสีแดงสวยงาม
          errorBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(30),
             borderSide: const BorderSide(color: Colors.red, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(30),
             borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}