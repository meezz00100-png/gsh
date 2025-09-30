import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/widgets/custom_button.dart';
import 'package:harari_prosperity_app/shared/widgets/responsive_widgets.dart';
import 'package:harari_prosperity_app/shared/services/auth_service.dart';
import 'package:harari_prosperity_app/shared/services/auth_state_manager.dart';
import 'package:harari_prosperity_app/shared/localization/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

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
      final response = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        await AuthStateManager().onAuthSuccess(response);
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.navigation,
            (route) => false,
          );
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
        _emailError = context.translate('invalidEmailOrPassword');
        _passwordError = context.translate('invalidEmailOrPassword');
      } else if (error.contains('Email')) {
        _emailError = context.translate('checkEmailAddress');
      } else if (error.contains('Password')) {
        _passwordError = context.translate('checkPassword');
      } else if (error.contains('network') || error.contains('connection')) {
        _emailError = context.translate('networkError');
      } else {
        _emailError = context.translate('loginFailed');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('login')),
        automaticallyImplyLeading: false,
      ),
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
                    context.translate('welcome'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.translate('usernameOrEmail'),
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
                    labelText: context.translate('usernameOrEmail'),
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.forgot),
                    child: Text(context.translate('forgotPassword')),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: CustomButton(
                    text: _isLoading
                        ? context.translate('signingIn')
                        : context.translate('login'),
                    onPressed: _isLoading ? null : _signIn,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(context.translate('dontHaveAccount')),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.signup),
                      child: Text(context.translate('signup')),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(child: Text(context.translate('orSignUpWith'))),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.facebook),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.g_mobiledata),
                    ),
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
