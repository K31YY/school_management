import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StuClass extends StatefulWidget {
  const StuClass({super.key});

  @override
  State<StuClass> createState() => _StuClassState();
}

class _StuClassState extends State<StuClass> {
  List<dynamic> schedules = [];
  bool isLoading = true;
  String errorMessage = "";

  // 1. MUST match your computer's IP.
  // Ensure Laravel is running with: php artisan serve --host=0.0.0.0
  final String serverIp = "192.168.1.13";

  @override
  void initState() {
    super.initState();
    fetchSchedules();
  }

  Future<void> fetchSchedules() async {
    // Safety check before starting
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final sp = await SharedPreferences.getInstance();
      final token = sp.getString('TOKEN');
      final apiUrl = 'http://$serverIp:8000/api/schedules';

      final response = await http
          .get(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      // FIXED: Check if widget is still in the tree after the network await
      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        setState(() {
          schedules = decodedData['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Server Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      // FIXED: Check mounted in catch block to prevent crash on setState
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            "Cannot connect to $serverIp. \nEnsure Laravel is running with --host=0.0.0.0";
      });
      // Helpful for you to see the real error in VS Code console
      debugPrint("Fetch Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(
          "My Class Schedule",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4A5BF6),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchSchedules,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? _buildErrorState()
            : schedules.isEmpty
            ? _buildEmptyState()
            : _buildList(),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      // FIXED: Added physics so RefreshIndicator works even with short lists
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: schedules.length,
      itemBuilder: (context, index) => _buildScheduleCard(schedules[index]),
    );
  }

  Widget _buildScheduleCard(dynamic item) {
    final subject = item['subject']?['SubjectName'] ?? 'No Subject';
    final teacher = item['teacher']?['FullName'] ?? 'No Teacher';
    final startTime = item['StartTime'] ?? '--:--';
    final endTime = item['EndTime'] ?? '--:--';
    final day = item['DayOfWeek'] ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.book)),
        title: Text(
          "$subject ($day)",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Teacher: $teacher\nTime: $startTime - $endTime"),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildEmptyState() {
    // FIXED: Wrapped in ListView so you can pull-to-refresh when empty
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Icon(Icons.calendar_today, size: 60, color: Colors.grey),
        const SizedBox(height: 10),
        Center(
          child: Text(
            "No schedules found",
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    // FIXED: Wrapped in ListView so you can pull-to-refresh to retry
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Icon(Icons.wifi_off, color: Colors.red, size: 60),
        const SizedBox(height: 10),
        Text(errorMessage, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: ElevatedButton(
            onPressed: fetchSchedules,
            child: const Text("Try Again"),
          ),
        ),
      ],
    );
  }
}
