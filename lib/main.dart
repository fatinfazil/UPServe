import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_page.dart';
import 'screens/instructor_dashboard_page.dart';
import 'screens/profile_page.dart';
import 'screens/create_session_page.dart';
import 'screens/migration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UpServe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF04214E, const <int, Color>{
          50: Color(0xFFEFF4FF),
          100: Color(0xFFD8E6FF),
          200: Color(0xFFB3CCFF),
          300: Color(0xFF8DB3FF),
          400: Color(0xFF6699FF),
          500: Color(0xFF04214E),
          600: Color(0xFF031D3D),
          700: Color(0xFF021629),
          800: Color(0xFF011015),
          900: Color(0xFF00090A),
        }),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF04214E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F4EF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF04214E),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF04214E),
            foregroundColor: const Color(0xFFF7F4EF),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF04214E),
            side: const BorderSide(color: Color(0xFFB3CCFF)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF04214E)),
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomePage(),
        '/instructor-dashboard': (context) => const InstructorDashboardPage(),
        '/profile': (context) => const ProfilePage(),
        '/migrate': (context) => const MigrationScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/create-session') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) =>
                CreateSessionPage(service: args['service'], type: args['type']),
          );
        }
        return null;
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isOnboardingCompleted = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Check onboarding status
    final prefs = await SharedPreferences.getInstance();
    final isOnboardingCompleted =
        prefs.getBool('onboarding_completed') ?? false;

    setState(() {
      _isOnboardingCompleted = isOnboardingCompleted;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F4EF),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF04214E)),
        ),
      );
    }

    if (!_isOnboardingCompleted) {
      return const OnboardingScreen();
    }

    // Check authentication state
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF7F4EF),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF04214E)),
            ),
          );
        }

        if (snapshot.hasData) {
          // User is authenticated, check role and navigate accordingly
          return FutureBuilder<Map<String, dynamic>?>(
            future: _authService.getUserData(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFFF7F4EF),
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFF04214E)),
                  ),
                );
              }

              final userData = roleSnapshot.data;
              final isInstructor = userData?['isInstructor'] ?? false;

              // Update last login
              _updateLastLogin(snapshot.data!.uid);

              if (isInstructor) {
                return const InstructorDashboardPage();
              } else {
                return const HomePage();
              }
            },
          );
        } else {
          // User is not authenticated, go to login
          return const LoginScreen();
        }
      },
    );
  }

  Future<void> _updateLastLogin(String uid) async {
    try {
      await _authService.updateLastLogin(uid);
    } catch (e) {
      // Silently handle error
      print('Error updating last login: $e');
    }
  }
}
