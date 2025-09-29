import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:harari_prosperity_app/shared/localization/app_localizations.dart';
import 'package:harari_prosperity_app/shared/widgets/confirmation_dialog.dart';
import 'package:harari_prosperity_app/shared/widgets/responsive_widgets.dart';
import 'package:harari_prosperity_app/shared/services/language_service.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(context.translate('language')),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
          ),
          body: ResponsivePadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    context.translate('selectLanguage'),
                    style: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                ...languageService.supportedLanguages.map(
                  (lang) => _buildLanguageOption(
                    lang['nativeName']!,
                    lang['code']!,
                    context,
                    languageService,
                  ),
                ).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    String language,
    String languageCode,
    BuildContext context,
    LanguageService languageService,
  ) {
    final isSelected = languageService.isCurrentLanguage(languageCode);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected 
          ? const BorderSide(color: Colors.blue, width: 2)
          : BorderSide.none,
      ),
      child: RadioListTile<String>(
        title: Text(
          language,
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.blue : Colors.black,
          ),
        ),
        value: languageCode,
        groupValue: languageService.currentLocale.languageCode,
        activeColor: Colors.blue,
        onChanged: (value) {
          if (value != null) {
            _showLanguageConfirmation(context, language, languageCode, languageService);
          }
        },
      ),
    );
  }

  Future<void> _showLanguageConfirmation(
    BuildContext context,
    String language,
    String languageCode,
    LanguageService languageService,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: context.translate('language'),
        message: '${context.translate('selectLanguage')}: $language?',
        confirmText: context.translate('confirm'),
        cancelText: context.translate('cancel'),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );

    if (confirmed == true) {
      final success = await languageService.changeLanguage(languageCode);
      
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.translate('success'),
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Force rebuild of the entire app to apply new language
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.translate('error'),
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }
}