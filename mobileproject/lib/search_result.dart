import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SearchResultPage extends StatefulWidget {
  final String searchText;

  const SearchResultPage({super.key, required this.searchText});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  List schedules = [];
  Map<String, List> groupedSchedules = {};

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    final prefs = await SharedPreferences.getInstance();
    final String email = prefs.getString('user_email') ?? '';

    if (email.isEmpty) return;

    final response = await http.get(
      Uri.parse(
        "http://localhost:3000/search-schedules?title=${widget.searchText}&email=$email",
      ),
    );

    if (response.statusCode == 200) {
      schedules = jsonDecode(response.body);

      schedules.sort((a, b) {
        DateTime d1 = DateTime.parse(a['date']).add(
          Duration(
            hours: int.parse(a['time_start'].substring(0, 2)),
            minutes: int.parse(a['time_start'].substring(3, 5)),
          ),
        );

        DateTime d2 = DateTime.parse(b['date']).add(
          Duration(
            hours: int.parse(b['time_start'].substring(0, 2)),
            minutes: int.parse(b['time_start'].substring(3, 5)),
          ),
        );
        return d1.compareTo(d2);
      });

      groupedSchedules.clear();

      for (var item in schedules) {
        String date = DateTime.parse(
          item['date'],
        ).toIso8601String().split("T")[0];

        if (!groupedSchedules.containsKey(date)) {
          groupedSchedules[date] = [];
        }

        groupedSchedules[date]!.add(item);
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBgColor = Color(0xFF32363E);

    return Scaffold(
      backgroundColor: primaryBgColor,

      appBar: AppBar(
        backgroundColor: primaryBgColor,
        elevation: 0,
        title: Text(
          "Search: ${widget.searchText}",
          style: const TextStyle(color: Colors.white),
        ),
      ),

      body: groupedSchedules.isEmpty
          ? const Center(
              child: Text(
                "No schedules found",
                style: TextStyle(color: Colors.white38),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: groupedSchedules.entries.map((entry) {
                DateTime date = DateTime.parse(entry.key);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        DateFormat('d/M/yyyy').format(date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    ...entry.value.map((item) {
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

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

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
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Text(
                              item['description'] ?? '',
                              style: const TextStyle(color: Colors.white60),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            ),
    );
  }
}
