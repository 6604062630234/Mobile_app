import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'notification_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _schedules = [];

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final response = await http.get(
        Uri.parse('http://localhost:3000/get-schedules?date=$formattedDate'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _schedules = jsonDecode(response.body);
        });

        await _syncNotifications();
      }
    } catch (e) {
      debugPrint("Error fetching schedules: $e");
    }
  }

  Future<void> _syncNotifications() async {
    DateTime now = DateTime.now();

    for (var item in _schedules) {
      int id = item['id'];

      List startParts = item['time_start'].split(":");
      List endParts = item['time_end'].split(":");

      DateTime startTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );

      DateTime endTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );

      if (now.isBefore(startTime)) {
        await NotificationService.scheduleNotification(
          id: id,
          title: item['title'],
          body: "Activity starting now",
          time: startTime,
        );
      }

      if (now.isAfter(endTime)) {
        await NotificationService.cancelNotification(id);
      }
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });

    _fetchSchedules();
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
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          const Divider(color: Colors.white24, height: 1),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => _changeDate(-1),
                ),

                Column(
                  children: [
                    Text(
                      DateFormat('d').format(_selectedDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      DateFormat('EEE. MMMM yyyy').format(_selectedDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),

                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => _changeDate(1),
                ),
              ],
            ),
          ),

          Expanded(
            child: _schedules.isEmpty
                ? const Center(
                    child: Text(
                      'No schedules for this day',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _schedules.length,
                    itemBuilder: (context, index) {
                      var item = _schedules[index];

                      String colorCode = item['color'].replaceAll('#', '');
                      Color cardColor = Color(int.parse("0xff$colorCode"));

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(15),

                        decoration: BoxDecoration(
                          color: cardColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border(
                            left: BorderSide(color: cardColor, width: 5),
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Text(
                                  "${item['time_start'].substring(0, 5)} - ${item['time_end'].substring(0, 5)}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Text(
                              item['description'] ?? '',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
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
        currentIndex: 0,
        onTap: (index) async {
          if (index == 1) {
            final result = await Navigator.pushNamed(context, '/manage');
            if (result == true) _fetchSchedules();
          } else if (index == 2) {
            final result = await Navigator.pushNamed(context, '/add');
            if (result == true) _fetchSchedules();
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/notification');
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