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

  // ดึงข้อมูลจาก database
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

  // เปลี่ยนวัน
  void _changeDate(int days) {

    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _loading = true;
    });

    _fetchSchedules();

  }

  // ลบ activity
  Future<void> _deleteSchedule(int id) async {

    try {

      await http.post(
        Uri.parse('http://localhost:3000/delete-schedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );

      if (!mounted) return;

      setState(() {
        _hasChanged = true; // บอกว่ามีการเปลี่ยนข้อมูล
      });

      _fetchSchedules(); // refresh หน้า manage

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Activity deleted")),
      );

    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  // เมนู Edit / Delete
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
                    content: const Text("Are you sure you want to delete this activity?"),
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
                      )

                    ],
                  ),
                );

              },
            )

          ],
        );

      },
    );

  }

  @override
  Widget build(BuildContext context) {

    const Color primaryBgColor = Color(0xFF32363E);

    return Scaffold(

      backgroundColor: primaryBgColor,

      appBar: AppBar(
        backgroundColor: primaryBgColor,
        title: const Text("Manage", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, _hasChanged);
          },
        ),
      ),

      body: Column(
        children: [

          const Divider(color: Colors.white24),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => _changeDate(-1),
                ),

                Column(
                  children: [
                    Text(
                      DateFormat('d').format(_selectedDate),
                      style: const TextStyle(color: Colors.white, fontSize: 28),
                    ),
                    Text(
                      DateFormat('EEE. MMMM yyyy').format(_selectedDate),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),

                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Text(
                                        item['title'],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        "${item['time_start'].substring(0,5)} - ${item['time_end'].substring(0,5)}",
                                        style: const TextStyle(color: Colors.white70),
                                      ),

                                    ],
                                  ),
                                ),

                                IconButton(
                                  icon: const Icon(Icons.more_vert, color: Colors.white),
                                  onPressed: () => _showOptions(item),
                                )

                              ],
                            ),
                          );
                        },
                      ),
          )

        ],
      ),
    );
  }
}