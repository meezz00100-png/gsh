import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/services/auth_state_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthStateManager _authManager = AuthStateManager();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize auth state manager
    await _authManager.initialize();
    
    // Wait for minimum splash duration
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // Navigate based on authentication status
      if (_authManager.isAuthenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.navigation);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.choice);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/prosperity_logo.png', 
              width: 160,
              errorBuilder: (context, error, stackTrace) => 
                const FlutterLogo(size: 120),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}