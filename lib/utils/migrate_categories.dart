import 'dart:convert';
import 'package:flutter/services.dart';
import '../services/category_service.dart';

/// Utility class to migrate categories from JSON to Firestore
class CategoryMigrator {
  static Future<void> migrateCategoriesToFirestore() async {
    try {
      final categoryService = CategoryService();

      // Load categories from JSON file
      final categoriesString = await rootBundle.loadString('lib/data/categories.json');
      final categoriesJson = json.decode(categoriesString) as List;

      print('Starting migration of ${categoriesJson.length} categories...');

      // Add each category to Firestore using the CategoryService
      for (int i = 0; i < categoriesJson.length; i++) {
        final category = categoriesJson[i] as Map<String, dynamic>;

        await categoryService.addCategory(
          name: category['name'],
          description: category['description'],
          icon: category['icon'],
          color: category['color'],
          displayOrder: category['displayOrder'],
          isActive: category['isActive'],
          isSpecial: category['isSpecial'],
        );

        print('Migrated category ${i + 1}/${categoriesJson.length}: ${category['name']}');
      }

      print('Categories migration completed successfully!');
    } catch (e) {
      print('Error during categories migration: $e');
      rethrow; // Re-throw to allow proper error handling in UI
    }
  }

  /// Initialize categories using the CategoryService's built-in default categories
  static Future<void> initializeDefaultCategories() async {
    try {
      final categoryService = CategoryService();
      print('Initializing default categories in Firestore...');

      await categoryService.initializeDefaultCategories();

      print('Default categories initialization completed successfully!');
    } catch (e) {
      print('Error during default categories initialization: $e');
      rethrow; // Re-throw to allow proper error handling in UI
    }
  }
}