import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'search_result.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  DateTime _selectedDate = DateTime.now();
  List<dynamic> _schedules = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {

    try {

      final prefs = await SharedPreferences.getInstance();
      final String userEmail = prefs.getString('user_email') ?? '';

      if (userEmail.isEmpty) return;

      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final response = await http.get(
        Uri.parse(
          'http://localhost:3000/get-schedules?date=$formattedDate&email=$userEmail',
        ),
      );

      if (response.statusCode == 200) {

        if (!mounted) return;

        setState(() {
          _schedules = jsonDecode(response.body);
        });
      }

    } catch (e) {
      debugPrint("Error fetching schedules: $e");
    }
  }

  void _changeDate(int days) {

    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
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

    if (picked != null) {

      setState(() {
        _selectedDate = picked;
      });

      _fetchSchedules();
    }
  }

  void _search() {

    if (_searchController.text.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SearchResultPage(searchText: _searchController.text),
      ),
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
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),

      body: Column(
        children: [

          const Divider(color: Colors.white24, height: 1),

          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (value) => _search(),
              decoration: InputDecoration(
                hintText: "Search activity...",
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),

                filled: true,
                fillColor: Colors.white.withOpacity(0.1),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),

                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: _search,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),

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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),

                      const Icon(
                        Icons.calendar_month,
                        color: Colors.white70,
                      ),

                    ],
                  ),
                ),

                IconButton(
                  icon:
                      const Icon(Icons.arrow_forward_ios, color: Colors.white),
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
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _schedules.length,
                    itemBuilder: (context, index) {

                      var item = _schedules[index];

                      String colorCode =
                          item['color'].replaceAll('#', '');

                      Color cardColor =
                          Color(int.parse("0xff$colorCode"));

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
                                  "${item['time_start'].substring(0,5)} - ${item['time_end'].substring(0,5)}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),

                              ],
                            ),

                            const SizedBox(height: 8),

                            Text(
                              item['description'] ?? '',
                              style: const TextStyle(
                                color: Colors.white60,
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
          }

          else if (index == 2) {

            final result = await Navigator.pushNamed(context, '/add');

            if (result == true) _fetchSchedules();
          }

          else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/notification');
          }

          else if (index == 4) {
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