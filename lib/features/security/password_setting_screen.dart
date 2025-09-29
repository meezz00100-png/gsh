import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/shared/widgets/custom_button.dart';
import 'package:harari_prosperity_app/shared/services/auth_service.dart';
import 'package:harari_prosperity_app/shared/services/auth_state_manager.dart';
import 'package:harari_prosperity_app/shared/localization/app_localizations.dart';

class PasswordSettingsScreen extends StatefulWidget {
  const PasswordSettingsScreen({super.key});

  @override
  State<PasswordSettingsScreen> createState() => _PasswordSettingsScreenState();
}

class _PasswordSettingsScreenState extends State<PasswordSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  final _authStateManager = AuthStateManager();

  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _currentPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });
  }

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
  return context.translate('currentPasswordRequired');
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.translate('newPasswordRequired');
    }
    if (value.length < 6) {
      return context.translate('passwordTooShort');
    }
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
      return context.translate('passwordRequirements');
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.translate('confirmPasswordRequired');
    }
    if (value != _newPasswordController.text) {
      return context.translate('passwordMismatch');
    }
    return null;
  }

  Future<void> _changePassword() async {
    _clearErrors();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final currentUser = _authStateManager.currentUser;
      if (currentUser?.email == null) {
        setState(() {
          _currentPasswordError = 'User not authenticated.';
        });
        return;
      }
      // Verify current password
      await _authService.signIn(
        email: currentUser!.email!,
        password: _currentPasswordController.text,
      );
      // Update password
      await _authService.updateProfile(password: _newPasswordController.text);
      // Refresh session after password change
      await _authService.refreshSession();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('passwordChangedSuccessfully')),
            backgroundColor: Colors.green,
          ),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        Navigator.pushReplacementNamed(context, '/security');
      }
    } catch (e) {
      final error = e.toString();
      setState(() {
        if (error.contains('Invalid login credentials')) {
          _currentPasswordError = context.translate('incorrectPassword');
        } else if (error.contains('network')) {
          _currentPasswordError = context.translate('networkError');
        } else if (error.contains('password')) {
          _newPasswordError = context.translate('passwordRequirements');
        } else {
          _currentPasswordError = context.translate('passwordChangeFailed');
        }
      });
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('passwordSettings')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          context.translate('currentPassword'),
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
                        controller: _currentPasswordController,
                        obscureText: true,
                        validator: _validateCurrentPassword,
                        onChanged: (_) => _clearErrors(),
                        decoration: InputDecoration(
                          labelText: context.translate('currentPassword'),
                          border: const OutlineInputBorder(),
                          errorText: _currentPasswordError,
                          errorBorder: _currentPasswordError != null
                              ? const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          context.translate('newPassword'),
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
                        controller: _newPasswordController,
                        obscureText: true,
                        validator: _validateNewPassword,
                        onChanged: (_) => _clearErrors(),
                        decoration: InputDecoration(
                          labelText: context.translate('newPassword'),
                          border: const OutlineInputBorder(),
                          errorText: _newPasswordError,
                          errorBorder: _newPasswordError != null
                              ? const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          context.translate('confirmNewPassword'),
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
                        obscureText: true,
                        validator: _validateConfirmPassword,
                        onChanged: (_) => _clearErrors(),
                        decoration: InputDecoration(
                          labelText: context.translate('confirmNewPassword'),
                          border: const OutlineInputBorder(),
                          errorText: _confirmPasswordError,
                          errorBorder: _confirmPasswordError != null
                              ? const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: CustomButton(
                          text: _isLoading
                              ? context.translate('changingPassword')
                              : context.translate('changePassword'),
                          onPressed: _isLoading ? null : _changePassword,
                          filled: true,
                        ),
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
