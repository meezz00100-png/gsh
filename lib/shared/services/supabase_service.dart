import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import 'database_service.dart';

/// Main Supabase service that provides access to all Supabase functionality
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Service instances
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  // Getters for services
  AuthService get auth => _authService;
  DatabaseService get database => _databaseService;

  // Direct access to Supabase client if needed
  SupabaseClient get client => Supabase.instance.client;

  // Helper method to check if Supabase is initialized
  bool get isInitialized => true; // Supabase.instance.client is always available after initialization
}
