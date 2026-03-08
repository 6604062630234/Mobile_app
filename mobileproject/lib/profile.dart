import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; //

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _displayEmail = 'Loading...'; // ค่าเริ่มต้นระหว่างรอโหลด

  @override
  void initState() {
    super.initState();
    _loadUserEmail(); // เรียกโหลดข้อมูลทันทีที่เปิดหน้า
  }

  // ฟังก์ชันดึงอีเมลที่บันทึกไว้ในเครื่อง
  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _displayEmail = prefs.getString('user_email') ?? 'No email found';
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBgColor = Color(0xFF32363E);
    const Color highlightColor = Color(0xFF8DB4B1);

    return Scaffold(
      backgroundColor: primaryBgColor,
      appBar: AppBar(
        backgroundColor: primaryBgColor,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: highlightColor,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 30),
              const Text(
                'My Name', 
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              
              //แสดงอีเมลที่ดึงมาจากตัวแปร _displayEmail
              Text(
                _displayEmail, 
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('Log Out', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    // เมื่อ Logout ควรล้างข้อมูลที่บันทึกไว้ด้วย
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear(); 

                    if (!mounted) return;
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: highlightColor,
        unselectedItemColor: Colors.grey,
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/homepage');
          else if (index == 2) Navigator.pushReplacementNamed(context, '/add');
          else if (index == 4) Navigator.pushReplacementNamed(context, '/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Manage'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notification'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}