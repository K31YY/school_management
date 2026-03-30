// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// --- 1. THE DATA MODEL ---
class Room {
  final int? roomId;
  final String name;
  final String location;
  final int capacity;
  final String status;

  Room({
    this.roomId,
    required this.name,
    required this.location,
    required this.capacity,
    required this.status,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomId: json['RoomID'] is int
          ? json['RoomID']
          : int.tryParse(json['RoomID']?.toString() ?? ''),
      name: json['RoomName']?.toString() ?? 'Unnamed',
      location: json['Location']?.toString() ?? 'No Location',
      capacity: json['Capacity'] is int
          ? json['Capacity']
          : int.tryParse(json['Capacity']?.toString() ?? '0') ?? 0,
      status: json['Status']?.toString() ?? "Available",
    );
  }

  Map<String, dynamic> toJson() => {
    "RoomName": name,
    "Location": location,
    "Capacity": capacity,
    "Status": status,
  };
}

// --- 2. SCREEN IMPLEMENTATION ---
class MyTimeClassroomScreen extends StatefulWidget {
  // ADDED: isReadOnly parameter to control permissions
  final bool isReadOnly;

  const MyTimeClassroomScreen({super.key, this.isReadOnly = false});

  @override
  _MyTimeClassroomScreenState createState() => _MyTimeClassroomScreenState();
}

class _MyTimeClassroomScreenState extends State<MyTimeClassroomScreen> {
  final String baseUrl = "http://10.0.2.2:8000/api";
  List<Room> roomList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pullRooms();
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

  Future<void> _pullRooms() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await http
          .get(Uri.parse("$baseUrl/rooms"), headers: await _getHeaders())
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];

        setState(() {
          roomList = data.map((json) => Room.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        _handleError("Error: ${response.statusCode}");
      }
    } catch (e) {
      _handleError("Connection Failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleError(String msg) {
    debugPrint(msg);
    EasyLoading.showError(msg);
  }

  Future<void> _insertRoom(Room newRoom) async {
    // DOUBLE CHECK: Prevent network call if read only
    if (widget.isReadOnly) return;

    EasyLoading.show(status: 'Saving...');
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/rooms"),
        headers: await _getHeaders(),
        body: jsonEncode(newRoom.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        EasyLoading.showSuccess("Room Saved!");
        if (mounted) Navigator.pop(context);
        _pullRooms();
      } else {
        final errorData = json.decode(response.body);
        EasyLoading.showError(errorData['errors']?.toString() ?? "Save Failed");
      }
    } catch (e) {
      EasyLoading.showError("Network Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text("Classroom Manager")),
        centerTitle: false,
        // MODIFIED: Only show add button if NOT read only
        actions: widget.isReadOnly
            ? null
            : [
                IconButton(
                  onPressed: _openRoomForm,
                  icon: const Icon(Icons.add_circle_outline, size: 28),
                  tooltip: "Add New Room",
                ),
                const SizedBox(width: 10),
              ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _pullRooms,
              child: roomList.isEmpty
                  ? const Center(
                      child: Text(
                        "No Rooms Found\nPull down to refresh",
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: roomList.length,
                      itemBuilder: (context, index) {
                        final item = roomList[index];
                        bool isActive =
                            item.status.toLowerCase() == "available" ||
                            item.status == "1";

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          elevation: 1,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isActive
                                  ? Colors.blue.shade100
                                  : Colors.grey.shade200,
                              child: const Icon(
                                Icons.meeting_room,
                                color: Colors.blue,
                              ),
                            ),
                            title: Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${item.location} • Cap: ${item.capacity}",
                            ),
                            trailing: Icon(
                              Icons.circle,
                              color: isActive ? Colors.green : Colors.red,
                              size: 12,
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  void _openRoomForm() {
    // SECURITY: Extra check to prevent opening form via other means
    if (widget.isReadOnly) return;

    final nameController = TextEditingController();
    final locController = TextEditingController();
    final capController = TextEditingController();

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
            const Text(
              "Add New Room",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Room Name",
                prefixIcon: Icon(Icons.label_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: locController,
              decoration: const InputDecoration(
                labelText: "Location",
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: capController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Capacity",
                prefixIcon: Icon(Icons.people_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
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
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  EasyLoading.showError("Room Name is required");
                  return;
                }
                _insertRoom(
                  Room(
                    name: nameController.text,
                    location: locController.text,
                    capacity: int.tryParse(capController.text) ?? 0,
                    status: "Available",
                  ),
                );
              },
              child: const Text(
                "SAVE",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
