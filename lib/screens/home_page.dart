import 'package:flutter/material.dart';
import 'package:upserve_flutter/screens/conversation_list_page.dart';
import 'package:upserve_flutter/screens/service_listing_page.dart'
    show ServiceListingPage;
import 'package:upserve_flutter/utils/migrate_categories.dart';
import 'main_home_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onQuickActionPressed() {
    // Show quick action dialog or bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF7F4EF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF04214E),
              ),
            ),
            const SizedBox(height: 12),
            _buildQuickActionButton(
              icon: Icons.list,
              label: 'Service and Skill Listing',
              onTap: () {
                Navigator.pop(context);
                _generateServiceListing();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFD8E6FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFB3CCFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF04214E)),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF04214E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show migration confirmation dialog
  void _showMigrationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Migrate categories to Firestore'),
        content: const Text(
          'This will migrate all categories from the JSON file to Firestore.\n\nThis should only be done once to avoid duplicate data. Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20),
                      Text('Migrating categories...'),
                    ],
                  ),
                ),
              );

              try {
                await CategoryMigrator.migrateCategoriesToFirestore();

                if (context.mounted) {
                  Navigator.of(context).pop(); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Services migrated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Migration failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF04214E),
              foregroundColor: Colors.white,
            ),
            child: const Text('Migrate'),
          ),
        ],
      ),
    );
  }

  // Quick action to generate service listing pages
  void _generateServiceListing() {
    // Logic to navigate to service listing page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceListingPage(
          categoryId: '',
          categoryName: '',
          categoryColor: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define pages for each tab
    final List<Widget> pages = [
      const MainHomePage(),
      const ProfilePage(),
      const ConversationListPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      body: pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _onQuickActionPressed,
        backgroundColor: const Color(0xFF04214E),
        shape: const CircleBorder(),
        heroTag: 'home_fab',
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.person, 'Profile', 1),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(Icons.chat_bubble, 'Messages', 2),
              _buildNavItem(Icons.settings, 'Settings', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF04214E) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFF04214E) : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
