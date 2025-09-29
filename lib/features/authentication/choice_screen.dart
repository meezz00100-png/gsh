import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/widgets/custom_button.dart';
import 'package:harari_prosperity_app/shared/localization/app_localizations.dart';

class ChoiceScreen extends StatelessWidget {
  const ChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth < 500 ? double.infinity : 400;
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: Image.asset(
                        'assets/images/prosperity_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const FlutterLogo(size: 120),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 250,
                      height: 50,
                      child: CustomButton(
                        text: context.translate('login'),
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.login),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(context.translate('or')),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      height: 36,
                      child: CustomButton(
                        text: context.translate('signup'),
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
        },
      ),
    );
  }
}
