import 'package:flutter/material.dart';
import 'service_details_page.dart';
import '../services/service_service.dart';
import '../models/service.dart';
import '../widgets/optimized_image.dart';

class ServiceListingPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String categoryColor;

  const ServiceListingPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
  });

  @override
  State<ServiceListingPage> createState() => _ServiceListingPageState();
}

class _ServiceListingPageState extends State<ServiceListingPage> {
  final ServiceService _serviceService = ServiceService();
  List<Service> services = [];
  List<Service> filteredServices = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      List<Service> servicesList;

      if (widget.categoryId.isEmpty && widget.categoryName.isEmpty) {
        // Show all services if both categoryId and categoryName are empty
        servicesList = await _serviceService.getExploreServices();
      } else {
        // Filter by specific category
        servicesList = await _serviceService.getExploreServices(categoryId: widget.categoryId);
      }

      setState(() {
        services = servicesList;
        filteredServices = servicesList;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading services: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterServices(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredServices = services;
      } else {
        filteredServices = services
            .where(
              (service) =>
                  service.title.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  service.instructorName.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color categoryColor;
    try {
      categoryColor = Color(
        int.parse(widget.categoryColor.replaceFirst('#', '0xFF')),
      );
    } catch (e) {
      categoryColor = const Color(0xFF3F51B5);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: _filterServices,
                    decoration: InputDecoration(
                      hintText: 'Search service or skill...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF04214E),
                      ),
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
                ),
                // Category Badge
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: categoryColor.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.categoryName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: categoryColor.computeLuminance() > 0.5
                                    ? const Color(0xFF04214E)
                                    : categoryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${filteredServices.length})',
                              style: TextStyle(
                                fontSize: 14,
                                color: categoryColor.computeLuminance() > 0.5
                                    ? const Color(0xFF04214E)
                                    : categoryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Services List
                Expanded(
                  child: filteredServices.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchQuery.isEmpty
                                    ? 'No services available in this category'
                                    : 'No services found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredServices.length,
                          itemBuilder: (context, index) {
                            final service = filteredServices[index];
                            return _buildServiceCard(service);
                          },
                        ),
                ),
              ],
            ),
    );
  }

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
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: ThumbnailImage(
                imageUrl: service.imageUrl,
                size: 120,
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
                      service.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF04214E),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.instructorName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF031D3D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD8E6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            service.difficulty,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF04214E),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          service.duration,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
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
