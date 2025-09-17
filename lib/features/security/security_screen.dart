import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/widgets/profile_item.dart';
import 'package:harari_prosperity_app/shared/constants.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security', style: AppTextStyles.titleMedium),
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
                    ProfileItem(
                      icon: Icons.lock,
                      title: "Change Password",
                      onTap: () => Navigator.pushNamed(context, AppRoutes.passwordSettings),
                    ),
                    ProfileItem(
                      icon: Icons.description,
                      title: "Terms And Conditions",
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