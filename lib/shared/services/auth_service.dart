import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:harari_prosperity_app/shared/config/api_config.dart';

class ApiAuthResponse {
  final ApiUser? user;
  final ApiSession? session;

  ApiAuthResponse({this.user, this.session});

  factory ApiAuthResponse.fromJson(Map<String, dynamic> json) {
    return ApiAuthResponse(
      user: json['user'] != null ? ApiUser.fromJson(json['user']) : null,
      session: json['session'] != null
          ? ApiSession.fromJson(json['session'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user?.toJson(), 'session': session?.toJson()};
  }
}

class ApiSession {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  ApiSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory ApiSession.fromJson(Map<String, dynamic> json) {
    return ApiSession(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}

class ApiUser {
  final String id;
  final String email;
  final Map<String, dynamic>? userMetadata;

  ApiUser({required this.id, required this.email, this.userMetadata});

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    return ApiUser(
      id: json['id'],
      email: json['email'],
      userMetadata: json['userMetadata'] ?? json['user_metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'userMetadata': userMetadata};
  }
}

class AuthService {
  // Get current user
  Future<ApiUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      return ApiUser.fromJson(json.decode(userJson));
    }
    return null;
  }

  // Get current session
  Future<ApiSession?> getCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('session');
    if (sessionJson != null) {
      final session = ApiSession.fromJson(json.decode(sessionJson));
      if (session.expiresAt.isAfter(DateTime.now())) {
        return session;
      } else {
        // Auto refresh if expired
        return await refreshSession();
      }
    }
    return null;
  }

  // Sign up with email and password
  Future<ApiAuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.signUp}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'userMetadata': data,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final authResponse = ApiAuthResponse.fromJson(data);
        await _saveSession(authResponse.session);
        await _saveUser(authResponse.user);
        return authResponse;
      } else {
        throw Exception(
          json.decode(response.body)['message'] ?? 'Sign up failed',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<ApiAuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (ApiConfig.debugMode) {
        debugPrint('Attempting login for: $email');
        debugPrint('API URL: ${ApiConfig.baseUrl}${ApiConfig.signIn}');
      }

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.signIn}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      if (ApiConfig.debugMode) {
        debugPrint('Response status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (ApiConfig.debugMode) {
          debugPrint('Parsed response data: $data');
        }
        final authResponse = ApiAuthResponse.fromJson(data);
        await _saveSession(authResponse.session);
        await _saveUser(authResponse.user);
        if (ApiConfig.debugMode) {
          debugPrint('Login successful for user: ${authResponse.user?.email}');
        }
        return authResponse;
      } else {
        final errorData = json.decode(response.body);
        if (ApiConfig.debugMode) {
          debugPrint('Login failed with status ${response.statusCode}: $errorData');
        }
        throw Exception(errorData['message'] ?? 'Sign in failed');
      }
    } catch (e) {
      if (ApiConfig.debugMode) {
        debugPrint('Login error: $e');
      }
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        throw Exception(
          'Unable to connect to server. Please check your internet connection.',
        );
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      final session = await getCurrentSession();
      if (session != null) {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.signOut}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${session.accessToken}',
          },
        );
      }
      await _clearSession();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.resetPassword}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw Exception('Reset password failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<ApiAuthResponse> updateProfile({
    Map<String, dynamic>? data,
    String? password,
  }) async {
    try {
      final session = await getCurrentSession();
      if (session == null) throw Exception('Not authenticated');

      Map<String, dynamic> body = {};
      if (data != null) body.addAll(data);
      if (password != null) body['password'] = password;

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.updateUser}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${session.accessToken}',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final authResponse = ApiAuthResponse.fromJson(data);
        await _saveUser(authResponse.user);
        return authResponse;
      } else {
        throw Exception('Update profile failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Refresh session
  Future<ApiSession?> refreshSession() async {
    try {
      final session = await getCurrentSession();
      if (session == null) return null;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.refreshToken}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': session.refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newSession = ApiSession.fromJson(data['session']);
        await _saveSession(newSession);
        return newSession;
      } else {
        await _clearSession();
        throw Exception('Session refresh failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteAccount(String userId) async {
    try {
      final session = await getCurrentSession();
      if (session == null) throw Exception('Not authenticated');

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId'),
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete account');
      }
      await _clearSession();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveSession(ApiSession? session) async {
    final prefs = await SharedPreferences.getInstance();
    if (session != null) {
      await prefs.setString('session', json.encode(session.toJson()));
    } else {
      await prefs.remove('session');
    }
  }

  Future<void> _saveUser(ApiUser? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user != null) {
      await prefs.setString('current_user', json.encode(user.toJson()));
    } else {
      await prefs.remove('current_user');
    }
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session');
    await prefs.remove('current_user');
  }
}
