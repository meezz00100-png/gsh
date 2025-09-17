import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/widgets/custom_button.dart';
import 'package:harari_prosperity_app/shared/widgets/responsive_widgets.dart';
import 'package:harari_prosperity_app/shared/services/auth_state_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthStateManager _authManager = AuthStateManager();

  @override
  void initState() {
    super.initState();
    _authManager.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authManager.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String _getDisplayName() {
    final user = _authManager.currentUser;
    if (user?.userMetadata?['username'] != null) {
      return user!.userMetadata!['username'].toString();
    }
    return user?.email?.split('@')[0] ?? 'USER';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: ResponsivePadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48), // Increased top space
            Center(
              child: Image.asset(
                'assets/images/prosperity_logo.png',
                height: 170, // Larger logo
                width: 170,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32), // More space below logo
            Text(
              "HELLO, ${_getDisplayName()}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "Welcome to Harari Regional Prosperity Party Political Analysis System. "
              "This application helps you to share the report to prosperity party office "
              "by giving you the guidance of standards to make the report and it gives "
              "you choices like document, pictures, links to attach with your report.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            const Text(
              "TO SEND A REPORT",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Center(
              child: CustomButton(
                text: "CLICK HERE",
                onPressed: () => Navigator.pushNamed(context, AppRoutes.reportDetail),
                filled: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}