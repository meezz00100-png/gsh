import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/widgets/custom_button.dart';
import 'package:harari_prosperity_app/shared/widgets/responsive_widgets.dart';
import 'package:harari_prosperity_app/shared/services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabaseService = SupabaseService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
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
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _signIn() async {
    _clearErrors();
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _supabaseService.auth.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.navigation);
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
    setState(() {
      if (error.contains('Invalid login credentials') || 
          error.contains('Email not confirmed') ||
          error.contains('Invalid email or password')) {
        _emailError = 'Invalid email or password';
        _passwordError = 'Invalid email or password';
      } else if (error.contains('Email')) {
        _emailError = 'Please check your email address';
      } else if (error.contains('Password')) {
        _passwordError = 'Please check your password';
      } else if (error.contains('network') || error.contains('connection')) {
        _emailError = 'Network error. Please check your connection';
      } else {
        _emailError = 'Login failed. Please try again';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
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
                  'Welcome',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Username Or Email",
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
                  labelText: "Username Or Email",
                  hintText: "example@gmail.com",
                  prefixIcon: const Icon(Icons.person),
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.forgot),
                  child: const Text("Forgot Password?"),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: CustomButton(
                  text: _isLoading ? "Signing In..." : "Log In",
                  onPressed: _isLoading ? null : _signIn,
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                    child: const Text("Sign Up"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Center(child: Text("or sign up with")),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.facebook)),
                  const SizedBox(width: 20),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.g_mobiledata)),
                ],
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}