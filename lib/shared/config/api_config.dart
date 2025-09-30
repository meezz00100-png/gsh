class ApiConfig {
  // Backend server URL - update this to match your backend
  static const String baseUrl =
      'http://10.232.199.224:3000/api'; // Actual host IP address
  // For iOS simulator or web: 'http://localhost:3000/api'

  // Debug mode to help troubleshoot connection issues
  static const bool debugMode = true;

  // Auth endpoints
  static const String signUp = '/auth/signup';
  static const String signIn = '/auth/signin';
  static const String signOut = '/auth/signout';
  static const String refreshToken = '/auth/refresh';
  static const String resetPassword = '/auth/reset-password';
  static const String updateUser = '/auth/update-user';

  // Database endpoints
  static const String reports = '/reports';
  static const String users = '/users';

  // Optional: Add additional configuration
  static const bool enableDebugMode = true;
  static const Duration timeout = Duration(seconds: 30);
}
