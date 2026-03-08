import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _schedules = [];
  bool _loading = true;
  bool _hasChanged = false;

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
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _loading = true;
    });

    _fetchSchedules();
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _loading = true;
      });

      _fetchSchedules();
    }
  }

  Future<void> _deleteSchedule(int id) async {
    try {
      await http.post(
        Uri.parse('http://localhost:3000/delete-schedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );

      if (!mounted) return;

      setState(() {
        _hasChanged = true;
      });

      _fetchSchedules();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Activity deleted")));
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  void _showOptions(dynamic item) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit"),
              onTap: () async {
                Navigator.pop(context);

                final result = await Navigator.pushNamed(
                  context,
                  '/edit',
                  arguments: item,
                );

                if (result == true) {
                  setState(() {
                    _hasChanged = true;
                  });

                  _fetchSchedules();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Delete"),
              onTap: () {
                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Delete Activity"),
                    content: const Text(
                      "Are you sure you want to delete this activity?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);

                          await _deleteSchedule(item['id']);
                        },
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
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
          "Manage Schedule",
          style: TextStyle(color: Colors.white),
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
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => _changeDate(-1),
                ),

                GestureDetector(
                  onTap: _pickDate,
                  child: Column(
                    children: [
                      Text(
                        DateFormat('d').format(_selectedDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                        ),
                      ),
                      Text(
                        DateFormat('EEE. MMMM yyyy').format(_selectedDate),
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      const Icon(Icons.calendar_month,
                          color: Colors.white70, size: 18)
                    ],
                  ),
                ),

                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                  onPressed: () => _changeDate(1),
                ),
              ],
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _schedules.isEmpty
                    ? const Center(
                        child: Text(
                          "No Activities",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _schedules.length,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemBuilder: (context, index) {
                          var item = _schedules[index];

                          String colorCode = item['color'].replaceAll('#', '');
                          Color cardColor = Color(int.parse("0xff$colorCode"));

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: cardColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border(
                                left: BorderSide(color: cardColor, width: 5),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'],
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
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => _showOptions(item),
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
        currentIndex: 1,
        onTap: (index) {
          if (index == 0)
            Navigator.pushReplacementNamed(context, '/homepage');
          else if (index == 2)
            Navigator.pushReplacementNamed(context, '/add');
          else if (index == 3)
            Navigator.pushReplacementNamed(context, '/notification');
          else if (index == 4)
            Navigator.pushReplacementNamed(context, '/profile');
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