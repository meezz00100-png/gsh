import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/widgets/custom_button.dart';
import 'package:harari_prosperity_app/shared/widgets/responsive_widgets.dart';
import 'package:harari_prosperity_app/shared/services/auth_service.dart';
import 'package:harari_prosperity_app/shared/services/auth_state_manager.dart';
import 'package:harari_prosperity_app/shared/localization/app_localizations.dart';

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
  final _authService = AuthService();

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
      return context.translate('emailRequired');
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return context.translate('invalidEmail');
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.translate('passwordRequired');
    }
    if (value.length < 6) {
      return context.translate('passwordMinLength');
    }
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
      return context.translate('passwordLetterNumber');
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.translate('confirmPasswordRequired');
    }
    if (value != _passwordController.text) {
      return context.translate('passwordsDoNotMatch');
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
      final response = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        await AuthStateManager().onAuthSuccess(response);
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
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
        _emailError = context.translate('emailAlreadyExists');
      } else if (error.contains('Invalid email')) {
        _emailError = context.translate('invalidEmail');
      } else if (error.contains('Password')) {
        _passwordError = context.translate('passwordRequirementsNotMet');
      } else if (error.contains('network') || error.contains('connection')) {
        _emailError = context.translate('networkError');
      } else if (error.contains('Email rate limit exceeded')) {
        _emailError = context.translate('signupRateLimit');
      } else if (error.contains('Invalid API key')) {
        _emailError = context.translate('configError');
      } else if (error.contains('signup is disabled')) {
        _emailError = context.translate('signupDisabled');
      } else {
        _emailError = context.translate('registrationFailed');
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
      appBar: AppBar(title: Text(context.translate('createAccount'))),
      body: ResponsivePadding(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    context.translate('signup'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.translate('email'),
                    style: const TextStyle(
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
                    labelText: context.translate('email'),
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.translate('password'),
                    style: const TextStyle(
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
                    labelText: context.translate('password'),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.translate('confirmPassword'),
                    style: const TextStyle(
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
                    labelText: context.translate('confirmPassword'),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                Text.rich(
                  TextSpan(
                    text: context.translate('agreeTo'),
                    children: [
                      TextSpan(
                        text: context.translate('termsOfUse'),
                        style: const TextStyle(color: Colors.blue),
                      ),
                      TextSpan(text: context.translate('and')),
                      TextSpan(
                        text: context.translate('privacyPolicy'),
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: CustomButton(
                    text: _isLoading
                        ? context.translate('creatingAccount')
                        : context.translate('signup'),
                    onPressed: _isLoading ? null : _signUp,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.login),
                    child: Text(context.translate('alreadyHaveAccountLogin')),
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
