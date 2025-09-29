import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/services/auth_state_manager.dart';
import 'package:harari_prosperity_app/shared/localization/app_localizations.dart';

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
    try {
      // Initialize auth state manager first
      await _authManager.initialize();

      // Check if user was explicitly logged out
      final wasLoggedOut = await _authManager.wasUserLoggedOut();

      if (wasLoggedOut) {
        // User was logged out, clear the flag and go to choice screen
        await _authManager.clearLogoutFlag();

        // Wait for minimum splash duration
        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.choice,
            (route) => false,
          );
        });
        return;
      }

      // Check if user has PIN set and is authenticated
      final prefs = await SharedPreferences.getInstance();
      final userId = _authManager.getUserId();
      final hasPin = userId != null ? (prefs.getBool('has_pin_$userId') ?? false) : false;

      if (hasPin && _authManager.isAuthenticated) {
        // User has PIN and is authenticated, navigate to PIN screen for verification
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed(AppRoutes.pin);
        });
        return;
      }

      // Wait for minimum splash duration
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Navigate based on authentication status
      final routeName = _authManager.isAuthenticated
          ? AppRoutes.navigation
          : AppRoutes.choice;

      // Use a post-frame callback to ensure the navigation happens after the current frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        // Clear all routes and push the new one
        Navigator.of(context).pushNamedAndRemoveUntil(
          routeName,
          (route) => false, // This removes all previous routes
        );
      });
    } catch (e) {
      debugPrint('Error in _initializeApp: $e');
      if (!mounted) return;

      // Fallback navigation in case of any error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.choice,
          (route) => false,
        );
      });
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
            Text(
              context.translate('loading'),
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
