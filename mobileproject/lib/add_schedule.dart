import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'notification_service.dart';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({super.key});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  Color _selectedColor = const Color(0xFF8DB4B1);

  Future<void> _saveSchedule() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/add-schedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
          'title': _titleController.text,
          'description': _descriptionController.text,
          'time_start':
              "${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}:00",
          'time_end':
              "${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}:00",
          'color':
              '#${_selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        DateTime startTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _startTime.hour,
          _startTime.minute,
        );

        await NotificationService.scheduleNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: _titleController.text,
          body: "Activity starting now",
          time: startTime,
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถเชื่อมต่อกับ Server ได้')),
      );
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBgColor = Color(0xFF32363E);
    const Color blueColor = Color(0xFF8DB4B1);
    const Color highlightColor = Color(0xFFB4D800);

    final String startTimeStr = _startTime.format(context);
    final String endTimeStr = _endTime.format(context);

    return Scaffold(
      backgroundColor: primaryBgColor,

      appBar: AppBar(
        backgroundColor: primaryBgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Add New Schedule',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Column(
        children: [
          const Divider(color: Colors.white24, height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text('Title', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter title...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text('Description', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _descriptionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter description...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [

                      Expanded(
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: _buildInfoTile(
                            'Date',
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            Icons.calendar_today,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickTime(true),
                          child: _buildInfoTile(
                            'Start',
                            startTimeStr,
                            Icons.access_time,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickTime(false),
                          child: _buildInfoTile(
                            'End',
                            endTimeStr,
                            Icons.access_time,
                          ),
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Select Color',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      _colorOption(blueColor, 'Blue'),
                      const SizedBox(width: 15),
                      _colorOption(const Color(0xFFE91E63), 'Pink'),
                      const SizedBox(width: 15),
                      _colorOption(const Color(0xFF2E671D), 'Green'),
                    ],
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                        backgroundColor: highlightColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      onPressed: () async {

                        if (_titleController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('กรุณากรอกชื่อหัวข้อ')),
                          );
                          return;
                        }

                        await _saveSchedule();
                      },

                      child: const Text(
                        'Save Schedule',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: blueColor,
        unselectedItemColor: Colors.grey,
        currentIndex: 2,

        onTap: (index) {

          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/homepage');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/manage');
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

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(label, style: const TextStyle(color: Colors.white)),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(12),

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(value, style: const TextStyle(color: Colors.white)),
              Icon(icon, color: Colors.white38),

            ],
          ),
        ),
      ],
    );
  }

  Widget _colorOption(Color color, String label) {
    bool isSelected = _selectedColor == color;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),

        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : null,
        ),

        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}