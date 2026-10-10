import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'instructor_profile_page.dart';

class AllInstructorsPage extends StatefulWidget {
  const AllInstructorsPage({super.key});

  @override
  State<AllInstructorsPage> createState() => _AllInstructorsPageState();
}

class _AllInstructorsPageState extends State<AllInstructorsPage> {
  List<Map<String, dynamic>> instructors = [];
  List<Map<String, dynamic>> filteredInstructors = [];
  bool isLoading = true;
  String searchQuery = '';
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadInstructors();
  }

  Future<void> _loadInstructors() async {
    try {
      final instructorsFromFirestore = await _authService.getInstructors();

      setState(() {
        instructors = instructorsFromFirestore.map((instructor) => {
          'id': instructor['id'],
          'name': instructor['fullName'] ?? instructor['displayName'] ?? 'Unknown',
          'rating': instructor['rating'] ?? 4.5,
          'isVerified': instructor['isInstructor'] ?? false,
          'imageUrl': instructor['imageUrl'],
          'bio': instructor['bio'] ?? 'Skilled instructor ready to share knowledge',
          'expertise': instructor['expertise'] ?? [],
          'email': instructor['email'],
          'uid': instructor['uid'],
          'responseTime': instructor['responseTime'] ?? '2 hours',
          'hourlyRate': instructor['hourlyRate'] ?? 50,
          'totalStudents': instructor['totalStudents'] ?? 0,
          'specialties': instructor['specialties'] ?? [],
          'languages': instructor['languages'] ?? ['English','Malay'],
        }).toList();

        // Sort by rating
        instructors.sort(
          (a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0),
        );
        filteredInstructors = List.from(instructors);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading providers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterInstructors(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredInstructors = List.from(instructors);
      } else {
        filteredInstructors = instructors
            .where(
              (instructor) =>
                  instructor['name'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  (instructor['bio']?.toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ?? false) ||
                              (instructor['specialties'] as List? ?? []).any(
                    (specialty) => specialty.toString().toLowerCase().contains(
                      query.toLowerCase(),
                    ),
                  ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        title: const Text(
          'All Providers',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFFFF),
          ),
        ),
        backgroundColor: const Color(0xFF04214E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: _filterInstructors,
                      decoration: InputDecoration(
                        hintText: 'Search providers by name, expertise...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF04214E),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                // Results Count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        '${filteredInstructors.length} ${filteredInstructors.length == 1 ? 'provider' : 'providers'} found',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF031D3D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Instructors List
                Expanded(
                  child: filteredInstructors.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_search,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchQuery.isEmpty
                                    ? 'No providers available'
                                    : 'No providers found for "$searchQuery"',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredInstructors.length,
                          itemBuilder: (context, index) {
                            final instructor = filteredInstructors[index];
                            return _buildInstructorCard(instructor);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildInstructorCard(Map<String, dynamic> instructor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InstructorProfilePage(instructor: instructor),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Instructor Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF04214E), Color(0xFF2C5F8D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF04214E).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    (instructor['name'] ?? '?')
                        .split(' ')
                        .map((n) => n.isNotEmpty ? n[0] : '')
                        .take(2)
                        .join()
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Instructor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Verification
Row(
  mainAxisSize: MainAxisSize.min, // Let Row take only necessary space
  children: [
    Text(
      instructor['name'] ?? '',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF04214E),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    if (instructor['isVerified'] == true) ...[
      const SizedBox(width: 6), // small space between name and icon
      const Icon(
        Icons.verified,
        color: Color(0xFF4CAF50),
        size: 20,
      ),
    ],
  ],
),


                    const SizedBox(height: 8),
                    // Bio
                    Text(
                      instructor['bio'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF031D3D),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Specialties
                    if (instructor['specialties'] != null &&
                        (instructor['specialties'] as List).isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: (instructor['specialties'] as List)
                            .take(3)
                            .map(
                              (specialty) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD8E6FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  specialty,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF04214E),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}