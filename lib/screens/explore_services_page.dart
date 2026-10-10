import 'package:flutter/material.dart';
import '../services/service_service.dart';
import '../models/service.dart';
import '../widgets/optimized_image.dart';
import 'service_details_page.dart';
import 'service_listing_page.dart';

class ExploreServicesPage extends StatefulWidget {
  const ExploreServicesPage({super.key});

  @override
  State<ExploreServicesPage> createState() => _ExploreServicesPageState();
}

class _ExploreServicesPageState extends State<ExploreServicesPage> {
  final ServiceService _serviceService = ServiceService();
  List<Service> featuredServices = [];
  List<Service> recentServices = [];
  List<Service> popularServices = [];
  bool isLoading = true;

  // Categories data
  final List<Map<String, dynamic>> categories = [
    {'id': 'coding', 'name': 'Coding', 'icon': Icons.code, 'color': '#4CAF50'},
    {'id': 'photography', 'name': 'Photography', 'icon': Icons.camera_alt, 'color': '#FF9800'},
    {'id': 'language', 'name': 'Language', 'icon': Icons.translate, 'color': '#2196F3'},
    {'id': 'design', 'name': 'Design', 'icon': Icons.palette, 'color': '#9C27B0'},
    {'id': 'business', 'name': 'Business', 'icon': Icons.business, 'color': '#F44336'},
    {'id': 'music', 'name': 'Music', 'icon': Icons.music_note, 'color': '#795548'},
  ];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final Future<List<Service>> featuredFuture = _serviceService.getFeaturedServices();
      final Future<List<Service>> recentFuture = _serviceService.getExploreServices(limit: 6);
      final Future<List<Service>> popularFuture = _serviceService.getExploreServices(minRating: 4.0, limit: 6);

      final results = await Future.wait([featuredFuture, recentFuture, popularFuture]);

      setState(() {
        featuredServices = results[0];
        recentServices = results[1];
        popularServices = results[2];
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading services: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        title: const Text(
          'Explore Services',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2416),
          ),
        ),
        backgroundColor: const Color(0xFFF7F4EF),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    onTap: () {
                      // Navigate to full search page
                    },
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Search for services...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF04214E)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Categories Section
                  _buildSectionHeader('Categories', Icons.category),
                  const SizedBox(height: 12),
                  _buildCategoriesGrid(),
                  const SizedBox(height: 24),

                  // Featured Services Section
                  if (featuredServices.isNotEmpty) ...[
                    _buildSectionHeader('Featured Services', Icons.star),
                    const SizedBox(height: 12),
                    _buildHorizontalServiceList(featuredServices),
                    const SizedBox(height: 24),
                  ],

                  // Popular Services Section
                  if (popularServices.isNotEmpty) ...[
                    _buildSectionHeader('Popular Services', Icons.trending_up),
                    const SizedBox(height: 12),
                    _buildHorizontalServiceList(popularServices),
                    const SizedBox(height: 24),
                  ],

                  // Recent Services Section
                  if (recentServices.isNotEmpty) ...[
                    _buildSectionHeader('Recent Services', Icons.access_time),
                    const SizedBox(height: 12),
                    _buildHorizontalServiceList(recentServices),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF04214E), size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF04214E),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        Color categoryColor = Color(
          int.parse(category['color'].replaceFirst('#', '0xFF')),
        );

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServiceListingPage(
                  categoryId: category['id'],
                  categoryName: category['name'],
                  categoryColor: category['color'],
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    category['icon'],
                    color: categoryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF04214E),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHorizontalServiceList(List<Service> services) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return _buildServiceCard(service);
        },
      ),
    );
  }

  Widget _buildServiceCard(Service service) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailsPage(
              service: service.toMap(),
            ),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: OptimizedImage(
                imageUrl: service.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                cacheWidth: 280 * 2, // 2x for retina displays
                cacheHeight: 120 * 2,
                errorWidget: Container(
                  height: 120,
                  width: double.infinity,
                  color: const Color(0xFFD8E6FF),
                  child: const Center(
                    child: Icon(
                      Icons.school,
                      size: 40,
                      color: Color(0xFF04214E),
                    ),
                  ),
                ),
              ),
            ),
            // Service Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF04214E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.instructorName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF031D3D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD8E6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          service.difficulty,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF04214E),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            service.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF04214E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}