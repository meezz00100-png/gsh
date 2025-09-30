import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class AuthStateManager extends ChangeNotifier {
  static final AuthStateManager _instance = AuthStateManager._internal();
  factory AuthStateManager() => _instance;
  AuthStateManager._internal();

  final AuthService _authService = AuthService();

  bool _isInitialized = false;
  bool _isAuthenticated = false;
  ApiUser? _currentUser;

  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _isAuthenticated;
  ApiUser? get currentUser => _currentUser;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Check current user from local storage
    final user = await _authService.getCurrentUser();
    await _updateAuthState(user);

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _updateAuthState(ApiUser? user) async {
    final session = await _authService.getCurrentSession();
    final hasValidSession =
        session != null && session.expiresAt.isAfter(DateTime.now());

    final wasAuthenticated = _isAuthenticated;
    _currentUser = hasValidSession ? user : null;
    _isAuthenticated = _currentUser != null;

    if (wasAuthenticated != _isAuthenticated) {
      notifyListeners();
    }
  }

  Future<void> onAuthSuccess(ApiAuthResponse response) async {
    await _updateAuthState(response.user);
  }

  Future<void> signOut() async {
    try {
      // Mark user as logged out in preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_logged_out', true);

      // Sign out from API
      await _authService.signOut();

      // Then update the state
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error during sign out: $e');
      debugPrint('Stack trace: $stackTrace');
      // Even if sign out fails, ensure we're in a clean state
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
      rethrow; // Rethrow to let the caller handle the error
    }
  }

  Future<bool> wasUserLoggedOut() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('user_logged_out') ?? false;
  }

  Future<void> clearLogoutFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_logged_out');
  }

  String? getUserEmail() {
    return _currentUser?.email;
  }

  String? getUserId() {
    return _currentUser?.id;
  }

  Map<String, dynamic>? getUserMetadata() {
    return _currentUser?.userMetadata;
  }
}
