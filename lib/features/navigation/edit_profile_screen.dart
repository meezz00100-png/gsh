import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/shared/widgets/custom_button.dart';
import 'package:harari_prosperity_app/shared/services/auth_service.dart';
import 'package:harari_prosperity_app/shared/services/auth_state_manager.dart';
import 'package:harari_prosperity_app/shared/localization/app_localizations.dart';

class ChangeUsernameScreen extends StatefulWidget {
  const ChangeUsernameScreen({super.key});

  @override
  State<ChangeUsernameScreen> createState() => _ChangeUsernameScreenState();
}

class _ChangeUsernameScreenState extends State<ChangeUsernameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _authStateManager = AuthStateManager();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Leave username field empty for new input
    // User can see current username but must enter new one
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateUsername() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newUsername = _usernameController.text.trim();
      final password = _passwordController.text;

      // First verify the current password by attempting to sign in
      final currentUser = _authStateManager.currentUser;
      if (currentUser?.email == null) {
        throw Exception('User not authenticated');
      }

      // Verify password by attempting to sign in
      await _authService.signIn(email: currentUser!.email!, password: password);

      // Update user metadata with new username
      await _authService.updateProfile(data: {'username': newUsername});

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('usernameUpdatedSuccessfully')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('Invalid login credentials')) {
      return context.translate('incorrectPassword');
    } else if (error.contains('network')) {
      return context.translate('networkError');
    } else if (error.contains('username')) {
      return context.translate('usernameTaken');
    }
    return context.translate('genericError');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.translate('changeUsername'))),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth < 500 ? double.infinity : 400;
          EdgeInsets padding = constraints.maxWidth < 500
              ? const EdgeInsets.all(12)
              : const EdgeInsets.all(20);
          return SingleChildScrollView(
            child: Padding(
              padding: padding,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          context.translate('changeUsername'),
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
                        controller: _usernameController,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          labelText: context.translate('newUsername'),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.translate('enterUsername');
                          }
                          if (value.trim().length < 3) {
                            return context.translate('usernameMinLength');
                          }
                          if (value.trim().length > 20) {
                            return context.translate('usernameMaxLength');
                          }
                          if (!RegExp(
                            r'^[a-zA-Z0-9_]+$',
                          ).hasMatch(value.trim())) {
                            return context.translate('usernameAllowedChars');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
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
                        controller: _passwordController,
                        enabled: !_isLoading,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: context.translate('currentPassword'),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.translate('enterCurrentPassword');
                          }
                          return null;
                        },
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade600,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      CustomButton(
                        text: _isLoading
                            ? context.translate('updating')
                            : context.translate('change'),
                        onPressed: _isLoading ? null : _updateUsername,
                        filled: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
