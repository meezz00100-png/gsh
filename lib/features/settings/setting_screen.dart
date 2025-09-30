import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/features/security/delete_account_dialog.dart';
import 'package:harari_prosperity_app/shared/services/auth_service.dart';
import 'package:harari_prosperity_app/shared/widgets/profile_item.dart';
import 'package:harari_prosperity_app/shared/localization/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('settings')),
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
                      icon: Icons.language,
                      title: context.translate('language'),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.language),
                    ),
                    const SizedBox(height: 10),
                    ProfileItem(
                      icon: Icons.delete,
                      title: context.translate('deleteAccount'),
                      onTap: () => _showDeleteConfirmation(context),
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

  void _showDeleteConfirmation(BuildContext context) async {
    final authService = AuthService();
    final user = await authService.getCurrentUser();
    final userId = user?.id;
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User not authenticated')));
      return;
    }
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
                  content: Text(
                    context.translate('failedToDeleteAccount'),
                  ), // Localized error
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
