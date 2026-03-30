import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart'; // Add this to your pubspec.yaml for date formatting

// --- 1. THE DATA MODEL ---
class AcademicYear {
  final int? yearId;
  final String yearName;
  final String startDate;
  final String endDate;
  final String description;
  final int isDeleted;

  AcademicYear({
    this.yearId,
    required this.yearName,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.isDeleted,
  });

  factory AcademicYear.fromJson(Map<String, dynamic> json) {
    return AcademicYear(
      yearId: json['YearID'] is int
          ? json['YearID']
          : int.tryParse(json['YearID']?.toString() ?? ''),
      yearName: json['YearName']?.toString() ?? '',
      startDate: json['StartDate']?.toString() ?? '',
      endDate: json['EndDate']?.toString() ?? '',
      description: json['Description']?.toString() ?? '',
      isDeleted: json['IsDeleted'] is int
          ? json['IsDeleted']
          : int.tryParse(json['IsDeleted']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "YearName": yearName,
    "StartDate": startDate,
    "EndDate": endDate,
    "Description": description,
    "IsDeleted": isDeleted,
  };
}

// --- 2. THE SCREEN ---
class AcademicYearScreen extends StatefulWidget {
  const AcademicYearScreen({super.key});

  @override
  State<AcademicYearScreen> createState() => _AcademicYearScreenState();
}

class _AcademicYearScreenState extends State<AcademicYearScreen> {
  final String baseUrl = "http://10.0.2.2:8000/api";
  List<AcademicYear> academicYears = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchYears();
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('TOKEN');
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // --- CRUD FUNCTIONS ---
  Future<void> _fetchYears() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/academic-years"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        setState(
          () => academicYears = data
              .map((e) => AcademicYear.fromJson(e))
              .toList(),
        );
      }
    } catch (e) {
      EasyLoading.showError("Connection Failed");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _insertYear(AcademicYear newYear) async {
    EasyLoading.show(status: 'Saving...');
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/academic-years"),
        headers: await _getHeaders(),
        body: jsonEncode(newYear.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        EasyLoading.showSuccess("Saved!");
        _fetchYears();
      }
    } catch (e) {
      EasyLoading.showError("Error Saving");
    }
  }

  Future<void> _updateYear(AcademicYear year) async {
    EasyLoading.show(status: 'Updating...');
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/academic-years/${year.yearId}"),
        headers: await _getHeaders(),
        body: jsonEncode(year.toJson()),
      );
      if (response.statusCode == 200) {
        EasyLoading.showSuccess("Updated!");
        _fetchYears();
      }
    } catch (e) {
      EasyLoading.showError("Update Failed");
    }
  }

  Future<void> _deleteYear(int id) async {
    EasyLoading.show(status: 'Deleting...');
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/academic-years/$id"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        EasyLoading.showSuccess("Deleted");
        _fetchYears();
      }
    } catch (e) {
      EasyLoading.showError("Delete Error");
    }
  }

  // --- UI COMPONENTS ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Academic Years"),
        actions: [
          IconButton(
            onPressed: () => _openYearForm(),
            icon: const Icon(Icons.add_circle_outline, size: 28),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchYears,
              child: ListView.builder(
                itemCount: academicYears.length,
                itemBuilder: (context, index) {
                  final item = academicYears[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.calendar_month),
                      ),
                      title: Text(
                        item.yearName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("${item.startDate} to ${item.endDate}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _openYearForm(existingYear: item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(item),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _confirmDelete(AcademicYear item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Delete '${item.yearName}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteYear(item.yearId!);
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- DATE PICKER HELPER ---
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blueAccent),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // Formats date to YYYY-MM-DD for Laravel
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  void _openYearForm({AcademicYear? existingYear}) {
    final nameController = TextEditingController(
      text: existingYear?.yearName ?? "",
    );
    final descController = TextEditingController(
      text: existingYear?.description ?? "",
    );
    final startController = TextEditingController(
      text: existingYear?.startDate ?? "",
    );
    final endController = TextEditingController(
      text: existingYear?.endDate ?? "",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 25,
          right: 25,
          top: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              existingYear == null ? "Add New Year" : "Update Year",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            _buildField(nameController, "Year Name", Icons.title, false),
            const SizedBox(height: 15),
            _buildField(
              descController,
              "Description",
              Icons.description,
              false,
            ),
            const SizedBox(height: 15),
            // START DATE FIELD
            GestureDetector(
              onTap: () => _selectDate(context, startController),
              child: AbsorbPointer(
                child: _buildField(
                  startController,
                  "Start Date",
                  Icons.calendar_today,
                  true,
                ),
              ),
            ),
            const SizedBox(height: 15),
            // END DATE FIELD
            GestureDetector(
              onTap: () => _selectDate(context, endController),
              child: AbsorbPointer(
                child: _buildField(
                  endController,
                  "End Date",
                  Icons.event_available,
                  true,
                ),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    startController.text.isNotEmpty &&
                    endController.text.isNotEmpty) {
                  final yearObj = AcademicYear(
                    yearId: existingYear?.yearId,
                    yearName: nameController.text,
                    startDate: startController.text,
                    endDate: endController.text,
                    description: descController.text,
                    isDeleted: 0,
                  );
                  existingYear == null
                      ? _insertYear(yearObj)
                      : _updateYear(yearObj);
                  Navigator.pop(context);
                } else {
                  EasyLoading.showInfo("Please fill all fields");
                }
              },
              child: Text(
                existingYear == null ? "SAVE" : "UPDATE",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool isReadOnly,
  ) {
    return TextField(
      controller: controller,
      readOnly: isReadOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
