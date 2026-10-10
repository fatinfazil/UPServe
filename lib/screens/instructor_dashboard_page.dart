import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../services/service_service.dart';
import '../services/chat_service.dart';
import '../models/service.dart';
import '../models/chat_conversation.dart';
import '../widgets/optimized_image.dart';
import 'create_service_page.dart';
import 'conversation_list_page.dart';
import 'chat_page.dart';
import 'edit_service_page.dart';


class InstructorDashboardPage extends StatefulWidget {
  const InstructorDashboardPage({super.key});

  @override
  State<InstructorDashboardPage> createState() => _InstructorDashboardPageState();
}

class _InstructorDashboardPageState extends State<InstructorDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  final SessionService _sessionService = SessionService();
  final ServiceService _serviceService = ServiceService();
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _sessions = [];
  List<Service> _services = [];
  bool _isLoading = true;
  Map<String, dynamic>? _instructorData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Get instructor data
      final instructorData = await _authService.getUserData(user.uid);
      print('Instructor data: $instructorData');

      // Get instructor sessions
      final sessions = await _sessionService.getInstructorSessions(user.uid);
      print('Sessions found: ${sessions.length}');
      for (var session in sessions) {
        print('Session: ${session['title']} - Status: ${session['status']}');
      }

      // Get instructor services
      final services = await _serviceService.getInstructorServices(user.uid);
      print('Services found: ${services.length}');

      setState(() {
        _instructorData = instructorData;
        _sessions = sessions;
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getSessionsByStatus(String status) {
    print('Filtering sessions by status: $status');
    print('Available sessions: ${_sessions.map((s) => '${s['title']}: ${s['status']}')}');

    final filteredSessions = _sessions.where((session) {
      final sessionStatus = session['status'];
      // Handle case where status might be null or missing
      if (sessionStatus == null) {
        print('Session ${session['title']} has no status');
        return false;
      }
      return sessionStatus.toString() == status;
    }).toList();

    print('Found ${filteredSessions.length} sessions with status $status');
    return filteredSessions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        title: Text(
          'Provider Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF04214E),
          ),
        ),
        backgroundColor: const Color(0xFFF7F4EF),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.person, color: Color(0xFF04214E)),
          ),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, color: Color(0xFF04214E)),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF04214E)),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.pushNamed(context, '/profile');
                  break;
                case 'logout':
                  _showLogoutDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Color(0xFF04214E)),
                    SizedBox(width: 8),
                    Text('Profile', style: TextStyle(color: Color(0xFF04214E))),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Color(0xFFE74C3C)),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Color(0xFFE74C3C))),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF04214E),
          labelColor: const Color(0xFF04214E),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Services'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Ongoing'),
            Tab(text: 'Completed'),
            Tab(text: 'Messages'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Column(
                children: [
                  // Instructor Stats
                  _buildStatsSection(),
                  // Sessions List
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildServicesList(),
                        _buildSessionsList('upcoming'),
                        _buildSessionsList('ongoing'),
                        _buildSessionsList('completed'),
                        _buildMessagesTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateServicePage(),
            ),
          );
          _loadData(); // Refresh data after creating service
        },
        backgroundColor: const Color(0xFF04214E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsSection() {
    print('Total sessions: ${_sessions.length}');
    for (var session in _sessions) {
      print('Session detail: ${session['title']} - Status: ${session['status']}');
    }

    final upcomingSessions = _getSessionsByStatus('upcoming');
    final ongoingSessions = _getSessionsByStatus('ongoing');
    final completedSessions = _getSessionsByStatus('completed');

    print('Filtered sessions - Upcoming: ${upcomingSessions.length}, Ongoing: ${ongoingSessions.length}, Completed: ${completedSessions.length}');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${_instructorData?['fullName'] ?? 'Instructor'}!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF04214E),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Upcoming',
                  '${upcomingSessions.length}',
                  Icons.upcoming,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Ongoing',
                  '${ongoingSessions.length}',
                  Icons.play_circle,
                  const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  '${completedSessions.length}',
                  Icons.check_circle,
                  const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList() {
    if (_services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No services created yet.\nTap + to create your first service!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        return _buildServiceCard(service);
      },
    );
  }

  Widget _buildSessionsList(String status) {
    final sessions = _getSessionsByStatus(status);

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(status),
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(status),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _buildSessionCard(session, status);
      },
    );
  }

  Widget _buildServiceCard(Service service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        leading: ThumbnailImage(
          imageUrl: service.imageUrl,
          size: 50,
        ),
        title: Text(
          service.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF04214E),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              service.categoryName,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildServiceDetail('Description', service.description),
                _buildServiceDetail('Duration', service.duration),
                _buildServiceDetail('Session Duration', '${service.sessionDuration} minutes'),
                _buildServiceDetail('Difficulty', service.difficulty),
                _buildServiceDetail('Format', service.format),
                const SizedBox(height: 16),
               Row(
  children: [
    // ✏️ EDIT BUTTON (LEFT)
    Expanded(
      child: OutlinedButton.icon(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditServicePage(
                service: service, // 👈 pass current service
              ),
            ),
          );
          _loadData(); // 🔄 refresh after edit
        },
        icon: const Icon(Icons.edit, size: 16),
        label: const Text('Edit'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF04214E),
          side: const BorderSide(color: Color(0xFF04214E)),
        ),
      ),
    ),

    const SizedBox(width: 12),

    // ❌ DELETE BUTTON (RIGHT)
    Expanded(
      child: OutlinedButton.icon(
        onPressed: () => _deleteService(service.id),
        icon: const Icon(Icons.delete, size: 16),
        label: const Text('Delete'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE74C3C),
          side: const BorderSide(color: Color(0xFFE74C3C)),
        ),
      ),
    ),
  ],
),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF04214E),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF031D3D)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status).withValues(alpha: 0.2),
          child: Icon(
            _getStatusIcon(status),
            color: _getStatusColor(status),
          ),
        ),
        title: Text(
          session['title'] ?? 'Untitled Session',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF04214E),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              session['description'] ?? 'No description',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSessionDetail('Date & Time', session['dateTime'] ?? 'TBD'),
                _buildSessionDetail('Duration', '${session['duration'] ?? 60} minutes'),
                _buildSessionDetail('Category', session['category'] ?? 'General'),
                // Show student details if available
                if (session['studentEmail'] != null && session['studentEmail'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF04214E).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF04214E).withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, size: 16, color: Color(0xFF04214E)),
                            SizedBox(width: 6),
                            Text(
                              'Student Details',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF04214E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildSessionDetail('Name', session['studentName'] ?? 'Not specified'),
                        _buildSessionDetail('Email', session['studentEmail']),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (status == 'upcoming') ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _updateSessionStatus(session['id'], 'ongoing'),
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text('Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (status == 'ongoing') ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _updateSessionStatus(session['id'], 'completed'),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Complete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteSession(session['id']),
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE74C3C),
                          side: const BorderSide(color: Color(0xFFE74C3C)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF04214E),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF031D3D)),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEmptyIcon(String status) {
    switch (status) {
      case 'upcoming':
        return Icons.upcoming;
      case 'ongoing':
        return Icons.play_circle;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.list;
    }
  }

  String _getEmptyMessage(String status) {
    switch (status) {
      case 'upcoming':
        return 'No upcoming sessions. Tap + to create one!';
      case 'ongoing':
        return 'No ongoing sessions';
      case 'completed':
        return 'No completed sessions yet';
      default:
        return 'No sessions';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return const Color(0xFF4CAF50);
      case 'ongoing':
        return const Color(0xFFFF9800);
      case 'completed':
        return const Color(0xFF2196F3);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'upcoming':
        return Icons.upcoming;
      case 'ongoing':
        return Icons.play_circle;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.list;
    }
  }

  Future<void> _updateSessionStatus(String sessionId, String status) async {
    try {
      await _sessionService.updateSessionStatus(sessionId, status);
      _loadData(); // Refresh data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Session status updated to $status'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating session: $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text('Are you sure you want to delete this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFE74C3C))),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _sessionService.deleteSession(sessionId);
        _loadData(); // Refresh data
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session deleted successfully'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting session: $e'),
              backgroundColor: const Color(0xFFE74C3C),
            ),
          );
        }
      }
    }
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Color(0xFFE74C3C))),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _authService.signOut();
        if (mounted) {
          // Navigate to login screen and clear all routes
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: $e'),
              backgroundColor: const Color(0xFFE74C3C),
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleServiceAvailability(String serviceId, bool isAvailable) async {
    try {
      await _serviceService.toggleServiceAvailability(serviceId, isAvailable);
      _loadData(); // Refresh data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAvailable ? 'Service is now visible' : 'Service is now hidden'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating service: $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  Future<void> _deleteService(String serviceId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFE74C3C))),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _serviceService.deleteService(serviceId);
        _loadData(); // Refresh data
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service deleted successfully'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting service: $e'),
              backgroundColor: const Color(0xFFE74C3C),
            ),
          );
        }
      }
    }
  }

  Widget _buildMessagesTab() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return const Center(
        child: Text(
          'Please login to view messages',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return StreamBuilder<List<ChatConversation>>(
      stream: _chatService.getConversationsStream(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Color(0xFFE74C3C),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading messages: ${snapshot.error}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFE74C3C),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final conversations = snapshot.data ?? [];

        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.message_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No messages yet.\nStart a conversation with your students!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConversationListPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Start Conversation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF04214E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Messages Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Conversations (${conversations.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF04214E),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConversationListPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    color: const Color(0xFF04214E),
                    tooltip: 'Start New Conversation',
                  ),
                ],
              ),
            ),
            // Conversations List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  return _buildConversationTile(conversation);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConversationTile(ChatConversation conversation) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final unreadCount = conversation.unreadCount[currentUserId] ?? 0;
    final isUnread = unreadCount > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF04214E).withValues(alpha: 0.1),
          child: Text(
            _getConversationInitial(conversation),
            style: const TextStyle(
              color: Color(0xFF04214E),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          _getConversationTitle(conversation),
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF04214E),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              conversation.lastMessage,
              style: TextStyle(
                color: isUnread ? const Color(0xFF04214E) : Colors.grey[600],
                fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(conversation.lastMessageTime),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: isUnread
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C),
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : null,
        onTap: () async {
          // Mark messages as read when opening conversation
          if (currentUserId != null && unreadCount > 0) {
            await _chatService.markMessagesAsRead(conversation.id, currentUserId);
          }

          // Navigate to chat page
          final otherUserId = conversation.participantIds
              .firstWhere((id) => id != currentUserId, orElse: () => '');

          if (otherUserId.isNotEmpty && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  conversationId: conversation.id,
                  otherUserId: otherUserId,
                  otherUserName: _getConversationTitle(conversation),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  String _getConversationTitle(ChatConversation conversation) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final otherUserId = conversation.participantIds
        .firstWhere((id) => id != currentUserId, orElse: () => '');

    return conversation.participantNames[otherUserId] ?? 'Unknown User';
  }

  String _getConversationInitial(ChatConversation conversation) {
    final title = _getConversationTitle(conversation);
    return title.isNotEmpty ? title[0].toUpperCase() : '?';
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Today ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}