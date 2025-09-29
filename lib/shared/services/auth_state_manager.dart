import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_service.dart';

class AuthStateManager extends ChangeNotifier {
  static final AuthStateManager _instance = AuthStateManager._internal();
  factory AuthStateManager() => _instance;
  AuthStateManager._internal();

  final SupabaseService _supabaseService = SupabaseService();
  
  bool _isInitialized = false;
  bool _isAuthenticated = false;
  User? _currentUser;

  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Listen to auth state changes
    _supabaseService.auth.authStateChanges.listen((AuthState data) {
      _updateAuthState(data.session?.user);
    });

    // Check current session
    final session = _supabaseService.auth.currentSession;
    _updateAuthState(session?.user);
    
    _isInitialized = true;
    notifyListeners();
  }

  void _updateAuthState(User? user) {
    final wasAuthenticated = _isAuthenticated;
    _currentUser = user;
    _isAuthenticated = user != null;
    
    if (wasAuthenticated != _isAuthenticated) {
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      // Mark user as logged out in preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_logged_out', true);

      // Sign out from Supabase
      await _supabaseService.auth.signOut();

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
