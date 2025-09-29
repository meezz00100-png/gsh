import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/widgets/confirmation_dialog.dart';
import 'package:harari_prosperity_app/features/faq/faq_help_screen.dart';
import 'package:harari_prosperity_app/shared/widgets/profile_item.dart';
import 'package:harari_prosperity_app/shared/services/auth_state_manager.dart';
import 'package:harari_prosperity_app/shared/localization/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;
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
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _getDisplayName(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "ID: ${_authManager.getUserId()?.substring(0, 8) ?? '25030024'}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 30),
                      ProfileItem(
                        icon: Icons.edit,
                        title: context.translate('editProfile'),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.changeUsername,
                        ),
                      ),
                      ProfileItem(
                        icon: Icons.lock,
                        title: context.translate('security'),
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.security),
                      ),
                      ProfileItem(
                        icon: Icons.settings,
                        title: context.translate('settings'),
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.settings);
                        },
                      ),
                      ProfileItem(
                        icon: Icons.help,
                        title: context.translate('helpAndSupport'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FaqHelpScreen(),
                            ),
                          );
                        },
                      ),
                      ProfileItem(
                        icon: Icons.logout,
                        title: context.translate('logout'),
                        onTap: () => _handleLogout(context),
                      ),
                      if (_isLoggingOut)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
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

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: context.translate('logout'),
        message: context.translate('logoutConfirmation'),
        confirmText: context.translate('yes'),
        cancelText: context.translate('no'),
        confirmColor: Colors.red,
        onConfirm: () {
          Navigator.of(context).pop(true);
        },
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Use the AuthStateManager for consistent logout
      await _authManager.signOut();
      
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
        
        // Navigate to choice screen and clear all routes
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.choice,
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error during sign out: $e');
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.translate('error')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
