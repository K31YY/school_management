// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ViewSchedule extends StatefulWidget {
  const ViewSchedule({super.key});

  @override
  _ViewScheduleState createState() => _ViewScheduleState();
}

class _ViewScheduleState extends State<ViewSchedule> {
  // ប្រសិនបើប្រើ Emulator សូមប្រើ 10.0.2.2 បើប្រើទូរសព្ទផ្ទាល់ត្រូវប្រើ IP ម៉ាស៊ីន
  final String baseUrl = "http://10.0.2.2:8000/api";

  List<dynamic> assignedSchedules = [];
  String selectedDay = "Monday";

  final Color primaryBlue = const Color(0xFF4A5BF6);
  final Color backgroundGrey = const Color(0xFFF4F6F8);

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    EasyLoading.show(status: 'Loading data...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('TOKEN');

      final response = await http.get(
        Uri.parse("$baseUrl/schedule-details"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      debugPrint("API Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        debugPrint("Full Data: $responseData");

        // ឆែកមើលរចនាសម្ព័ន្ធ JSON ពី Laravel (ភាគច្រើនគឺរុំក្នុង key 'data')
        List<dynamic> allData = [];
        if (responseData is Map && responseData.containsKey('data')) {
          allData = responseData['data'];
        } else if (responseData is List) {
          allData = responseData;
        }

        setState(() {
          // ការ Filter ដោយប្រើ lowercase និង trim ដើម្បីបង្កើនភាពច្បាស់លាស់
          assignedSchedules = allData.where((item) {
            String dayFromApi = item['DayOfWeek']
                .toString()
                .trim()
                .toLowerCase();
            String dayToCompare = selectedDay.toLowerCase();
            return dayFromApi == dayToCompare;
          }).toList();
        });
      } else {
        EasyLoading.showError("Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
      EasyLoading.showError("Connection Failed");
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Schedule",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildDaySelector(),
          const SizedBox(height: 15),
          Expanded(child: _buildScheduleList()),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    List<String> days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: days.map((day) {
            bool isSelected = selectedDay == day;
            return GestureDetector(
              onTap: () {
                setState(() => selectedDay = day);
                _fetchSchedules(); // ទាញទិន្នន័យថ្មីរាល់ពេលដូរថ្ងៃ
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  day.substring(0, 3),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    if (assignedSchedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 10),
            const Text(
              "No schedule assigned for this day.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: assignedSchedules.length,
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        final item = assignedSchedules[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${item['subject']?['SubName'] ?? 'Unnamed Subject'}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['teacher']?['TeacherName'] ?? "No Teacher",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _timeBox(
                item['StartTime'].toString().substring(0, 5),
                const Color(0xFF607D8B),
                true,
              ),
              _timeBox(
                item['EndTime'].toString().substring(0, 5),
                const Color(0xFFECEFF1),
                false,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _timeBox(String time, Color color, bool isLeft) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: isLeft
            ? const BorderRadius.horizontal(left: Radius.circular(8))
            : const BorderRadius.horizontal(right: Radius.circular(8)),
      ),
      child: Text(
        time,
        style: TextStyle(
          color: isLeft ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
