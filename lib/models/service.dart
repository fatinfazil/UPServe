import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String id;
  final String instructorId;
  final String instructorName;
  final String title;
  final String description;
  final String categoryId;
  final String categoryName;
  final String duration;
  final int sessionDuration;
  final int? totalSessions;
  final String difficulty;
  final String format;
  final int? maxStudents;
  final int currentStudents;
  final double rating;
  final int reviews;
  final String imageUrl;
  final List<String> tags;
  final List<String> prerequisites;
  final List<String> learningOutcomes;
  final List<Map<String, String>> schedule;
  final String startDate;
  final bool isAvailable;
  final bool featured;
  final List<String> enrolledStudents;
  final DateTime createdAt;
  final DateTime updatedAt;




  Service({
    required this.id,
    required this.instructorId,
    required this.instructorName,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.duration,
    required this.sessionDuration,
    this.totalSessions,
    required this.difficulty,
    required this.format,
    this.maxStudents,
    required this.currentStudents,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
    required this.tags,
    required this.prerequisites,
    required this.learningOutcomes,
    required this.schedule,
    required this.startDate,
    required this.isAvailable,
    required this.featured,
    required this.enrolledStudents,
    required this.createdAt,
    required this.updatedAt,

  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'instructorId': instructorId,
      'instructorName': instructorName,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'duration': duration,
      'sessionDuration': sessionDuration,
      'totalSessions': totalSessions,
      'difficulty': difficulty,
      'format': format,
      'maxStudents': maxStudents,
      'currentStudents': currentStudents,
      'rating': rating,
      'reviews': reviews,
      'imageUrl': imageUrl,
      'tags': tags,
      'prerequisites': prerequisites,
      'learningOutcomes': learningOutcomes,
      'schedule': schedule,
      'startDate': startDate,
      'isAvailable': isAvailable,
      'featured': featured,
      'enrolledStudents': enrolledStudents,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),

    };
  }

  // Create from Firestore document
  factory Service.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Service(
      id: doc.id,
      instructorId: data['instructorId'] ?? '',
      instructorName: data['instructorName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      duration: data['duration'] ?? '',
      sessionDuration: data['sessionDuration'] ?? 60,
      totalSessions: data['totalSessions'],
      difficulty: data['difficulty'] ?? 'Beginner',
      format: data['format'] ?? 'Online',
      maxStudents: data['maxStudents'],
      currentStudents: data['currentStudents'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviews: data['reviews'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      prerequisites: List<String>.from(data['prerequisites'] ?? []),
      learningOutcomes: List<String>.from(data['learningOutcomes'] ?? []),
      schedule: (data['schedule'] as List?)?.map((item) => Map<String, String>.from(item)).toList() ?? [],
      startDate: data['startDate'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      featured: data['featured'] ?? false,
      enrolledStudents: List<String>.from(data['enrolledStudents'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),

    );
  }

  // Create from Map (for local data usage)
  factory Service.fromMap(Map<String, dynamic> data, String documentId) {
    return Service(
      id: documentId,
      instructorId: data['instructorId'] ?? '',
      instructorName: data['instructorName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      duration: data['duration'] ?? '',
      sessionDuration: data['sessionDuration'] ?? 60,
      totalSessions: data['totalSessions'],
      difficulty: data['difficulty'] ?? 'Beginner',
      format: data['format'] ?? 'Online',
      maxStudents: data['maxStudents'],
      currentStudents: data['currentStudents'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviews: data['reviews'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      prerequisites: List<String>.from(data['prerequisites'] ?? []),
      learningOutcomes: List<String>.from(data['learningOutcomes'] ?? []),
      schedule: (data['schedule'] as List?)?.map((item) => Map<String, String>.from(item)).toList() ?? [],
      startDate: data['startDate'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      featured: data['featured'] ?? false,
      enrolledStudents: List<String>.from(data['enrolledStudents'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),

    );
  }

  // Copy with method for updating properties
  Service copyWith({
    String? id,
    String? instructorId,
    String? instructorName,
    String? title,
    String? description,
    String? categoryId,
    String? categoryName,
    String? duration,
    int? sessionDuration,
    int? totalSessions,
    String? difficulty,
    String? format,
    int? maxStudents,
    int? currentStudents,
    double? rating,
    int? reviews,
    String? imageUrl,
    List<String>? tags,
    List<String>? prerequisites,
    List<String>? learningOutcomes,
    List<Map<String, String>>? schedule,
    String? startDate,
    bool? isAvailable,
    bool? featured,
    List<String>? enrolledStudents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      duration: duration ?? this.duration,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      totalSessions: totalSessions ?? this.totalSessions,
      difficulty: difficulty ?? this.difficulty,
      format: format ?? this.format,
      maxStudents: maxStudents ?? this.maxStudents,
      currentStudents: currentStudents ?? this.currentStudents,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      prerequisites: prerequisites ?? this.prerequisites,
      learningOutcomes: learningOutcomes ?? this.learningOutcomes,
      schedule: schedule ?? this.schedule,
      startDate: startDate ?? this.startDate,
      isAvailable: isAvailable ?? this.isAvailable,
      featured: featured ?? this.featured,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if service has available slots
  bool get hasAvailableSlots {
    if (maxStudents == null) return true;
    return currentStudents < maxStudents!;
  }

  // Get enrollment status
  double get enrollmentProgress {
    if (maxStudents == null) return 0.0;
    return currentStudents / maxStudents!;
  }

  // Get display text for available slots
  String get availableSlotsText {
    if (maxStudents == null) return 'Unlimited slots';
    final available = maxStudents! - currentStudents;
    return '$available slots left';
  }
}