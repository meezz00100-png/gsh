import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/widgets/profile_item.dart';
import 'package:harari_prosperity_app/shared/constants.dart';
import 'package:harari_prosperity_app/shared/localization/app_localizations.dart';
import 'package:harari_prosperity_app/shared/services/auth_state_manager.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _hasPin = false;

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh PIN status when returning to this screen
    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final authManager = AuthStateManager();
    final userId = authManager.getUserId();
    final hasPin = userId != null ? (prefs.getBool('has_pin_$userId') ?? false) : false;
    setState(() {
      _hasPin = hasPin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('securityTitle'), style: AppTextStyles.titleMedium),
        elevation: 0,
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: Colors.black),
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
                    // Set PIN option - only enabled when user doesn't have PIN
                    ProfileItem(
                      icon: Icons.pin,
                      title: context.translate('set_pin'),
                      onTap: _hasPin
                          ? null // Disabled when user already has PIN
                          : () => Navigator.pushNamed(
                              context,
                              AppRoutes.pin,
                              arguments: false, // isChangingPin = false
                            ),
                      enabled: !_hasPin, // Visually indicate disabled state
                    ),
                    // Change PIN option - only enabled when user has PIN
                    ProfileItem(
                      icon: Icons.pin,
                      title: context.translate('change_pin'),
                      onTap: !_hasPin
                          ? null // Disabled when user doesn't have PIN
                          : () => Navigator.pushNamed(
                              context,
                              AppRoutes.pin,
                              arguments: true, // isChangingPin = true
                            ),
                      enabled: _hasPin, // Visually indicate disabled state
                    ),
                    ProfileItem(
                      icon: Icons.lock,
                      title: context.translate('changePassword'),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.passwordSettings),
                    ),
                    ProfileItem(
                      icon: Icons.description,
                      title: context.translate('termsAndConditions'),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.terms),
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
}
