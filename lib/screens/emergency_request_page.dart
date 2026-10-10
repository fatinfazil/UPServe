import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyRequestPage extends StatefulWidget {
  const EmergencyRequestPage({super.key});

  @override
  _EmergencyRequestPageState createState() => _EmergencyRequestPageState();
}

class _EmergencyRequestPageState extends State<EmergencyRequestPage> {
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController expectedTimeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String urgency = "Low";
  bool isLoading = false;

  Future<void> submitERS() async {
    if (serviceController.text.isEmpty ||
        priceController.text.isEmpty ||
        expectedTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all required fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection("emergencyRequests").add({
      "serviceNeeded": serviceController.text.trim(),
      "price": double.tryParse(priceController.text.trim()) ?? 0,
      "urgency": urgency,
      "expectedTime": expectedTimeController.text.trim(),
      "description": descriptionController.text.trim(),
      "status": "pending",
      "userId": user?.uid,
      "userName": user?.displayName ?? "Unknown User",
      "userEmail": user?.email ?? "unknown@mail.com",
      "timestamp": FieldValue.serverTimestamp(),
      "acceptedBy": null,
      "acceptedAt": null,
    });

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Emergency Request Submitted!")),
    );

    Navigator.pop(context);
  }

  Color getUrgencyColor(String level) {
    switch (level) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF04214E),
        elevation: 0,
        title: const Text(
          "Emergency Request  🚨",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // SERVICE
            _buildCardField(
              icon: Icons.push_pin,
              label: "Service Needed",
              child: TextField(
                controller: serviceController,
                decoration: const InputDecoration(
                  hintText: "e.g., printing, repairing, cleaning",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // PRICE
            _buildCardField(
              icon: Icons.attach_money,
              label: "Offered Price (RM)",
              child: TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "e.g., 20",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // EXPECTED TIME
            _buildCardField(
              icon: Icons.access_time,
              label: "Expected Time",
              child: TextField(
                controller: expectedTimeController,
                decoration: const InputDecoration(
                  hintText: "e.g., 30 minutes",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // URGENCY
            _buildCardField(
              icon: Icons.priority_high,
              label: "Urgency Level",
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: urgency,
                  isExpanded: true,
                  items: ["Low", "Medium", "High"]
                      .map((u) => DropdownMenuItem(
                            value: u,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: getUrgencyColor(u).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                u,
                                style: TextStyle(
                                  color: getUrgencyColor(u),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => urgency = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // DESCRIPTION
            _buildCardField(
              icon: Icons.note_alt,
              label: "Description (Optional)",
              child: TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Add extra details to help the helper…",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF04214E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isLoading ? null : submitERS,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit Request",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to create card-style field
  Widget _buildCardField(
      {required IconData icon, required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF04214E)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF04214E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
