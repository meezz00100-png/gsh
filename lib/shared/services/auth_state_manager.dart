import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      await _supabaseService.auth.signOut();
      // Force clear the auth state immediately
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
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
