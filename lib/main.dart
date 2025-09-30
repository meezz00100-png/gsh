import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'shared/constants.dart';
import 'shared/config/api_config.dart';
import 'shared/localization/app_localizations.dart';
import 'shared/services/language_service.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientation to portrait only
  const bool isTest = bool.fromEnvironment('dart.vm.product') == false;
  if (!isTest) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  // Run the app
  runApp(const ProsperityApp());
}

// Fallback delegates for unsupported locales
class FallbackCupertinoLocalisationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalisationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    return const DefaultCupertinoLocalizations();
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<CupertinoLocalizations> old,
  ) => false;
}

class FallbackMaterialLocalisationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalisationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return DefaultMaterialLocalizations();
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<MaterialLocalizations> old,
  ) => false;
}

class ProsperityApp extends StatelessWidget {
  const ProsperityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LanguageService(),
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Harari Prosperity App',
            locale: languageService.currentLocale,
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('am', ''), // Amharic
              Locale('om', ''), // Oromo
            ],
            localizationsDelegates: [
              AppLocalizations.delegate,
              // Fallback to English for Material and Cupertino widgets when Oromo is selected
              const FallbackCupertinoLocalisationsDelegate(),
              const FallbackMaterialLocalisationsDelegate(),
              GlobalWidgetsLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              // Check if the current device locale is supported
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              // If the locale is not supported, use the first supported locale (en)
              return supportedLocales.first;
            },
            theme: ThemeData(
              primaryColor: AppColors.primary,
              primarySwatch: Colors.blue,
              fontFamily: 'Poppins',
              scaffoldBackgroundColor: Colors.white,
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 1,
              ),
            ),
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
