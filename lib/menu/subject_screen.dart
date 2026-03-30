import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewsSubject extends StatefulWidget {
  const ViewsSubject({super.key});

  @override
  State<ViewsSubject> createState() => _ViewsSubjectState();
}

class _ViewsSubjectState extends State<ViewsSubject> {
  List<dynamic> _subjects = [];
  bool _isLoading = true;
  final String _baseUrl = "http://10.0.2.2:8000/api/subjects";

  final _nameCtrl = TextEditingController();
  final _levelCtrl = TextEditingController();
  final _creditCtrl = TextEditingController();
  final _hourCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  // --- Helpers ---
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('TOKEN');
    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // --- API Actions ---
  Future<void> _fetchSubjects() async {
    setState(() => _isLoading = true);
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse(_baseUrl), headers: headers);
      if (res.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(res.body);
        setState(() {
          _subjects = responseData['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        EasyLoading.showError("Failed to load subjects");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      EasyLoading.showError("Connection Failed");
    }
  }

  // --- DELETE LOGIC WITH CONFIRMATION ---
  Future<void> _deleteSubject(dynamic subID) async {
    // Show Confirmation Dialog
    bool confirm =
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Delete"),
              content: const Text(
                "Are you sure you want to delete this subject?",
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(false), // Returns false
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(true), // Returns true
                  child: const Text("Yes", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if dialog is dismissed

    if (confirm) {
      EasyLoading.show(status: 'Deleting...');
      try {
        final headers = await _getHeaders();
        final res = await http.delete(
          Uri.parse("$_baseUrl/$subID"),
          headers: headers,
        );
        if (res.statusCode == 200) {
          EasyLoading.showSuccess("Deleted successfully");
          _fetchSubjects();
        } else {
          EasyLoading.showError("Delete Failed");
        }
      } catch (e) {
        EasyLoading.showError("Network Error");
      }
    }
  }

  // --- FORM HANDLING ---
  Future<void> _saveSubject({dynamic subID}) async {
    if (_nameCtrl.text.isEmpty) {
      EasyLoading.showInfo("Subject Name is required");
      return;
    }
    EasyLoading.show(status: 'Saving...');
    final isUpdate = subID != null;
    final url = isUpdate ? "$_baseUrl/$subID" : _baseUrl;

    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        "SubName": _nameCtrl.text,
        "Level": _levelCtrl.text,
        "Credit": int.tryParse(_creditCtrl.text) ?? 0,
        "Hour": int.tryParse(_hourCtrl.text) ?? 0,
        "Description": _descCtrl.text,
      });

      final res = isUpdate
          ? await http.put(Uri.parse(url), headers: headers, body: body)
          : await http.post(Uri.parse(url), headers: headers, body: body);

      EasyLoading.dismiss();
      if (res.statusCode == 200 || res.statusCode == 201) {
        EasyLoading.showSuccess(isUpdate ? "Updated!" : "Saved!");
        if (mounted) Navigator.pop(context);
        _fetchSubjects();
      } else {
        EasyLoading.showError("Save Failed");
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError("Network Error");
    }
  }

  void _showFormSheet({Map<String, dynamic>? item}) {
    if (item != null) {
      _nameCtrl.text = item['SubName']?.toString() ?? "";
      _levelCtrl.text = item['Level']?.toString() ?? "";
      _creditCtrl.text = item['Credit']?.toString() ?? "";
      _hourCtrl.text = item['Hour']?.toString() ?? "";
      _descCtrl.text = item['Description']?.toString() ?? "";
    } else {
      _nameCtrl.clear();
      _levelCtrl.clear();
      _creditCtrl.clear();
      _hourCtrl.clear();
      _descCtrl.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item == null ? "Add New Subject" : "Update Subject",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _buildInput("Subject Name", _nameCtrl),
              _buildInput("Level", _levelCtrl),
              _buildInput("Credit", _creditCtrl, isNum: true),
              _buildInput("Hour", _hourCtrl, isNum: true),
              _buildInput("Description", _descCtrl, maxLines: 3),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5BF6),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () => _saveSubject(subID: item?['SubID']),
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController ctrl, {
    bool isNum = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subject List"),
        backgroundColor: const Color(0xFF4A5BF6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showFormSheet(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _subjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final item = _subjects[i];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    title: Text(
                      item['SubName'] ?? "Unnamed",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Level: ${item['Level']} | Credits: ${item['Credit']}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showFormSheet(item: item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteSubject(item['SubID']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
