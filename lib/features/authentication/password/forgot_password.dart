import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/widgets/custom_button.dart';
import 'package:harari_prosperity_app/shared/widgets/responsive_widgets.dart';
import 'package:harari_prosperity_app/shared/localization/app_localizations.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.translate('forgotPasswordTitle'))),
      body: ResponsivePadding(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.translate('resetPassword'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(context.translate('forgotPasswordDescription')),
              const Divider(height: 40),
              Text(
                context.translate('enterEmailAddress'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  hintText: context.translate('emailExample'),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: CustomButton(
                  text: context.translate('next'),
                  onPressed: () {},
                  filled: true,
                ),
              ),
              const SizedBox(height: 30),
              Center(child: Text(context.translate('createAnotherAccount'))),
              const SizedBox(height: 20),
              Center(
                child: CustomButton(
                  text: context.translate('signUp'),
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.signup),
                  filled: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
