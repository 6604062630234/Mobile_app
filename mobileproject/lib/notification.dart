import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<dynamic> _notifications = [];
  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _fetchNotifications();

    // refresh ทุก 30 วินาที
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _fetchNotifications();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String userEmail = prefs.getString('user_email') ?? '';

      if (userEmail.isEmpty) return;

      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final response = await http.get(
        Uri.parse(
          'http://localhost:3000/get-schedules?date=$today&email=$userEmail',
        ),
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        DateTime now = DateTime.now();

        List filtered = data.where((item) {
          if (item['time_start'] == null || item['time_end'] == null) {
            return false;
          }

          List startParts = item['time_start'].split(":");
          List endParts = item['time_end'].split(":");

          DateTime startTime = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(startParts[0]),
            int.parse(startParts[1]),
          );

          DateTime endTime = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(endParts[0]),
            int.parse(endParts[1]),
          );

          return now.isAfter(startTime) && now.isBefore(endTime);
        }).toList();

        if (!mounted) return;

        setState(() {
          _notifications = filtered;
          _loading = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Notification Error: $e");

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
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
        automaticallyImplyLeading: false,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Column(
        children: [
          const Divider(color: Colors.white24, height: 1),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? const Center(
                        child: Text(
                          "No notifications",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          var item = _notifications[index];

                          String colorCode =
                              (item['color'] ?? '#8DB4B1')
                                  .replaceAll('#', '');

                          Color cardColor =
                              Color(int.parse("0xff$colorCode"));

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(15),

                            decoration: BoxDecoration(
                              color: cardColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border(
                                left: BorderSide(
                                  color: cardColor,
                                  width: 5,
                                ),
                              ),
                            ),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Text(
                                  item['title'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  "${item['time_start'].substring(0, 5)} - ${item['time_end'].substring(0, 5)}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  item['description'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                const Row(
                                  children: [
                                    Icon(
                                      Icons.notifications_active,
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "Activity time reached",
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),

                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: highlightColor,
        unselectedItemColor: Colors.grey,
        currentIndex: 3,

        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/homepage');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/manage');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/add');
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Manage'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}