import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/features/security/delete_account_dialog.dart';
import 'package:harari_prosperity_app/shared/services/auth_service.dart';
import 'package:harari_prosperity_app/shared/widgets/profile_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setting"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth < 500 ? double.infinity : 400;
          EdgeInsets padding = constraints.maxWidth < 500
              ? const EdgeInsets.all(12)
              : const EdgeInsets.all(20);
          return SingleChildScrollView(
            child: Padding(
              padding: padding,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    ProfileItem(
                      icon: Icons.delete,
                      title: "Delete Account",
                      onTap: () => _showDeleteConfirmation(context),
                    ),
                    ProfileItem(
                      icon: Icons.language,
                      title: "Language",
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.language),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final authService = AuthService();
    final userId = authService.currentUser?.id;
    showDialog(
      context: context,
      builder: (context) => DeleteAccountDialog(
        onConfirm: () async {
          if (userId != null) {
            try {
              await authService.deleteAccount(userId);
              await authService.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacementNamed(context, AppRoutes.choice);
            } catch (e) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to delete account: $e'),
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
