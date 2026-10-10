import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all active categories
  Future<List<Map<String, dynamic>>> getActiveCategories() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .orderBy('displayOrder', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error getting active categories: $e');
      return [];
    }
  }

  // Get all categories (including inactive)
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('categories')
          .orderBy('displayOrder', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error getting all categories: $e');
      return [];
    }
  }

  // Get category by ID
  Future<Map<String, dynamic>?> getCategoryById(String categoryId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('categories').doc(categoryId).get();
      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
      return null;
    } catch (e) {
      print('Error getting category by ID: $e');
      return null;
    }
  }

  // Add a new category
  Future<String> addCategory({
    required String name,
    required String description,
    required String icon,
    required String color,
    required int displayOrder,
    bool isActive = true,
    bool isSpecial = false,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('categories').add({
        'name': name,
        'description': description,
        'icon': icon,
        'color': color,
        'displayOrder': displayOrder,
        'isActive': isActive,
        'isSpecial': isSpecial,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw 'Error adding category: $e';
    }
  }

  // Update category
  Future<void> updateCategory(String categoryId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('categories').doc(categoryId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error updating category: $e';
    }
  }

  // Delete category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
    } catch (e) {
      throw 'Error deleting category: $e';
    }
  }

  // Toggle category active status
  Future<void> toggleCategoryStatus(String categoryId, bool isActive) async {
    try {
      await _firestore.collection('categories').doc(categoryId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error toggling category status: $e';
    }
  }

  // Initialize categories with default data (call this once to setup Firestore)
  Future<void> initializeDefaultCategories() async {
    try {
      final defaultCategories = [
        {
          'name': 'Coding & Programming',
          'description': 'Learn programming languages, web development, mobile apps, and software engineering',
          'icon': 'coding_icon',
          'color': '#3F51B5',
          'displayOrder': 5,
          'isActive': true,
          'isSpecial': false,
        },
        {
          'name': 'Photography',
          'description': 'Master photography techniques, editing, and visual storytelling',
          'icon': 'photography_icon',
          'color': '#607D8B',
          'displayOrder': 6,
          'isActive': true,
          'isSpecial': false,
        },
        {
          'name': 'Language Learning',
          'description': 'Learn new languages and improve communication skills',
          'icon': 'language_icon',
          'color': '#E91E63',
          'displayOrder': 7,
          'isActive': true,
          'isSpecial': false,
        },
        {
          'name': 'Graphic Design',
          'description': 'Create stunning visuals, UI/UX design, and digital art',
          'icon': 'design_icon',
          'color': '#009688',
          'displayOrder': 8,
          'isActive': true,
          'isSpecial': false,
        },
        {
          'name': 'Music & Audio',
          'description': 'Learn instruments, music production, and audio engineering',
          'icon': 'music_icon',
          'color': '#795548',
          'displayOrder': 9,
          'isActive': true,
          'isSpecial': false,
        },
        {
          'name': 'Business & Marketing',
          'description': 'Develop business skills, marketing strategies, and entrepreneurship',
          'icon': 'business_icon',
          'color': '#FF5722',
          'displayOrder': 10,
          'isActive': true,
          'isSpecial': false,
        },
        {
          'name': 'Cooking & Culinary',
          'description': 'Master culinary arts and cooking techniques',
          'icon': 'cooking_icon',
          'color': '#8BC34A',
          'displayOrder': 11,
          'isActive': true,
          'isSpecial': false,
        },
        {
          'name': 'Fitness & Wellness',
          'description': 'Achieve your health and fitness goals',
          'icon': 'fitness_icon',
          'color': '#CDDC39',
          'displayOrder': 12,
          'isActive': true,
          'isSpecial': false,
        },
        {
          'name': 'Writing & Content',
          'description': 'Improve your writing and content creation skills',
          'icon': 'writing_icon',
          'color': '#FFC107',
          'displayOrder': 13,
          'isActive': true,
          'isSpecial': false,
        },
        {
          'name': 'Data Science & Analytics',
          'description': 'Analyze data and derive actionable insights',
          'icon': 'data_icon',
          'color': '#673AB7',
          'displayOrder': 14,
          'isActive': true,
          'isSpecial': false,
        },
      ];

      for (final category in defaultCategories) {
        await addCategory(
          name: category['name']?.toString() ?? '',
          description: category['description']?.toString() ?? '',
          icon: category['icon']?.toString() ?? '',
          color: category['color']?.toString() ?? '',
          displayOrder: (category['displayOrder'] as num?)?.toInt() ?? 0,
          isActive: category['isActive'] as bool? ?? true,
          isSpecial: category['isSpecial'] as bool? ?? false,
        );
      }
    } catch (e) {
      throw 'Error initializing default categories: $e';
    }
  }
}