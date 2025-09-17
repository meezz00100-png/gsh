import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/shared/widgets/confirmation_dialog.dart';
import 'package:harari_prosperity_app/shared/widgets/responsive_widgets.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? _selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Language")),
      body: ResponsivePadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Which Language Do\nYou Want To Change",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            _buildLanguageOption("English", context),
            _buildLanguageOption("Oromya", context),
            _buildLanguageOption("Amharic", context),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: RadioListTile<String>(
        title: Text(language, style: const TextStyle(fontSize: 18)),
        value: language,
        groupValue: _selectedLanguage,
        onChanged: (value) {
          setState(() {
            _selectedLanguage = value;
          });
          _showLanguageConfirmation(context, language);
        },
      ),
    );
  }

  void _showLanguageConfirmation(BuildContext context, String language) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: "Language",
        message: "Are you sure you want to change?",
        selectedOption: language,
        confirmText: "Yes",
        onConfirm: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Language changed to $language")),
          );
        },
      ),
    );
  }
}