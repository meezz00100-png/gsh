import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/widgets/custom_button.dart';
import 'package:harari_prosperity_app/shared/localization/app_localizations.dart';

class TermsViewScreen extends StatefulWidget {
  const TermsViewScreen({super.key});

  @override
  State<TermsViewScreen> createState() => _TermsViewScreenState();
}

class _TermsViewScreenState extends State<TermsViewScreen> {
  bool _isAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.translate('termsAndConditions'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.translate('welcomeToHarari'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(context.translate('termsDescription')),
            SizedBox(height: 20),
            Text(context.translate('termsPoint1')),
            Text(context.translate('termsPoint2')),
            Text(context.translate('termsPoint3')),
            Text(context.translate('termsPoint4')),
            SizedBox(height: 20),
            Text(context.translate('termsDescription2')),
            SizedBox(height: 20),
            Text(context.translate('termsBullet1')),
            Text(context.translate('termsBullet2')),
            SizedBox(height: 20),
            Text(context.translate('termsDescription3')),
            Divider(height: 40),
            Text(
              context.translate('readTermsMore'),
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _isAccepted,
                  onChanged: (value) {
                    setState(() {
                      _isAccepted = value ?? false;
                    });
                  },
                ),
                Expanded(child: Text(context.translate('acceptAllTerms'))),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: CustomButton(
                text: context.translate('acceptContinue'),
                onPressed: _isAccepted
                    ? () => Navigator.pushNamed(context, AppRoutes.login)
                    : null,
                filled: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
