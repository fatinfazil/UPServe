import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/service_service.dart';
import '../services/category_service.dart';
import '../models/service.dart';
import '../widgets/optimized_image.dart';
import 'service_details_page.dart';
import 'service_listing_page.dart';
import 'banner_detail_page.dart';
import 'instructor_profile_page.dart';
import 'all_instructors_page.dart';
import 'all_categories_page.dart';
import 'emergency_request_page.dart';
import 'emergency_request_list_page.dart';
import 'profile_page.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  List<dynamic> banners = [];
  List<dynamic> categories = [];
  List<Service> services = [];
  List<Map<String, dynamic>> instructors = [];
  bool isLoading = true;
  final AuthService _authService = AuthService();
  final ServiceService _serviceService = ServiceService();
  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  Future<void> _loadJsonData() async {
    try {
      // Load banners
      final bannersString = await rootBundle.loadString(
        'lib/data/banners.json',
      );
      final bannersJson = json.decode(bannersString);

      // Load categories from Firestore
      final categoriesFromFirestore = await _categoryService.getActiveCategories();

      // Fetch real instructors from Firestore
      final instructorsFromFirestore = await _authService.getInstructors();

      // Fetch featured services from Firestore
      final servicesFromFirestore = await _serviceService.getFeaturedServices();

      setState(() {
        banners = bannersJson;
        categories = categoriesFromFirestore;
        // Use featured services from Firestore
        services = servicesFromFirestore;
        // Use real instructors from Firestore
        instructors = instructorsFromFirestore.map((instructor) => {
          'id': instructor['id'],
          'name': instructor['fullName'] ?? instructor['displayName'] ?? 'Unknown',
          'rating': instructor['rating'] ?? 4.5, // Default rating for new instructors
          'isVerified': instructor['isInstructor'] ?? false,
          'imageUrl': instructor['imageUrl'],
          'bio': instructor['bio'] ?? 'Skilled instructor ready to share knowledge',
          'expertise': instructor['expertise'] ?? [],
          'email': instructor['email'],
          'uid': instructor['uid'],
        }).toList();

        // Sort by rating
        instructors.sort(
          (a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0),
        );
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleBannerTap(Map<String, dynamic> banner) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BannerDetailPage(banner: banner)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        title: const Text(
          'UPServe',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFFFF),
          ),
        ),
        backgroundColor: const Color(0xFF04214E),

        elevation: 0,
        actions: [
        PopupMenuButton<String>(
  icon: const Icon(
    Icons.emergency_share,
    color: Color.fromARGB(255, 206, 36, 24),
    size: 27,
  ),
  onSelected: (value) {
    if (value == 'new') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EmergencyRequestPage()),
      );
    } else if (value == 'view') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EmergencyRequestListPage()),
      );
    }
  },
  itemBuilder: (context) => [
    const PopupMenuItem(
      value: 'new',
      child: Text('Emergency Request'),
    ),
    const PopupMenuItem(
      value: 'view',
      child: Text('View All Requests'),
    ),
  ],
),


          IconButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  },
  icon: const Icon(Icons.person, color: Color.fromARGB(255, 255, 255, 255)),
),
         PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'logout') {
          try {
            await _authService.signOut();

            if (!mounted) return;

            Navigator.pushReplacementNamed(context, '/login');
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logout failed: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Color(0xFF04214E)),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
        ),
      ],
    ),
  ],
),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user?.displayName ?? user?.email ?? 'User'}!',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF04214E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Discover services and skills and get help from the best',
                      style: TextStyle(fontSize: 16, color: Color(0xFF031D3D)),
                    ),
                    const SizedBox(height: 24),
                    // Banner Carousel
                    banners.isEmpty
                        ? const SizedBox.shrink()
                        : SizedBox(
                            height: 200,
                            child: PageView.builder(
                              itemCount: banners.length,
                              controller: PageController(
                                viewportFraction: 1.0,
                              ),
                              itemBuilder: (context, index) {
                                final banner = banners[index];
                                final screenWidth = MediaQuery.of(context).size.width;
                                return Padding(
                                  padding: EdgeInsets.zero,
                                  child: GestureDetector(
                                    onTap: () {
                                      _handleBannerTap(banner);
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          OptimizedImage(
                                            imageUrl: banner['imageUrl'] ?? '',
                                            width: screenWidth,
                                            height: 200,
                                            fit: BoxFit.cover,
                                            cacheWidth: (screenWidth * 2).toInt(), // 2x for retina displays
                                            cacheHeight: 400, // 2x retina for 200px height
                                            errorWidget: Container(
                                              width: screenWidth,
                                              color: Colors.blue[(index + 2) * 100],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.image,
                                                  size: 48,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            placeholder: Container(
                                              width: screenWidth,
                                              color: Colors.grey[200],
                                              child: Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    Colors.grey[400]!,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withOpacity(0.7),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 16,
                                            left: 16,
                                            right: 16,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  banner['title'] ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  banner['description'] ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    const SizedBox(height: 32),
                    // Instructors Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Top Providers',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF04214E),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AllInstructorsPage(),
                              ),
                            );
                          },
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                    instructors.isEmpty
                        ? const Center(child: Text('No providers available'))
                        : SizedBox(
                            height: 130,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: instructors.length > 10
                                  ? 10
                                  : instructors.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                final instructor = instructors[index];
                                return _buildInstructorCard(instructor);
                              },
                            ),
                          ),
                    // Categories Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF04214E),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AllCategoriesPage(),
                              ),
                            );
                          },
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                    categories.isEmpty
                        ? const Center(child: Text('No categories available'))
                        : SizedBox(
                            height: 100,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length > 8
                                  ? 8
                                  : categories.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return _buildCategoryCard(
                                  category['id'] ?? '',
                                  category['name'] ?? '',
                                  category['color'] ?? '#3F51B5',
                                );
                              },
                            ),
                          ),
                    const SizedBox(height: 32),
                    // Featured Services Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Featured Services & Skills',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF04214E),
                          ),
                        ),
                        TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceListingPage(
          categoryId: '', // empty means all services
          categoryName: 'All Services & Skills',
          categoryColor: '#04214E', // you can pick a default color
        ),
      ),
    );
  },
  child: const Text('See all'),
),

                      ],
                    ),
                    services.isEmpty
                        ? const Center(child: Text('No services and skills available'))
                        : SizedBox(
                            height: 180,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: services.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final service = services[index];
                                return _buildServiceCard(service);
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  // Instructor Card
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
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              instructor['name'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF04214E),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,

            ),
          ],
        ),
      ),
    );
  }

  // Category Card
  Widget _buildCategoryCard(String categoryId, String title, String colorHex) {
    Color color;
    try {
      color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      color = const Color(0xFF3F51B5);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceListingPage(
              categoryId: categoryId,
              categoryName: title,
              categoryColor: colorHex,
            ),
          ),
        );
      },
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: color.computeLuminance() > 0.5
                    ? const Color(0xFF04214E)
                    : color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  // Service Card
  Widget _buildServiceCard(Service service) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailsPage(service: service.toMap()),
          ),
        );
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: OptimizedImage(
                  imageUrl: service.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  cacheWidth: 200 * 2, // 2x for retina displays
                  errorWidget: Container(
                    color: const Color(0xFFF0F4F8),
                    child: const Center(
                      child: Icon(
                        Icons.school,
                        size: 32,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Service Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          service.instructorName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    // Rating indicator
                    if (service.rating > 0)
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 10,
                            color: Color(0xFFFFA000),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            service.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
