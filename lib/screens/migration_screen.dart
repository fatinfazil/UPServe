import 'package:flutter/material.dart';
import '../utils/migrate_categories.dart';

class MigrationScreen extends StatelessWidget {
  const MigrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Migrate Categories to Firestore'),
        backgroundColor: const Color(0xFF04214E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.upload_file,
              size: 80,
              color: Color(0xFF04214E),
            ),
            const SizedBox(height: 20),
            const Text(
              'Category Data Migration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF04214E),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'This will migrate all categories from the JSON file to Firestore.\n\nNote: Only run this once to avoid duplicate data!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF031D3D),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                // Show confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Migration'),
                    content: const Text(
                      'Are you sure you want to migrate categories from JSON to Firestore?\n\nThis should only be done once!',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF04214E),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Migrate'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
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
                          content: Text('Categories migrated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop(); // Close loading dialog

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Categories migration failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Migrate Categories to Firestore'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF04214E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}