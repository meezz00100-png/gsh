class SupabaseConfig {
  // TODO: Replace these with your CORRECT Supabase project URL and anon key
  // Get these from: https://supabase.com/dashboard → Your Project → Settings → API
  static const String supabaseUrl = 'https://ptebdkkhdmalwwbichxf.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB0ZWJka2toZG1hbHd3YmljaHhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY5NDYzMjYsImV4cCI6MjA3MjUyMjMyNn0.SwKbVSGf5zsFFDMjgh9lZRlRAvbIaHYsNO18M0x5DCM';
  
  // Optional: Add additional configuration
  static const bool enableDebugMode = true;
  static const Duration authTimeout = Duration(seconds: 30);
}
