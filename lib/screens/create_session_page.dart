import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateSessionPage extends StatefulWidget {
  final Map<String, dynamic> service;
  final String type; // 'learn' or 'teach'

  const CreateSessionPage({
    super.key,
    required this.service,
    required this.type,
  });

  @override
  State<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedDuration = '1 hour';
  String _selectedFormat = 'Online';
  int _maxParticipants = 1;
  bool _isLoading = false;

  final List<String> _durations = [
    '30 minutes',
    '1 hour',
    '1.5 hours',
    '2 hours',
    '3 hours',
  ];

  final List<String> _formats = ['Online', 'In-Person', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.type == 'teach'
        ? 'Service/Skill: ${widget.service['title']}'
        : 'Service/Skill: ${widget.service['title']}';
  }

  int _getDurationInMinutes(String duration) {
    switch (duration) {
      case '30 minutes':
        return 30;
      case '1 hour':
        return 60;
      case '1.5 hours':
        return 90;
      case '2 hours':
        return 120;
      case '3 hours':
        return 180;
      default:
        return 60;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF04214E),
              onPrimary: Colors.white,
              onSurface: Color(0xFF04214E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF04214E),
              onPrimary: Colors.white,
              onSurface: Color(0xFF04214E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveSession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Combine date and time
      final sessionDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Create session data
      final sessionData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'serviceId': widget.service['id'],
        'serviceName': widget.service['title'],
        'categoryId': widget.service['categoryId'],
        'type': widget.type, // 'learn' or 'teach'
        'instructorId': widget.service['instructorId'],
        'instructorEmail': widget.service['instructorEmail'],
        'instructorName': widget.service['instructorName'] ?? 'Instructor',
        'imageUrl': widget.service['imageUrl'] ?? '',
        'skills': widget.service['skills'] ?? [],
        'category': widget.service['categoryName'] ?? 'General',
        'dateTime': sessionDateTime.toString(),
        'duration': _getDurationInMinutes(_selectedDuration),
        'format': _selectedFormat,
        'location': _locationController.text.trim(),
        'price': 0.0, // Sessions are free
        // For learning sessions, maxParticipants is always 1
        'maxStudents': widget.type == 'learn' ? 1 : _maxParticipants,
        'enrolledStudents': [],
        'status': 'upcoming', // upcoming, ongoing, completed
        'rating': 0.0,
        'reviews': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'studentId': widget.type == 'learn' ? user.uid : null,
        'studentEmail': widget.type == 'learn' ? user.email : null,
        'studentName': widget.type == 'learn' ? (user.displayName ?? 'Student') : null,
      };

      // Save to Firestore
      await FirebaseFirestore.instance.collection('sessions').add(sessionData);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.type == 'teach'
                  ? 'Session created successfully!'
                  : 'Session created successfully!',
            ),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );

        // Navigate back to home
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating session: ${e.toString()}'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        title: Text(
          widget.type == 'teach'
              ? 'Create Session'
              : 'Create Session',
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Session Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: widget.type == 'teach'
                          ? const Color(0xFF3F51B5)
                          : const Color(0xFF04214E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.type == 'teach'
                              ? Icons.person_pin_circle
                              : Icons.school,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.type == 'teach'
                              ? 'Give Help Mode'
                              : 'Get Help Mode',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Session Title',
                      hintText: 'Enter session title',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe what students want to learn or get from this session',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Date and Time
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                      color: Color(0xFF04214E),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _selectedDate == null
                                          ? 'Select date'
                                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _selectedDate == null
                                            ? Colors.grey
                                            : const Color(0xFF04214E),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Time',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 18,
                                      color: Color(0xFF04214E),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _selectedTime == null
                                          ? 'Select time'
                                          : _selectedTime!.format(context),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _selectedTime == null
                                            ? Colors.grey
                                            : const Color(0xFF04214E),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Duration
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDuration,
                    decoration: InputDecoration(
                      labelText: 'Duration',
                      prefixIcon: const Icon(Icons.schedule),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _durations.map((duration) {
                      return DropdownMenuItem(
                        value: duration,
                        child: Text(duration),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDuration = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Format
                  DropdownButtonFormField<String>(
                    initialValue: _selectedFormat,
                    decoration: InputDecoration(
                      labelText: 'Format',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _formats.map((format) {
                      return DropdownMenuItem(
                        value: format,
                        child: Text(format),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFormat = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Location
                  if (_selectedFormat != 'Online')
                    Column(
                      children: [
                        TextFormField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            labelText: 'Location',
                            hintText: 'Enter meeting location',
                            prefixIcon: const Icon(Icons.place),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (_selectedFormat != 'Online' &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Please enter a location';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  // (Price field removed – sessions are free)
                  // Max Participants (only for teaching sessions)
                  if (widget.type == 'teach')
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Max Participants',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF04214E),
                                ),
                              ),
                              Text(
                                '$_maxParticipants',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF04214E),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Slider(
                            value: _maxParticipants.toDouble(),
                            min: 1,
                            max: 20,
                            divisions: 19,
                            activeColor: const Color(0xFF04214E),
                            onChanged: (value) {
                              setState(() {
                                _maxParticipants = value.toInt();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 30),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF04214E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Create Session',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
