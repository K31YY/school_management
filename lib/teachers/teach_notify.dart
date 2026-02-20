import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class NotificationRequestScreen extends StatefulWidget {
  const NotificationRequestScreen({super.key});

  @override
  State<NotificationRequestScreen> createState() =>
      _NotificationRequestScreenState();
}

class _NotificationRequestScreenState extends State<NotificationRequestScreen> {
  // Colors
  final Color primaryBlue = const Color(0xFF4A5BF6);
  final Color backgroundGrey = const Color(0xFFF0F0F0);
  final Color textDark = const Color(0xFF333333);

  // State
  bool isRequestTab = true; // true = Request, false = Accepts
  int? expandedIndex = 0; // Tracks which item is expanded (default: first one)

  // Mock Data
  final List<Map<String, dynamic>> requests = [
    {
      "name": "Khoeurt Sokhy",
      "id": "0001",
      "date": "30/11/2025",
      "class": "10 - A",
      "reason": "Sick",
      "isExpanded": true,
    },
    {
      "name": "Rom Sarun",
      "id": "0002",
      "date": "01/12/2025",
      "class": "10 - B",
      "reason": "Family Event",
      "isExpanded": false,
    },
    {
      "name": "Neat Tina",
      "id": "0003",
      "date": "02/12/2025",
      "class": "10 - A",
      "reason": "Sick",
      "isExpanded": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Notification",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // --- 1. Custom Tab Switcher ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Row(
                children: [
                  _buildTabOption("Request", true),
                  _buildTabOption("Accepts", false),
                ],
              ),
            ),
          ),

          // --- 2. List of Requests ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                return _buildRequestCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTabOption(String text, bool isRequestBtn) {
    // Determine if this specific button is active based on state
    bool isActive = isRequestTab == isRequestBtn;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isRequestTab = isRequestBtn;
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(int index) {
    final item = requests[index];
    bool isExpanded = expandedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle: if clicking same item, collapse it. If new item, expand it.
          if (expandedIndex == index) {
            expandedIndex = null;
          } else {
            expandedIndex = index;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundGrey, // Transparent look on grey background
          // Or use Colors.white if you want card style
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Row (Avatar + Name + Arrow) ---
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.teal[200],
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: textDark,
                        ),
                      ),
                      Text(
                        "ID: ${item['id']}",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  color: Colors.black,
                ),
              ],
            ),

            // --- Expanded Content ---
            if (isExpanded) ...[
              const SizedBox(height: 16),

              // Date & Class Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        item['date'],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Class Selection",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        item['class'],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Reason
              Text(
                "Reason | ${item['reason']}",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons (Approve / Call)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Approve Button (Icon with Check)
                  Column(
                    children: [
                      const Icon(
                        Icons.person_add,
                        size: 28,
                        color: Colors.black,
                      ),
                      // Small check mark overlay logic could go here, simplified for now
                    ],
                  ),
                  // Call Button
                  const Icon(
                    Icons.phone_in_talk_outlined,
                    size: 28,
                    color: Colors.black,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
