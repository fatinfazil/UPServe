import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/service.dart';

class ServiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ----------------------------
  // CREATE SERVICE
  // ----------------------------
  Future<String> createService({
    required String instructorId,
    required String instructorName,
    required String title,
    required String description,
    required String categoryId,
    required String categoryName,
    required String duration,
    required int sessionDuration,
    int? totalSessions,
    required String difficulty,
    required String format,
    int? maxStudents,
    required List<String> tags,
    required List<String> prerequisites,
    required List<String> learningOutcomes,
    required List<Map<String, String>> schedule,
    required String startDate,
    String? imageUrl,
    required double fee,
  }) async {
    try {
      Map<String, dynamic> serviceData = {
        'instructorId': instructorId,
        'instructorName': instructorName,
        'title': title,
        'description': description,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'duration': duration,
        'sessionDuration': sessionDuration,
        'difficulty': difficulty,
        'format': format,
        'currentStudents': 0,
        'rating': 0.0,
        'reviews': 0,
        'imageUrl': imageUrl ?? '',
        'tags': tags,
        'prerequisites': prerequisites,
        'learningOutcomes': learningOutcomes,
        'schedule': schedule,
        'startDate': startDate,
        'isAvailable': true,
        'featured': false,
        'enrolledStudents': [],
        'fee': fee,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (totalSessions != null) {
        serviceData['totalSessions'] = totalSessions;
      }
      if (maxStudents != null) {
        serviceData['maxStudents'] = maxStudents;
      }

      DocumentReference docRef =
          await _firestore.collection('services').add(serviceData);

      return docRef.id;
    } catch (e) {
      throw 'Error creating service: $e';
    }
  }

  // ----------------------------
  // GET SERVICES
  // ----------------------------

  Future<List<Service>> getInstructorServices(String instructorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('services')
          .where('instructorId', isEqualTo: instructorId)
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Service.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error: $e');
      return [];
    }
  }

  Future<List<Service>> getAllServices() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('services')
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Service.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error: $e');
      return [];
    }
  }

  Future<List<Service>> getFeaturedServices() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('services')
          .where('isAvailable', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Service.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error: $e');
      return [];
    }
  }

  Future<List<Service>> getServicesByCategory(String categoryId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('services')
          .where('categoryId', isEqualTo: categoryId)
          .where('isAvailable', isEqualTo: true)
          .orderBy('featured', descending: true)
          .orderBy('rating', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Service.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error: $e');
      return [];
    }
  }

  Future<Service?> getServiceById(String serviceId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('services').doc(serviceId).get();

      if (doc.exists) return Service.fromFirestore(doc);
      return null;
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  Future<List<Service>> getExploreServices({
    String? categoryId,
    String? difficulty,
    String? format,
    double? minRating,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection('services')
          .where('isAvailable', isEqualTo: true);

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }
      if (difficulty != null && difficulty.isNotEmpty) {
        query = query.where('difficulty', isEqualTo: difficulty);
      }
      if (format != null && format.isNotEmpty) {
        query = query.where('format', isEqualTo: format);
      }
      if (minRating != null) {
        query = query.where('rating', isGreaterThanOrEqualTo: minRating);
      }

      query = query.orderBy('featured', descending: true)
                   .orderBy('rating', descending: true);

      if (limit != null) query = query.limit(limit);

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs
          .map((doc) => Service.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error: $e');
      return [];
    }
  }

  // ----------------------------
  // UPDATE SERVICE (EDIT)
  // ----------------------------

  Future<void> updateService(Service service) async {
    try {
      await _firestore.collection('services').doc(service.id).update({
        ...service.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error updating service: $e';
    }
  }

  // ----------------------------
  // DELETE SERVICE
  // ----------------------------

  Future<void> deleteService(String serviceId) async {
    try {
      await _firestore.collection('services').doc(serviceId).delete();
    } catch (e) {
      throw 'Error deleting service: $e';
    }
  }

  // ----------------------------
  // STUDENT ENROLLMENT
  // ----------------------------

  Future<void> enrollStudent(String serviceId, String studentId) async {
    try {
      await _firestore.collection('services').doc(serviceId).update({
        'enrolledStudents': FieldValue.arrayUnion([studentId]),
        'currentStudents': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error enrolling student: $e';
    }
  }

  Future<void> unenrollStudent(String serviceId, String studentId) async {
    try {
      await _firestore.collection('services').doc(serviceId).update({
        'enrolledStudents': FieldValue.arrayRemove([studentId]),
        'currentStudents': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error unenrolling student: $e';
    }
  }

  // ----------------------------
  // TOGGLES
  // ----------------------------

  Future<void> toggleServiceAvailability(String serviceId, bool isAvailable) async {
    try {
      await _firestore.collection('services').doc(serviceId).update({
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error toggling availability: $e';
    }
  }

  Future<void> toggleFeaturedStatus(String serviceId, bool featured) async {
    try {
      await _firestore.collection('services').doc(serviceId).update({
        'featured': featured,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error toggling featured: $e';
    }
  }

  // ----------------------------
  // ADD REVIEW
  // ----------------------------

  Future<void> addReview(String serviceId, double rating) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('services').doc(serviceId).get();

      if (!doc.exists) return;

      double currentRating = doc['rating'] ?? 0.0;
      int reviews = doc['reviews'] ?? 0;

      double newRating =
          ((currentRating * reviews) + rating) / (reviews + 1);

      await _firestore.collection('services').doc(serviceId).update({
        'rating': newRating,
        'reviews': reviews + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error adding review: $e';
    }
  }
}
