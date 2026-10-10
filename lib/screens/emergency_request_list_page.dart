import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/chat_page.dart';

/// ⭐ FUNCTION: Create or get an existing conversation
Future<String> getOrCreateConversationDirect(
  String userAId,
  String userBId,
  String userAName,
  String userBName,
) async {
  final query = await FirebaseFirestore.instance
      .collection('conversations')
      .where('participantIds', arrayContains: userAId)
      .get();

  // Check if chat already exists
  for (var doc in query.docs) {
    final participants = doc['participantIds'] as List;

    if (participants.contains(userBId)) {
      return doc.id;
    }
  }

  // Create new chat
  final newConvo = await FirebaseFirestore.instance
      .collection('conversations')
      .add({
    'participantIds': [userAId, userBId],
    'participantNames': {
      userAId: userAName,
      userBId: userBName,
    },
    'lastMessage': '',
    'lastMessageSenderId': '',
    'lastMessageTime': Timestamp.now(),
    'unreadCount': {
      userAId: 0,
      userBId: 0,
    },
  });

  return newConvo.id;
}

class EmergencyRequestListPage extends StatelessWidget {
  const EmergencyRequestListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF04214E),
        elevation: 0,
        title: const Text(
          "Emergency Request List",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("emergencyRequests")
            .orderBy("timestamp", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No emergency requests found."));
          }

          return ListView(
            padding: const EdgeInsets.all(14),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final requesterId = data["userId"] ?? "";
              final requesterName =
                  data["userName"] ??
                  data["userEmail"] ??
                  "Unknown User";

              final service = data["serviceNeeded"] ?? "";
              final urgency = data["urgency"] ?? "";
              final expectedTime = data["expectedTime"] ?? "";
              final desc = data["description"] ?? "";
              final price = data["price"] ?? 0;
              final status = data["status"] ?? "pending";

              final isOwner = requesterId == currentUser?.uid;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  requesterName[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    requesterName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          _statusBadge(status),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text("Urgency: $urgency"),
                      Text("Expected Time: $expectedTime"),
                      Text("Offered Price: RM $price"),

                      const SizedBox(height: 10),
                      Text(desc),

                      const SizedBox(height: 15),

                      // ACCEPT BUTTON
                      if (status == "pending" && !isOwner)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () async {
                              // 1️⃣ Update emergency request
                              await FirebaseFirestore.instance
                                  .collection("emergencyRequests")
                                  .doc(doc.id)
                                  .update({
                                "status": "accepted",
                                "acceptedBy": currentUser?.uid,
                                "acceptedAt": FieldValue.serverTimestamp(),
                              });

                              // 2️⃣ Prepare chat
                              final conversationId =
                                  await getOrCreateConversationDirect(
                                currentUser!.uid,
                                requesterId,
                                currentUser.displayName ?? "User",
                                requesterName,
                              );

                              // 3️⃣ OPEN CHAT IMMEDIATELY
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    conversationId: conversationId,
                                    otherUserId: requesterId,
                                    otherUserName: requesterName,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "ACCEPT REQUEST",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                      if (status == "accepted")
                        const Text(
                          "Already accepted",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    if (status == "pending") {
      color = Colors.orange;
    } else if (status == "accepted") color = Colors.green;
    else color = Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
