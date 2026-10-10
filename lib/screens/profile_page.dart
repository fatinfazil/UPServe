import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:upserve_flutter/screens/session_list_page.dart';
import 'edit_profile_page.dart';
import 'about_app_page.dart';

class _ProfileConstants {
  static const double avatarRadius = 60.0;
  static const double avatarSize = 120.0;
  static const EdgeInsets heroPadding = EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0);
  static const EdgeInsets contentPadding = EdgeInsets.all(24.0);
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 24.0;
  static const double spacingLarge = 40.0;
  static const double nameFontSize = 28.0;
  static const double emailFontSize = 16.0;
  static const double badgeFontSize = 14.0;
  static const double defaultAvatarFontSize = 48.0;
}

class _ProfileAvatar extends StatelessWidget {
  final User? user;

  const _ProfileAvatar(this.user);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'profile_avatar',
      child: Container(
        width: _ProfileConstants.avatarSize + 16,
        height: _ProfileConstants.avatarSize + 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.9),
              Colors.white.withValues(alpha: 0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 25,
              offset: const Offset(0, 12),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0xFF04214E).withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD8E6FF), Color(0xFFA8C5FF)],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: _ProfileConstants.avatarRadius,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: user?.photoURL != null && user!.photoURL!.isNotEmpty
                  ? Image.network(
                      user!.photoURL!,
                      width: _ProfileConstants.avatarSize,
                      height: _ProfileConstants.avatarSize,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: _ProfileConstants.avatarSize,
                          height: _ProfileConstants.avatarSize,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFD8E6FF), Color(0xFFA8C5FF)],
                            ),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF04214E),
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          _DefaultAvatar(user),
                    )
                  : _DefaultAvatar(user),
            ),
          ),
        ),
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  final User? user;

  const _DefaultAvatar(this.user);

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? '';
    final email = user?.email ?? '';

    String initial;
    String fullName;

    if (displayName.isNotEmpty) {
      final nameParts = displayName.trim().split(' ');
      if (nameParts.length >= 2) {
        initial = '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
        fullName = displayName;
      } else {
        initial = displayName.substring(0, 1).toUpperCase();
        fullName = displayName;
      }
    } else if (email.isNotEmpty) {
      initial = email.substring(0, 1).toUpperCase();
      fullName = email.split('@')[0];
    } else {
      initial = 'U';
      fullName = 'User';
    }

    return Container(
      width: _ProfileConstants.avatarSize,
      height: _ProfileConstants.avatarSize,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD8E6FF), Color(0xFFA8C5FF)],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: _ProfileConstants.defaultAvatarFontSize,
                fontWeight: FontWeight.w700,
                color: Color(0xFF04214E),
                letterSpacing: -1.2,
              ),
            ),
          ),
          if (initial.length == 1 && fullName.length > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Text(
                fullName,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF04214E).withValues(alpha: 0.6),
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  final User? user;

  const _UserInfo(this.user);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          user?.displayName ?? 'User',
          style: const TextStyle(
            fontSize: _ProfileConstants.nameFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: _ProfileConstants.spacingSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.email_outlined,
              size: 16,
              color: Colors.white.withOpacity(0.8),
            ),
            SizedBox(width: _ProfileConstants.spacingSmall),
            Flexible(
              child: Text(
                user?.email ?? '',
                style: TextStyle(
                  fontSize: _ProfileConstants.emailFontSize,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user,
            size: 18,
            color: Colors.white.withOpacity(0.9),
          ),
          SizedBox(width: _ProfileConstants.spacingSmall),
          Text(
            'Verified Account',
            style: TextStyle(
              fontSize: _ProfileConstants.badgeFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final User? user;
  final bool hasAppBar;

  const _HeroSection(this.user, {this.hasAppBar = false});

  @override
  Widget build(BuildContext context) {
    // Adjust padding when there's an AppBar
    final effectivePadding = hasAppBar
        ? const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0)
        : _ProfileConstants.heroPadding;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF04214E), Color(0xFF031D3D)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        top: hasAppBar ? false : true,
        child: Padding(
          padding: effectivePadding,
          child: Column(
            children: [
              _ProfileAvatar(user),
              SizedBox(height: _ProfileConstants.spacingMedium),
              _UserInfo(user),
              SizedBox(height: _ProfileConstants.spacingMedium),
              const _VerifiedBadge(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (mounted) {
          setState(() {
            userData = doc.exists ? doc.data() as Map<String, dynamic> : null;
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool get isStudent => userData?['role'] == 'student' || !(userData?['isInstructor'] ?? false);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Check if we can pop to determine if we should show back button
    final canPop = Navigator.canPop(context);
    final isFromTabNavigation = ModalRoute.of(context)?.settings.name == null;

    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F4EF),
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF04214E),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      // Show AppBar with back button only when navigated from other screens
      appBar: canPop && !isFromTabNavigation
          ? AppBar(
              backgroundColor: const Color(0xFF04214E),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: CustomScrollView(
        slivers: [
          // Hero Section - adjust padding when AppBar is present
          SliverToBoxAdapter(
            child: canPop && !isFromTabNavigation
                ? _HeroSection(user, hasAppBar: true)
                : _HeroSection(user),
          ),
          // Content Section
          SliverToBoxAdapter(
            child: Padding(
              padding: _ProfileConstants.contentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF04214E),
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: _ProfileConstants.spacingMedium),
                  _buildProfileOption(
                    context,
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      );
                    },
                  ),
                  // Only show My Sessions for students
                  if (isStudent)
                    _buildProfileOption(
                      context,
                      icon: Icons.help_outline,
                      title: 'My Sessions',
                      subtitle: 'View your session history',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SessionListPage(),
                          ),
                        );
                      },
                    ),
                  _buildProfileOption(
                    context,
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'Learn more about Upserve',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutAppPage(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: _ProfileConstants.spacingLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8E6FF).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF04214E), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF04214E),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF04214E).withValues(alpha: 0.6),
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: const Color(0xFF04214E).withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
