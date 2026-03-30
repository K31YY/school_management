// ignore_for_file: library_private_types_in_public_api, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AssignSchedule extends StatefulWidget {
  const AssignSchedule({super.key});

  @override
  _AssignScheduleScreenState createState() => _AssignScheduleScreenState();
}

class _AssignScheduleScreenState extends State<AssignSchedule> {
  // CONFIGURATION
  final String baseUrl = "http://10.0.2.2:8000/api";

  // DATA LISTS
  List<dynamic> classSections = [];
  List<dynamic> studies = [];
  List<dynamic> teachers = [];
  List<dynamic> subjects = [];
  List<dynamic> assignedSchedules = [];

  // SELECTIONS
  String? selectedSectionId;
  String? selectedYearId;
  String selectedDay = "Monday";

  // STYLING
  final Color primaryBlue = const Color(0xFF4A5BF6);
  final Color backgroundGrey = const Color(0xFFF4F6F8);
  final Color borderBlue = const Color(0xFFD0DBF1);

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  // --- API HELPERS ---

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer ${prefs.getString('TOKEN')}",
    };
  }

  Future<void> _fetchInitialData() async {
    EasyLoading.show(status: 'Loading...');
    try {
      final headers = await _getHeaders();
      final responses = await Future.wait([
        http.get(Uri.parse("$baseUrl/class-sections"), headers: headers),
        http.get(Uri.parse("$baseUrl/academic-years"), headers: headers),
        http.get(Uri.parse("$baseUrl/teachers"), headers: headers),
        http.get(Uri.parse("$baseUrl/subjects"), headers: headers),
      ]);

      if (mounted) {
        setState(() {
          classSections = json.decode(responses[0].body)['data'] ?? [];
          studies = json.decode(responses[1].body)['data'] ?? [];
          teachers = json.decode(responses[2].body)['data'] ?? [];
          subjects = json.decode(responses[3].body)['data'] ?? [];
        });
      }
    } catch (e) {
      EasyLoading.showError("Fetch Error: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> _fetchSchedules() async {
    if (selectedSectionId == null) return;
    try {
      final headers = await _getHeaders();
      final res = await http.get(
        Uri.parse("$baseUrl/schedule-details?section_id=$selectedSectionId"),
        headers: headers,
      );

      if (res.statusCode == 200) {
        final List<dynamic> allData = json.decode(res.body)['data'];
        setState(() {
          assignedSchedules = allData
              .where((item) => item['DayOfWeek'] == selectedDay)
              .toList();
        });
      }
    } catch (e) {
      debugPrint("List Fetch Error: $e");
    }
  }

  Future<void> _saveToDatabase(
    String tId,
    String sId,
    String start,
    String end, {
    String? detailId,
    String? scheduleId,
  }) async {
    EasyLoading.show(status: 'Processing...');
    try {
      final headers = await _getHeaders();

      // Use 'schedule-details' with a DASH to match Laravel apiResource
      final String url = detailId != null
          ? "$baseUrl/schedule-details/$detailId"
          : "$baseUrl/schedule-details";

      // IDs must be sent as Integers for Laravel Validation
      final Map<String, dynamic> body = {
        "ScheduleID": int.parse(scheduleId ?? "1"),
        "TeacherID": int.parse(tId),
        "SubID": int.parse(sId),
        "RoomID": 1,
        "DayOfWeek": selectedDay,
        "StartTime": start,
        "EndTime": end,
      };

      final response = detailId != null
          ? await http.put(
              Uri.parse(url),
              headers: headers,
              body: jsonEncode(body),
            )
          : await http.post(
              Uri.parse(url),
              headers: headers,
              body: jsonEncode(body),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.showSuccess("Saved Successfully");
        if (!mounted) return;
        Navigator.pop(context); // Close Modal
        _fetchSchedules(); // Refresh List
      } else {
        EasyLoading.dismiss();
        debugPrint("Server Error: ${response.body}");
        EasyLoading.showError("Failed: ${response.statusCode}");
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError("Network Error");
    }
  }

  Future<void> _deleteSchedule(String id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Delete Schedule"),
        content: const Text("Are you sure you want to remove this schedule?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      EasyLoading.show(status: 'Deleting...');
      try {
        final headers = await _getHeaders();
        final res = await http.delete(
          Uri.parse("$baseUrl/schedule-details/$id"),
          headers: headers,
        );
        if (res.statusCode == 200) {
          EasyLoading.showSuccess("Deleted");
          _fetchSchedules();
        } else {
          EasyLoading.dismiss();
          EasyLoading.showError("Delete Failed");
        }
      } catch (e) {
        EasyLoading.dismiss();
        EasyLoading.showError("Network Error");
      }
    }
  }

  // --- UI COMPONENTS ---

  String _formatTime(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute:00";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text(
          "Assign Schedule",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: () => _openAddModal(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildTopSelectionCard(),
          const SizedBox(height: 15),
          _buildDaySelector(),
          const SizedBox(height: 10),
          Expanded(child: _buildScheduleList()),
        ],
      ),
    );
  }

  Widget _buildTopSelectionCard() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputLabel("Class Section"),
          _customDropdown(
            value: selectedSectionId,
            items: classSections
                .map(
                  (item) => DropdownMenuItem(
                    value: item['SectionID'].toString(),
                    child: Text(item['SectionName']),
                  ),
                )
                .toList(),
            onChanged: (v) {
              setState(() => selectedSectionId = v);
              _fetchSchedules();
            },
          ),
          const SizedBox(height: 15),
          _inputLabel("Academic Year"),
          _customDropdown(
            value: selectedYearId,
            items: studies
                .map(
                  (item) => DropdownMenuItem(
                    value: item['YearID'].toString(),
                    child: Text(item['YearName'] ?? "Year ${item['YearID']}"),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => selectedYearId = v),
          ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((day) {
          bool isSelected = selectedDay == day;
          return GestureDetector(
            onTap: () {
              setState(() => selectedDay = day);
              _fetchSchedules();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }

  Widget _buildScheduleList() {
    if (assignedSchedules.isEmpty) {
      return const Center(
        child: Text(
          "No schedule assigned",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      itemCount: assignedSchedules.length,
      itemBuilder: (context, index) {
        final item = assignedSchedules[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${item['subject']?['SubName'] ?? 'Subject'}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      item['teacher']?['TeacherName'] ?? "Teacher",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              _timeBox(
                item['StartTime'].substring(0, 5),
                Colors.blueGrey,
                true,
              ),
              _timeBox(
                item['EndTime'].substring(0, 5),
                Colors.grey[300]!,
                false,
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'edit') _openAddModal(existingItem: item);
                  if (val == 'delete')
                    _deleteSchedule(item['DetailID'].toString());
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'edit', child: Text("Update")),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text("Delete", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _openAddModal({dynamic existingItem}) {
    if (selectedSectionId == null || selectedYearId == null) {
      EasyLoading.showInfo("Select Class and Year first");
      return;
    }

    bool isEdit = existingItem != null;
    String? mTeacherId = isEdit ? existingItem['TeacherID'].toString() : null;
    String? mSubId = isEdit ? existingItem['SubID'].toString() : null;

    TimeOfDay startTime = isEdit
        ? TimeOfDay(
            hour: int.parse(existingItem['StartTime'].split(":")[0]),
            minute: int.parse(existingItem['StartTime'].split(":")[1]),
          )
        : const TimeOfDay(hour: 7, minute: 0);
    TimeOfDay endTime = isEdit
        ? TimeOfDay(
            hour: int.parse(existingItem['EndTime'].split(":")[0]),
            minute: int.parse(existingItem['EndTime'].split(":")[1]),
          )
        : const TimeOfDay(hour: 8, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEdit ? "Update Schedule" : "Add New Schedule",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              _customDropdown(
                value: mTeacherId,
                items: teachers
                    .map(
                      (t) => DropdownMenuItem(
                        value: t['TeacherID'].toString(),
                        child: Text(t['TeacherName']),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setModalState(() => mTeacherId = v),
              ),
              const SizedBox(height: 15),
              _customDropdown(
                value: mSubId,
                items: subjects
                    .map(
                      (s) => DropdownMenuItem(
                        value: s['SubID'].toString(),
                        child: Text(s['SubName']),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setModalState(() => mSubId = v),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _modalTimeField(
                      context,
                      "Start",
                      startTime,
                      (p) => setModalState(() => startTime = p),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _modalTimeField(
                      context,
                      "End",
                      endTime,
                      (p) => setModalState(() => endTime = p),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _actionBtn(
                      "Cancel",
                      Colors.grey,
                      () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _actionBtn(
                      isEdit ? "Update" : "Save",
                      primaryBlue,
                      () {
                        if (mTeacherId != null && mSubId != null) {
                          _saveToDatabase(
                            mTeacherId!,
                            mSubId!,
                            _formatTime(startTime),
                            _formatTime(endTime),
                            detailId: isEdit
                                ? existingItem['DetailID'].toString()
                                : null,
                            scheduleId: isEdit
                                ? existingItem['ScheduleID'].toString()
                                : null,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- REUSABLE WIDGETS ---

  Widget _inputLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
        fontSize: 13,
      ),
    ),
  );

  Widget _customDropdown({
    String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderBlue),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _timeBox(String time, Color color, bool isLeft) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: isLeft
            ? const BorderRadius.horizontal(left: Radius.circular(5))
            : const BorderRadius.horizontal(right: Radius.circular(5)),
      ),
      child: Text(
        time,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _modalTimeField(
    BuildContext context,
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onPick,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: () async {
            final p = await showTimePicker(context: context, initialTime: time);
            if (p != null) onPick(p);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderBlue),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time.format(context),
                  style: const TextStyle(fontSize: 12),
                ),
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
