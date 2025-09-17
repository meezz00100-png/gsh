import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:harari_prosperity_app/shared/config/supabase_config.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Auth state changes stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Delete user account (requires service role key, not anon key)
  Future<void> deleteAccount(String userId) async {
    final url = Uri.parse(
      '${SupabaseConfig.supabaseUrl}/auth/v1/admin/users/$userId',
    );
    final apiKey = _supabase.headers['apikey'] ?? '';
    final response = await http.delete(
      url,
      headers: {'apikey': apiKey, 'Authorization': 'Bearer $apiKey'},
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete account');
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      return await _supabase.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut(scope: SignOutScope.global);
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<UserResponse> updateProfile({
    Map<String, dynamic>? data,
    String? password,
  }) async {
    try {
      if (password != null) {
        return await _supabase.auth.updateUser(
          UserAttributes(password: password),
        );
      } else {
        return await _supabase.auth.updateUser(UserAttributes(data: data));
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get user session
  Session? get currentSession => _supabase.auth.currentSession;

  // Refresh session
  Future<AuthResponse> refreshSession() async {
    try {
      return await _supabase.auth.refreshSession();
    } catch (e) {
      rethrow;
    }
  }
}
