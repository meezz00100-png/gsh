import 'package:flutter/material.dart';
import '../features/authentication/login_screen.dart';
import '../features/authentication/signup_screen.dart';
import '../features/authentication/password/forgot_password.dart';
// ...existing code...
import '../features/home/home_screen.dart';
import '../features/report/report_detail_screen.dart';
import '../features/report/attachment_screen.dart';
import '../features/report/final_step_screen.dart';
import '../features/report/report_history_screen.dart';
import '../features/report/report_view_screen.dart';
import '../features/navigation/navigation_screen.dart';
import '../features/navigation/profile_screen.dart';
import '../features/security/security_screen.dart';
import '../features/settings/setting_screen.dart';
import '../features/settings/language_screen.dart';
import '../features/security/password_setting_screen.dart';
import '../features/faq/faq_screen.dart';
import '../features/authentication/terms_screen.dart';
import '../features/authentication/choice_screen.dart';
import '../features/authentication/splash_screen.dart';
import '../features/authentication/pin_screen.dart';
import '../features/navigation/edit_profile_screen.dart' as change_username;
import '../shared/models/report_model.dart' show Report;

abstract class AppRoutes {
  static const String pin = '/pin';
  static const String splash = '/';
  static const String choice = '/choice';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String terms = '/terms';
  static const String forgot = '/forgot';
  // ...existing code...
  static const String home = '/home';
  static const String reportDetail = '/report-detail';
  static const String attachment = '/attachment';
  static const String finalStep = '/final-step';
  static const String navigation = '/navigation';
  static const String profile = '/profile';
  static const String security = '/security';
  static const String settings = '/settings';
  static const String language = '/language';
  static const String passwordSettings = '/password-settings';
  static const String faq = '/faq';
  static const String reportHistory = '/report-history';
  static const String reportView = '/report-view';
  static const String changeUsername = '/change-username';
  static const String changeUsernameSuccess = '/change-username-success';

  static final routes = {
    pin: (context) {
      final hasPin = ModalRoute.of(context)?.settings.arguments as bool? ?? false;
      return PinScreen(isChangingPin: hasPin);
    },
    splash: (context) => const SplashScreen(),
    choice: (context) => const ChoiceScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    terms: (context) => const TermsScreen(),
    forgot: (context) => const ForgotPasswordScreen(),
    // ...existing code...
    home: (context) => const HomeScreen(),
    reportDetail: (context) => const ReportDetailScreen(),
    attachment: (context) => const AttachmentScreen(),
    finalStep: (context) => const FinalStepScreen(),
    navigation: (context) => const NavigationScreen(),
    profile: (context) => const ProfileScreen(),
    security: (context) => const SecurityScreen(),
    settings: (context) => const SettingsScreen(),
    language: (context) => const LanguageScreen(),
    passwordSettings: (context) => const PasswordSettingsScreen(),
    faq: (context) => const FaqScreen(),
    changeUsername: (context) => const change_username.ChangeUsernameScreen(),
    reportHistory: (context) => const ReportHistoryScreen(),
    reportView: (context) {
      final report = ModalRoute.of(context)?.settings.arguments as Report;
      return ReportViewScreen(report: report);
    },
  };
}
