import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/localization/app_localizations.dart';
import 'package:harari_prosperity_app/shared/services/auth_state_manager.dart';

class PinScreen extends StatefulWidget {
  final bool isChangingPin;

  const PinScreen({
    super.key,
    this.isChangingPin = false,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final TextEditingController _pinController = TextEditingController();
  String _enteredPin = '';
  String? _errorMessage;
  bool _isSettingPin = false;

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final authManager = AuthStateManager();
    final userId = authManager.getUserId();
    final hasPin = userId != null ? (prefs.getBool('has_pin_$userId') ?? false) : false;

    if (!hasPin) {
      setState(() {
        _isSettingPin = true;
      });
    } else if (widget.isChangingPin) {
      // When changing PIN, we don't need to verify first
      setState(() {
        _isSettingPin = true; // Treat as setting new PIN
      });
    }
  }

  Future<void> _changePin() async {
    if (_enteredPin.length != 4) {
      setState(() {
        _errorMessage = context.translate('pin_must_be_4_digits');
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final authManager = AuthStateManager();
    final userId = authManager.getUserId();
    if (userId != null) {
      await prefs.setString('app_pin_$userId', _enteredPin);
    }

    if (!mounted) return;
    Navigator.of(context).pop(); // Go back to security screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.translate('passwordChangedSuccessfully'))),
    );
  }

  Future<void> _verifyPin() async {
    final prefs = await SharedPreferences.getInstance();
    final authManager = AuthStateManager();
    final userId = authManager.getUserId();
    final storedPin = userId != null ? prefs.getString('app_pin_$userId') : null;

    if (storedPin == _enteredPin) {
      // PIN correct, proceed to home screen since user is authenticated
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.navigation);
    } else {
      setState(() {
        _errorMessage = context.translate('incorrect_pin');
        _enteredPin = '';
        _pinController.clear();
      });
    }
  }

  Future<void> _setPin() async {
    if (_enteredPin.length != 4) {
      setState(() {
        _errorMessage = context.translate('pin_must_be_4_digits');
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final authManager = AuthStateManager();
    final userId = authManager.getUserId();
    if (userId != null) {
      await prefs.setString('app_pin_$userId', _enteredPin);
      await prefs.setBool('has_pin_$userId', true);
    }

    if (!mounted) return;
    // Navigate back to security screen after setting PIN
    Navigator.of(context).pop();
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _errorMessage = null;
      });

      // Auto-submit when 4 digits are entered
      if (_enteredPin.length == 4) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (widget.isChangingPin) {
            _changePin();
          } else if (_isSettingPin) {
            _setPin();
          } else {
            _verifyPin();
          }
        });
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(top: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Logo
              Image.asset(
                'assets/images/prosperity_logo.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                widget.isChangingPin
                    ? context.translate('change_pin')
                    : (_isSettingPin
                        ? context.translate('set_pin')
                        : context.translate('enter_pin')),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                widget.isChangingPin
                    ? context.translate('change_pin_description')
                    : (_isSettingPin
                        ? context.translate('set_pin_description')
                        : context.translate('enter_pin_description')),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _enteredPin.length
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Error message
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 24),

              // Number pad
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 1.3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    // Numbers 1-9
                    for (int i = 1; i <= 9; i++)
                      _buildNumberButton(i.toString()),

                    // Empty space
                    const SizedBox(),

                    // Number 0
                    _buildNumberButton('0'),

                    // Delete button
                    _buildDeleteButton(),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return ElevatedButton(
      onPressed: () => _onNumberPressed(number),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(5),
        elevation: 0,
        minimumSize: const Size(15, 15),
      ),
      child: Text(
        number,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return ElevatedButton(
      onPressed: _onDeletePressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[50],
        foregroundColor: Colors.red,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(5),
        elevation: 0,
        minimumSize: const Size(15, 15),
      ),
      child: const Icon(
        Icons.backspace,
        size: 15,
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
