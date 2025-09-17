import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/widgets/custom_button.dart';
import 'package:harari_prosperity_app/shared/widgets/responsive_widgets.dart';
import 'package:harari_prosperity_app/shared/services/supabase_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _supabaseService = SupabaseService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain at least one letter and one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _signUp() async {
    _clearErrors();
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _supabaseService.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully! Please check your email to verify your account.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
          // Navigate to terms screen
          Navigator.pushReplacementNamed(context, AppRoutes.terms);
        }
      }
    } catch (error) {
      if (mounted) {
        _handleAuthError(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleAuthError(String error) {
    // Print detailed error for debugging
    print('Signup Error: $error');
    
    setState(() {
      if (error.contains('User already registered') || 
          error.contains('already been registered')) {
        _emailError = 'An account with this email already exists';
      } else if (error.contains('Invalid email')) {
        _emailError = 'Please enter a valid email address';
      } else if (error.contains('Password')) {
        _passwordError = 'Password does not meet requirements';
      } else if (error.contains('network') || error.contains('connection')) {
        _emailError = 'Network error. Please check your connection';
      } else if (error.contains('Email rate limit exceeded')) {
        _emailError = 'Too many signup attempts. Please wait before trying again';
      } else if (error.contains('Invalid API key')) {
        _emailError = 'Configuration error. Please contact support';
      } else if (error.contains('signup is disabled')) {
        _emailError = 'Account creation is currently disabled';
      } else {
        _emailError = 'Registration failed: ${error.length > 50 ? error.substring(0, 50) + '...' : error}';
      }
    });
    
    // Also show a snackbar with the full error for debugging
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Debug: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: ResponsivePadding(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Email",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                onChanged: (_) => _clearErrors(),
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "example@gmail.com",
                  prefixIcon: const Icon(Icons.email),
                  errorText: _emailError,
                  errorBorder: _emailError != null 
                    ? const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      )
                    : null,
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Password",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: _validatePassword,
                onChanged: (_) => _clearErrors(),
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  errorText: _passwordError,
                  errorBorder: _passwordError != null 
                    ? const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      )
                    : null,
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Confirm Password",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                validator: _validateConfirmPassword,
                onChanged: (_) => _clearErrors(),
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  errorText: _confirmPasswordError,
                  errorBorder: _confirmPasswordError != null 
                    ? const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      )
                    : null,
                ),
              ),
              const SizedBox(height: 20),
              const Text.rich(
                TextSpan(
                  text: "By continuing, you agree to ",
                  children: [
                    TextSpan(
                      text: "Terms of Use",
                      style: TextStyle(color: Colors.blue),
                    ),
                    TextSpan(text: " and "),
                    TextSpan(
                      text: "Privacy Policy",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: CustomButton(
                  text: _isLoading ? "Creating Account..." : "Sign Up",
                  onPressed: _isLoading ? null : _signUp,
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                  child: const Text("Already have an account? Login"),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}