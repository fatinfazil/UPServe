import 'package:flutter/material.dart';
import '../utils/migrate_services.dart';

// Temporary widget to add to any screen for migration
class MigrationButton extends StatelessWidget {
  const MigrationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Migrating services...'),
              ],
            ),
          ),
        );

        try {
          await ServiceMigrator.migrateServicesToFirestore();

          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Services migrated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Migration failed: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      backgroundColor: Colors.orange,
      tooltip: 'Migrate Services to Firestore',
      child: const Icon(Icons.cloud_upload),
    );
  }
}