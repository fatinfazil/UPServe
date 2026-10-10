import 'package:cloud_firestore/cloud_firestore.dart';

class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new session
  Future<String> createSession({
    required String instructorId,
    required String instructorName,
    required String title,
    required String description,
    required String category,
    required String dateTime,
    required int duration,
    required double price,
    required String imageUrl,
    required List<String> skills,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('sessions').add({
        'instructorId': instructorId,
        'instructorName': instructorName,
        'title': title,
        'description': description,
        'category': category,
        'dateTime': dateTime,
        'duration': duration,
        'price': price,
        'imageUrl': imageUrl,
        'skills': skills,
        'enrolledStudents': [],
        'maxStudents': 10,
        'rating': 0.0,
        'reviews': 0,
        'status': 'upcoming', // upcoming, ongoing, completed
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw 'Error creating session: $e';
    }
  }

  // Get all sessions for a specific instructor
  Future<List<Map<String, dynamic>>> getInstructorSessions(String instructorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('sessions')
          .where('instructorId', isEqualTo: instructorId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error getting instructor sessions: $e');
      return [];
    }
  }

  // Get all sessions (for students to browse)
  Future<List<Map<String, dynamic>>> getAllSessions() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('sessions')
          .where('status', isEqualTo: 'upcoming')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error getting all sessions: $e');
      return [];
    }
  }

  // Enroll a student in a session
  Future<void> enrollStudent(String sessionId, String studentId) async {
    try {
      await _firestore.collection('sessions').doc(sessionId).update({
        'enrolledStudents': FieldValue.arrayUnion([studentId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error enrolling student: $e';
    }
  }

  // Unenroll a student from a session
  Future<void> unenrollStudent(String sessionId, String studentId) async {
    try {
      await _firestore.collection('sessions').doc(sessionId).update({
        'enrolledStudents': FieldValue.arrayRemove([studentId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error unenrolling student: $e';
    }
  }

  // Update session details
  Future<void> updateSession(String sessionId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('sessions').doc(sessionId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error updating session: $e';
    }
  }

  // Delete a session
  Future<void> deleteSession(String sessionId) async {
    try {
      await _firestore.collection('sessions').doc(sessionId).delete();
    } catch (e) {
      throw 'Error deleting session: $e';
    }
  }

  // Update session status
  Future<void> updateSessionStatus(String sessionId, String status) async {
    try {
      await _firestore.collection('sessions').doc(sessionId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error updating session status: $e';
    }
  }
}