import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  Color _selectedColor = const Color(0xFF8DB4B1);

  int scheduleId = 0;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loaded) return;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {

      scheduleId = args['id'];

      _titleController.text = args['title'] ?? "";
      _descriptionController.text = args['description'] ?? "";

      /// ใช้วันที่เดิมของ Activity
      _selectedDate = DateTime.parse(args['date']).toLocal();

      _startTime = _parseTime(args['time_start']);
      _endTime = _parseTime(args['time_end']);

      _selectedColor = _hexToColor(args['color']);
    }

    _loaded = true;
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(":");
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Color _hexToColor(String hex) {
    return Color(int.parse("0xFF${hex.replaceAll("#", "")}"));
  }

  Future<void> _updateSchedule() async {

    try {

      final response = await http.put(
        Uri.parse('http://localhost:3000/update-schedule/$scheduleId'),
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

      /// เช็ค statusCode ก่อน decode
      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {

          if (!mounted) return;

          Navigator.pop(context, true);

        } else {

          throw Exception(data['message']);

        }

      } else {

        throw Exception("Server error: ${response.statusCode}");

      }

    } catch (e) {

      debugPrint("Update error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Update failed")),
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

    if (picked != null) {

      setState(() {
        _selectedDate = picked;
      });

    }
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

        title: const Text(
          "Edit Schedule",
          style: TextStyle(color: Colors.white),
        ),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(25),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text('Title', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 10),

            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle(),
            ),

            const SizedBox(height: 20),

            const Text('Description', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 10),

            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle(),
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

            const Text('Select Color', style: TextStyle(color: Colors.white)),
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
                ),

                onPressed: _updateSchedule,

                child: const Text(
                  "Update Schedule",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ),

            )

          ],

        ),

      ),

    );

  }

  InputDecoration _inputStyle() {

    return InputDecoration(
      hintText: "Enter text...",
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
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

        )

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
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
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