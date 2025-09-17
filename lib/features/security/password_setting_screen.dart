import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/shared/widgets/custom_button.dart';
import 'package:harari_prosperity_app/shared/services/auth_service.dart';
import 'package:harari_prosperity_app/shared/services/auth_state_manager.dart';

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
      return 'Please enter your current password';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
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
      return 'Please confirm your new password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
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
          const SnackBar(
            content: Text('Password changed successfully!'),
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
          _currentPasswordError = 'Incorrect current password.';
        } else if (error.contains('network')) {
          _currentPasswordError =
              'Network error. Please check your connection.';
        } else if (error.contains('password')) {
          _newPasswordError = 'Password does not meet requirements.';
        } else {
          _currentPasswordError =
              'Failed to change password. Please try again.';
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
        title: const Text("Password Settings"),
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
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Current Password",
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
                        controller: _currentPasswordController,
                        obscureText: true,
                        validator: _validateCurrentPassword,
                        onChanged: (_) => _clearErrors(),
                        decoration: InputDecoration(
                          labelText: "Current Password",
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
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "New Password",
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
                        controller: _newPasswordController,
                        obscureText: true,
                        validator: _validateNewPassword,
                        onChanged: (_) => _clearErrors(),
                        decoration: InputDecoration(
                          labelText: "New Password",
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
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Confirm New Password",
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
                        obscureText: true,
                        validator: _validateConfirmPassword,
                        onChanged: (_) => _clearErrors(),
                        decoration: InputDecoration(
                          labelText: "Confirm New Password",
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
                          text: _isLoading ? "Changing..." : "Change Password",
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
