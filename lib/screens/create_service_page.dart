import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/service_service.dart';
import '../services/category_service.dart';

class CreateServicePage extends StatefulWidget {
  const CreateServicePage({super.key});

  @override
  State<CreateServicePage> createState() => _CreateServicePageState();
}

class _CreateServicePageState extends State<CreateServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _sessionDurationController = TextEditingController();
    final _tagsController = TextEditingController();
  final _prerequisitesController = TextEditingController();
  final _learningOutcomesController = TextEditingController();
  final _startDateController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _feeController = TextEditingController();


  String? _selectedCategory;
  String? _selectedDifficulty;
  String? _selectedFormat;
  List<dynamic> _categories = [];
  Map<String, dynamic>? _instructorData;
  bool _isLoading = true;
  bool _isCreating = false;

  final AuthService _authService = AuthService();
  final ServiceService _serviceService = ServiceService();
  final CategoryService _categoryService = CategoryService();

  final List<String> _difficultyLevels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _formatOptions = ['Online', 'In-Person', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _sessionDurationController.dispose();
        _tagsController.dispose();
    _prerequisitesController.dispose();
    _learningOutcomesController.dispose();
    _startDateController.dispose();
    _imageUrlController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Load categories from Firestore
      final categories = await _categoryService.getActiveCategories();

      // Get instructor data
      final instructorData = await _authService.getUserData(user.uid);

      setState(() {
        _categories = categories;
        _instructorData = instructorData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _createService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not logged in';

      final selectedCategory = _categories.firstWhere(
        (cat) => cat['id'] == _selectedCategory,
        orElse: () => <String, dynamic>{'name': 'Unknown'},
      );

      await _serviceService.createService(
        instructorId: user.uid,
        instructorName: _instructorData?['fullName'] ?? 'Instructor',
        title: _titleController.text,
        description: _descriptionController.text,
        categoryId: _selectedCategory!,
        categoryName: selectedCategory['name']?.toString() ?? 'Unknown',
        duration: _durationController.text,
        sessionDuration: int.parse(_sessionDurationController.text),
        fee: double.tryParse(_feeController.text) ?? 0,
        difficulty: _selectedDifficulty!,
        format: _selectedFormat!,
        tags: _tagsController.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList(),
        prerequisites: _prerequisitesController.text.split('\n').map((req) => req.trim()).where((req) => req.isNotEmpty).toList(),
        learningOutcomes: _learningOutcomesController.text.split('\n').map((outcome) => outcome.trim()).where((outcome) => outcome.isNotEmpty).toList(),
        schedule: [
          {'day': 'Monday', 'time': '6:00 PM'},
          {'day': 'Wednesday', 'time': '6:00 PM'},
        ],
        startDate: _startDateController.text,
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service created successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating service: $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        title: const Text(
          'Create Service or Skill',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF04214E),
          ),
        ),
        backgroundColor: const Color(0xFFF7F4EF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF04214E)),
        actions: [
          TextButton(
            onPressed: _isCreating ? null : _createService,
            child: _isCreating
                ? const CircularProgressIndicator(strokeWidth: 2)
                : const Text(
                    'Create',
                    style: TextStyle(
                      color: Color(0xFF04214E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Section
                    _buildSectionTitle('Basic Information'),
                    _buildTextField(
                      controller: _titleController,
                      label: 'Service Title',
                      hint: 'e.g., Complete JavaScript Mastery',
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter a title' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextArea(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Describe what students will learn...',
                      maxLines: 4,
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter a description' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _imageUrlController,
                      label: 'Image URL',
                      hint: 'https://example.com/image.jpg',
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 24),

                    // Course Details Section
                    _buildSectionTitle('Course Details'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _durationController,
                            label: 'Duration',
                            hint: 'e.g., 8 weeks',
                            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _sessionDurationController,
                            label: 'Session Duration',
                            hint: 'e.g., 90',
                            keyboardType: TextInputType.number,
                            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),

                      ],
                    ),
                                        const SizedBox(height: 16),


                    Row(
                      children: [
                        Expanded(child: _buildDifficultyDropdown()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFormatDropdown()),
                      ],
                    ),
                    const SizedBox(height: 24),


                    const SizedBox(height: 24),

                    // Tags and Requirements Section
                    _buildSectionTitle('Tags & Requirements'),
                    _buildTextField(
                      controller: _tagsController,
                      label: 'Tags',
                      hint: 'e.g., JavaScript, ES6, Async, DOM (comma separated)',
                    ),
                    const SizedBox(height: 16),
                    _buildTextArea(
                      controller: _prerequisitesController,
                      label: 'Prerequisites',
                      hint: 'Enter each prerequisite on a new line',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildTextArea(
                      controller: _learningOutcomesController,
                      label: 'Session Outcomes',
                      hint: 'Enter each session outcome on a new line',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    // Schedule Section
                    _buildSectionTitle('Schedule'),
                    _buildDateField(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF04214E),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF04214E)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE74C3C)),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 3,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF04214E)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE74C3C)),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF04214E)),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem<String>(
          value: category['id'],
          child: Text(
            category['name'] ?? 'Unknown',
            style: const TextStyle(color: Color(0xFF04214E)),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  Widget _buildDifficultyDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedDifficulty,
      decoration: InputDecoration(
        labelText: 'Difficulty',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF04214E)),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      items: _difficultyLevels.map((difficulty) {
        return DropdownMenuItem<String>(
          value: difficulty,
          child: Text(
            difficulty,
            style: const TextStyle(color: Color(0xFF04214E)),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDifficulty = value;
        });
      },
      validator: (value) => value == null ? 'Please select difficulty' : null,
    );
  }

  Widget _buildFormatDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedFormat,
      decoration: InputDecoration(
        labelText: 'Format',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF04214E)),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      items: _formatOptions.map((format) {
        return DropdownMenuItem<String>(
          value: format,
          child: Text(
            format,
            style: const TextStyle(color: Color(0xFF04214E)),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedFormat = value;
        });
      },
      validator: (value) => value == null ? 'Please select format' : null,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _startDateController,
      readOnly: true,
      validator: (value) => value?.isEmpty ?? true ? 'Please select start date' : null,
      decoration: InputDecoration(
        labelText: 'Start Date',
        hintText: 'Select start date',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF04214E)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE74C3C)),
        ),
        contentPadding: const EdgeInsets.all(16),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today, color: Color(0xFF04214E)),
          onPressed: _selectDate,
        ),
      ),
    );
  }
}