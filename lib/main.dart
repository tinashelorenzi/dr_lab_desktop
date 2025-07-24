import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/account_setup_screen.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager for desktop
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Initialize notification service
  await NotificationService().initialize();
  
  runApp(const DrLabApp());
}

class DrLabApp extends StatelessWidget {
  const DrLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dr Lab Desktop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  final _storageService = StorageService();
  final _apiService = ApiService();
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Check if user is already authenticated
      final isAuthenticated = await _apiService.isAuthenticated();
      
      if (isAuthenticated) {
        // Try to get user profile to verify token is still valid
        final profileResponse = await _apiService.getProfile();
        
        if (profileResponse.isSuccess) {
          // User is authenticated and token is valid
          final user = profileResponse.data!;
          
          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  if (user.needsAccountSetup) {
                    return AccountSetupScreen(user: user);
                  } else {
                    return DashboardScreen(user: user);
                  }
                },
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
            return;
          }
        }
      }
      
      // If we reach here, user needs to login
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    } catch (e) {
      // On any error, show login screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitializing) {
      return const SizedBox.shrink(); // Hide this widget after initialization
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1117),
              Color(0xFF161B22),
              Color(0xFF21262D),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Icon(
                Icons.medical_services_outlined,
                size: 80,
                color: AppTheme.primaryBlue,
              ),
              SizedBox(height: 32),
              
              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryBlue,
                  ),
                ),
              ),
              SizedBox(height: 24),
              
              // Loading text
              Text(
                'Initializing Dr Lab Desktop...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}