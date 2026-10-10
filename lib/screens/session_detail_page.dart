import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SessionDetailPage extends StatefulWidget {
  final String sessionId;
  final Map<String, dynamic> sessionData;

  const SessionDetailPage({
    super.key,
    required this.sessionId,
    required this.sessionData,
  });

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  bool _isJoined = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserIsJoined();
  }

  Future<void> _checkIfUserIsJoined() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final sessionRef = FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId);
    final sessionDoc = await sessionRef.get();

    if (sessionDoc.exists) {
      final data = sessionDoc.data() as Map<String, dynamic>;
      final enrolledStudents = List<String>.from(data['enrolledStudents'] ?? []);

      setState(() {
        _isJoined = enrolledStudents.contains(user.uid);
      });
    }
  }

  Future<void> _toggleJoinSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to join this session'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final sessionRef = FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId);
      final sessionDoc = await sessionRef.get();

      if (!sessionDoc.exists) {
        throw Exception('Session not found');
      }

      final data = sessionDoc.data() as Map<String, dynamic>;
      final enrolledStudents = List<String>.from(data['enrolledStudents'] ?? []);
      final maxStudents = data['maxStudents'] as int;

      if (_isJoined) {
        // Leave session
        enrolledStudents.remove(user.uid);
        await sessionRef.update({
          'enrolledStudents': enrolledStudents,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          _isJoined = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have left the session'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      } else {
        // Join session
        if (enrolledStudents.length >= maxStudents) {
          throw Exception('Session is full');
        }

        enrolledStudents.add(user.uid);
        await sessionRef.update({
          'enrolledStudents': enrolledStudents,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          _isJoined = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have joined the session successfully!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'No date set';

    DateTime parsedDateTime;

    if (dateTime is Timestamp) {
      parsedDateTime = dateTime.toDate();
    } else if (dateTime is String) {
      // Try to parse string as DateTime
      try {
        parsedDateTime = DateTime.parse(dateTime);
      } catch (e) {
        return dateTime.toString(); // Return as-is if parsing fails
      }
    } else {
      return 'Invalid date format';
    }

    return '${parsedDateTime.day}/${parsedDateTime.month}/${parsedDateTime.year} at ${parsedDateTime.hour.toString().padLeft(2, '0')}:${parsedDateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getSessionTypeColor(String type) {
    return type == 'teach' ? const Color(0xFF3F51B5) : const Color(0xFF04214E);
  }

  IconData _getSessionTypeIcon(String type) {
    return type == 'teach' ? Icons.person_pin_circle : Icons.school;
  }

  String _getSessionTypeText(String type) {
    return type == 'teach' ? 'Give Help Session' : 'Get Help Session';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return const Color(0xFF2196F3);
      case 'ongoing':
        return const Color(0xFF4CAF50);
      case 'completed':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF757575);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'upcoming':
        return Icons.schedule;
      case 'ongoing':
        return Icons.play_circle;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'upcoming':
        return 'Upcoming';
      case 'ongoing':
        return 'Ongoing';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.sessionData;
    final isOwner = FirebaseAuth.instance.currentUser?.uid == data['instructorId'];
    final sessionType = data['type'] as String? ?? 'get help';
    final sessionStatus = data['status'] as String? ?? 'upcoming';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        title: const Text(
          'Session Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2416),
          ),
        ),
        backgroundColor: const Color(0xFFF7F4EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF04214E)),
          onPressed: () => Navigator.pop(context),
        ),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Type and Status Badges
            Row(
              children: [
                // Session Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getSessionTypeColor(sessionType),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getSessionTypeIcon(sessionType),
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getSessionTypeText(sessionType),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Session Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(sessionStatus),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(sessionStatus),
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getStatusText(sessionStatus),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Session Title
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF04214E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.event,
                          color: Color(0xFF04214E),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title'] ?? 'Untitled Session',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C2416),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['serviceName'] ?? 'Service',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  if (data['description'] != null && data['description'].toString().isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2416),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['description'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2C2416),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Session Information
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.access_time,
                    'Date & Time',
                    _formatDateTime(data['dateTime']),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.schedule,
                    'Duration',
                    '${data['duration'] ?? 60} minutes',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.location_on,
                    'Format',
                    data['format'] ?? 'Not specified',
                  ),
                  if (data['location'] != null && data['location'].toString().isNotEmpty) ...[
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.place,
                      'Location',
                      data['location'],
                    ),
                  ],
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.person,
                    'Organizer',
                    data['instructorName'] ?? data['instructorEmail'] ?? 'Unknown',
                  ),
                  // Show student details if available (for learning sessions)
                  if (data['studentEmail'] != null && data['studentEmail'].toString().isNotEmpty) ...[
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.school,
                      'Student',
                      data['studentName'] ?? 'Not specified',
                    ),
                    if (data['studentEmail'] != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.email,
                        'Student Email',
                        data['studentEmail'],
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF04214E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF04214E),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2C2416),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}