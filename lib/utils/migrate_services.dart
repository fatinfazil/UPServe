import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility class to migrate services from JSON to Firestore
class ServiceMigrator {
  static Future<void> migrateServicesToFirestore() async {
    try {
      // Load services from JSON file
      final servicesString = await rootBundle.loadString('lib/data/services.json');
      final servicesJson = json.decode(servicesString) as List;

      // Get reference to services collection
      final servicesRef = FirebaseFirestore.instance.collection('services');

      print('Starting migration of ${servicesJson.length} services...');

      // Clear existing services (optional - uncomment if you want to start fresh)
      // final existingDocs = await servicesRef.get();
      // for (var doc in existingDocs.docs) {
      //   await doc.reference.delete();
      // }

      // Add each service to Firestore
      for (int i = 0; i < servicesJson.length; i++) {
        final service = servicesJson[i] as Map<String, dynamic>;

        // Add timestamp for creation
        service['createdAt'] = FieldValue.serverTimestamp();
        service['updatedAt'] = FieldValue.serverTimestamp();

        // Add document ID as a field for reference
        service['jsonId'] = service['id'];

        // Remove the original id as Firestore will generate its own
        // But keep it for reference as jsonId
        service.remove('id');

        await servicesRef.add(service);

        print('Migrated service ${i + 1}/${servicesJson.length}: ${service['title']}');
      }

      print('Migration completed successfully!');
    } catch (e) {
      print('Error during migration: $e');
    }
  }
}