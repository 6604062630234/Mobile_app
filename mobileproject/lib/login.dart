import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // สำหรับคุยกับ Node.js
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}
Future<void> _saveUserEmail(String email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_email', email); // บันทึกอีเมลลงเครื่อง
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //ส่งข้อมูลไปเช็คที่ Node.js
  Future<void> _login() async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:3000/login'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', _emailController.text); // บันทึกอีเมลที่ผู้ใช้กรอก
        // ถ้า Login สำเร็จ
        if (!mounted) return;
        await prefs.setBool('is_logged_in', true);
        Navigator.pushReplacementNamed(context, '/homepage');
      } else {
        _showErrorDialog(data['message']);
      }
    } catch (e) {
      _showErrorDialog("ไม่สามารถเชื่อมต่อกับ Server ได้");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color topBackgroundColor = Color(0xFF32363E); 
    const Color bottomBackgroundColor = Color(0xFF8DB4B1); 
    const Color buttonColor = Color(0xFFB4D800);

    return Scaffold(
      backgroundColor: topBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 50.0),
                child: Center(
                  child: Image(
                    image: AssetImage("assets/images/logo.png"),
                    height: 120,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                decoration: const BoxDecoration(
                  color: bottomBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    const Text('Welcome to My schedule', style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 40),
                    // ช่องกรอก Email
                    TextField(
                      controller: _emailController, 
                      decoration: const InputDecoration(labelText: 'Email', filled: true, fillColor: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    // ช่องกรอก Password
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password', filled: true, fillColor: Colors.white),
                    ),
                    const SizedBox(height: 30),
                    // ปุ่ม Log in
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
                        onPressed: _login, // เรียกใช้ฟังก์ชัน _login
                        child: const Text('Log In', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}