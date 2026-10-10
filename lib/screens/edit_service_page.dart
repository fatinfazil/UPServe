import 'package:flutter/material.dart';
import '../models/service.dart';
import '../services/service_service.dart';
import '../services/category_service.dart';

class EditServicePage extends StatefulWidget {
  final Service service;

  const EditServicePage({super.key, required this.service});

  @override
  State<EditServicePage> createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
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

  String? _selectedCategory;
  String? _selectedDifficulty;
  String? _selectedFormat;

  List<dynamic> _categories = [];
  bool _isLoading = true;
  bool _isSaving = false;

  final ServiceService _serviceService = ServiceService();
  final CategoryService _categoryService = CategoryService();

  final List<String> _difficultyLevels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _formatOptions = ['Online', 'In-Person', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _prefillData();
    _loadCategories();
  }

  void _prefillData() {
    final s = widget.service;

    _titleController.text = s.title;
    _descriptionController.text = s.description;
    _durationController.text = s.duration;
    _sessionDurationController.text = s.sessionDuration.toString();
    _imageUrlController.text = s.imageUrl ?? '';
    _tagsController.text = s.tags.join(', ');
    _prerequisitesController.text = s.prerequisites.join('\n');
    _learningOutcomesController.text = s.learningOutcomes.join('\n');
    _startDateController.text = s.startDate;

    _selectedCategory = s.categoryId;
    _selectedDifficulty = s.difficulty;
    _selectedFormat = s.format;
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _categoryService.getActiveCategories();
      setState(() {
        _categories = cats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_startDateController.text),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      _startDateController.text = picked.toIso8601String().split('T')[0];
    }
  }

  Future<void> _updateService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final selectedCategory = _categories.firstWhere(
      (c) => c['id'] == _selectedCategory,
      orElse: () => {'name': 'Unknown'},
    );

    final updated = widget.service.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      categoryId: _selectedCategory!,
      categoryName: selectedCategory['name'],
      duration: _durationController.text,
      sessionDuration: int.parse(_sessionDurationController.text),
      difficulty: _selectedDifficulty!,
      format: _selectedFormat!,
      tags: _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      prerequisites: _prerequisitesController.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      learningOutcomes: _learningOutcomesController.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      startDate: _startDateController.text,
      imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
    );

    await _serviceService.updateService(updated);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service updated successfully'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        title: const Text(
          'Edit Service',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF04214E)),
        ),
        backgroundColor: const Color(0xFFF7F4EF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF04214E)),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _updateService,
            child: _isSaving
                ? const CircularProgressIndicator(strokeWidth: 2)
                : const Text(
                    'Save',
                    style: TextStyle(color: Color(0xFF04214E), fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Basic Information'),
                    _buildTextField(controller: _titleController, label: 'Service Title', validator: _required),
                    const SizedBox(height: 16),
                    _buildTextArea(controller: _descriptionController, label: 'Description', validator: _required),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _imageUrlController, label: 'Image URL'),
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Course Details'),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(controller: _durationController, label: 'Duration', validator: _required)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField(controller: _sessionDurationController, label: 'Session Duration', keyboardType: TextInputType.number, validator: _required)),
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

                    _buildSectionTitle('Tags & Requirements'),
                    _buildTextField(controller: _tagsController, label: 'Tags'),
                    const SizedBox(height: 16),
                    _buildTextArea(controller: _prerequisitesController, label: 'Prerequisites'),
                    const SizedBox(height: 16),
                    _buildTextArea(controller: _learningOutcomesController, label: 'Learning Outcomes'),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Schedule'),
                    _buildDateField(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  // ================== UI HELPERS (IDENTICAL STYLE) ==================

  String? _required(String? v) => v == null || v.isEmpty ? 'Required' : null;

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF04214E)),
        ),
      );

  InputDecoration _decoration(String label, {Widget? suffix}) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF04214E))),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE74C3C))),
        contentPadding: const EdgeInsets.all(16),
        suffixIcon: suffix,
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _decoration(label),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      validator: validator,
      decoration: _decoration(label),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: _decoration('Category'),
      items: _categories.map<DropdownMenuItem<String>>((dynamic c) {
        final category = c as Map<String, dynamic>;
        return DropdownMenuItem<String>(
          value: category['id'],
          child: Text(category['name']),
        );
      }).toList(),
      onChanged: (v) => setState(() => _selectedCategory = v),
      validator: (v) => v == null ? 'Please select category' : null,
    );
  }

  Widget _buildDifficultyDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedDifficulty,
      decoration: _decoration('Difficulty'),
      items: _difficultyLevels
          .map((d) => DropdownMenuItem<String>(value: d, child: Text(d)))
          .toList(),
      onChanged: (v) => setState(() => _selectedDifficulty = v),
      validator: (v) => v == null ? 'Please select difficulty' : null,
    );
  }

  Widget _buildFormatDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedFormat,
      decoration: _decoration('Format'),
      items: _formatOptions
          .map((f) => DropdownMenuItem<String>(value: f, child: Text(f)))
          .toList(),
      onChanged: (v) => setState(() => _selectedFormat = v),
      validator: (v) => v == null ? 'Please select format' : null,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _startDateController,
      readOnly: true,
      validator: _required,
      decoration: _decoration(
        'Start Date',
        suffix: IconButton(
          icon: const Icon(Icons.calendar_today, color: Color(0xFF04214E)),
          onPressed: _selectDate,
        ),
      ),
    );
  }
}
