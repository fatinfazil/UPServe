import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../services/session_service.dart';
import '../services/service_service.dart';
import '../models/service.dart';
import 'service_details_page.dart';

class InstructorProfilePage extends StatefulWidget {
  final Map<String, dynamic> instructor;

  const InstructorProfilePage({super.key, required this.instructor});

  @override
  State<InstructorProfilePage> createState() => _InstructorProfilePageState();
}

class _InstructorProfilePageState extends State<InstructorProfilePage> {
  List<Map<String, dynamic>> instructorServices = [];
  bool isLoading = true;
  final SessionService _sessionService = SessionService();
  final ServiceService _serviceService = ServiceService();

  @override
  void initState() {
    super.initState();
    _loadInstructorServices();
  }

  Future<void> _loadInstructorServices() async {
    try {
      final instructorId = widget.instructor['id'] ?? widget.instructor['uid'];

      if (instructorId == null) {
        _loadFallbackServices();
        return;
      }

      // Load instructor services from Firestore
      final services = await _serviceService.getInstructorServices(instructorId);

      setState(() {
        instructorServices = services.map((service) => _normalizeServiceData(service)).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading instructor services from Firestore: $e');
      _loadFallbackServices();
    }
  }

  void _loadFallbackServices() async {
    try {
      // Fallback to JSON data for demo purposes
      final servicesString = await rootBundle.loadString('lib/data/services.json');
      final servicesJson = json.decode(servicesString) as List;

      setState(() {
        instructorServices = servicesJson
            .where((service) => service['instructorId'] == widget.instructor['id'])
            .map((service) => _normalizeServiceData(service))
            .cast<Map<String, dynamic>>()
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading fallback services: $e');
      setState(() {
        instructorServices = [];
        isLoading = false;
      });
    }
  }

  Map<String, dynamic> _normalizeServiceData(dynamic service) {
    if (service is Service) {
      return {
        'id': service.id,
        'title': service.title,
        'description': service.description,
        'image': service.imageUrl,
        'rating': service.rating,
        'reviews': service.reviews,
        'duration': service.duration,
        'price': 0, // Service model doesn't have price, defaulting to 0
        'category': service.categoryName,
        'instructorId': service.instructorId,
        'instructorName': service.instructorName,
        'format': service.format,
        'difficulty': service.difficulty,
        'currentStudents': service.currentStudents,
        'maxStudents': service.maxStudents ?? 10,
        'totalSessions': service.totalSessions ?? 1,
        'sessionDuration': service.sessionDuration,
      };
    } else if (service is Map<String, dynamic>) {
      return {
        'id': service['id'] ?? '',
        'title': service['title'] ?? '',
        'description': service['description'] ?? '',
        'image': service['imageUrl'] ?? service['image'] ?? '',
        'rating': service['rating'] ?? 4.5,
        'reviews': service['reviews'] ?? 0,
        'duration': service['duration'] ?? '',
        'price': service['price'] ?? 0,
        'category': service['categoryName'] ?? service['category'] ?? 'General',
        'instructorId': service['instructorId'] ?? widget.instructor['id'],
        'instructorName': service['instructorName'] ?? widget.instructor['name'] ?? 'Unknown Instructor',
        'format': service['format'] ?? 'Online',
        'difficulty': service['difficulty'] ?? 'Beginner',
        'currentStudents': service['currentStudents'] ?? 0,
        'maxStudents': service['maxStudents'] ?? 10,
        'totalSessions': service['totalSessions'] ?? 1,
        'sessionDuration': service['sessionDuration'] ?? 60,
      };
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        title: const Text(
          ' Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF04214E),
          ),
        ),
        backgroundColor: const Color(0xFFF7F4EF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF04214E)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF04214E), Color(0xFF2C5F8D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              (widget.instructor['name'] ?? '?')
                                  .split(' ')
                                  .map((n) => n.isNotEmpty ? n[0] : '')
                                  .take(2)
                                  .join()
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF04214E),
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.instructor['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (widget.instructor['isVerified'] == true) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.verified,
                                color: Color(0xFF4CAF50),
                                size: 24,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const SizedBox(height: 24),
                 // Premium Bio Section Card with Justified Text
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Container(
    width: double.infinity,
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
        // Header with icon and colored background
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF04214E),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: const [
              Icon(
                Icons.info_outline,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'About',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        // Bio Text
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            widget.instructor['bio'] ?? '',
            textAlign: TextAlign.justify, // Justified text
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF04214E),
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  ),
),



                  const SizedBox(height: 13),
                  // Specialties Section
                  if (widget.instructor['specialties'] != null &&
                      (widget.instructor['specialties'] as List).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Specialties',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF04214E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (widget.instructor['specialties'] as List)
                                .map(
                                  (specialty) => Chip(
                                    label: Text(
                                      specialty,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF04214E),
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFD8E6FF),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Services Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Services',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF04214E),
                              ),
                            ),
                            Text(
                              '${instructorServices.length} ${instructorServices.length == 1 ? 'service' : 'services'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF031D3D),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        instructorServices.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Text(
                                    'No services available yet',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: instructorServices.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final service = instructorServices[index];
                                  return _buildServiceCard(service);
                                },
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Icon(icon, color: const Color(0xFF04214E), size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF04214E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailsPage(service: service),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Service Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                service['image'] ?? '',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: const Color(0xFFD8E6FF),
                    child: const Center(
                      child: Icon(
                        Icons.school,
                        size: 36,
                        color: Color(0xFF04214E),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Service Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF04214E),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service['description'] ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          service['duration'] ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}