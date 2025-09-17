import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/widgets/confirmation_dialog.dart';
import 'package:harari_prosperity_app/features/faq/faq_help_screen.dart';
import 'package:harari_prosperity_app/shared/widgets/profile_item.dart';
import 'package:harari_prosperity_app/shared/services/auth_state_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    return user?.email?.split('@')[0] ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth < 500 ? double.infinity : 400;
          EdgeInsets padding = constraints.maxWidth < 500
              ? const EdgeInsets.all(12)
              : const EdgeInsets.all(20);
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: padding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, size: 50, color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _getDisplayName(), 
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                          ),
                          Text(
                            "ID: ${_authManager.getUserId()?.substring(0, 8) ?? '25030024'}", 
                            style: const TextStyle(color: Colors.grey)
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      ProfileItem(
                        icon: Icons.edit,
                        title: "Change Username",
                        onTap: () => Navigator.pushNamed(context, AppRoutes.changeUsername),
                      ),
                      ProfileItem(
                        icon: Icons.lock,
                        title: "Security",
                        onTap: () => Navigator.pushNamed(context, AppRoutes.security),
                      ),
                      ProfileItem(
                        icon: Icons.settings,
                        title: "Setting",
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.settings);
                        },
                      ),
                      ProfileItem(
                        icon: Icons.help,
                        title: "Faq and Help",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FaqHelpScreen()),
                          );
                        },
                      ),
                      ProfileItem(
                        icon: Icons.logout,
                        title: "Logout",
                        onTap: () => _showLogoutConfirmation(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: "End Session",
        message: "Are you sure you want to log out?",
        confirmText: "Yes",
        onConfirm: () async {
          Navigator.pop(context); // Close dialog
          
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
          
          try {
            await _authManager.signOut();
            if (context.mounted) {
              Navigator.pop(context); // Close loading dialog first
              // Clear all navigation stack and go to choice screen
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.choice,
                (route) => false,
              );
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(context); // Close loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logout failed: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
}