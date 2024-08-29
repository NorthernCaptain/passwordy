import 'package:flutter/material.dart';
import 'package:passwordy/screens/security_options.dart';
import 'package:passwordy/service/auth_service.dart';
import 'package:passwordy/service/utils.dart';
import 'package:passwordy/widgets/password_field.dart';

class MasterPasswordScreen extends StatefulWidget {
  const MasterPasswordScreen({super.key});

  @override
  _MasterPasswordScreenState createState() => _MasterPasswordScreenState();
}

class _MasterPasswordScreenState extends State<MasterPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  double _passwordStrength = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Vault'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 200,
                    maxWidth: 200 * 16 / 9, // 16:9 aspect ratio
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/img/vault_door.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Create Master Password',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Please provide a strong master password for your vault. This password will be used to encrypt and protect all your sensitive data.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              PasswordTextField(controller: _passwordController, labelText: 'Master Password', onChanged: (value) {
                setState(() {
                  _passwordStrength = _calculatePasswordStrength(value);
                });
              }),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: _passwordStrength,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(_getColorForStrength(_passwordStrength)),
              ),
              const SizedBox(height: 8),
              Text(
                _getPasswordStrengthLabel(_passwordStrength),
                textAlign: TextAlign.center,
                style: TextStyle(color: _getColorForStrength(_passwordStrength)),
              ),
              const SizedBox(height: 20),
              PasswordTextField(controller: _confirmPasswordController, labelText: 'Confirm Master Password'),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _onContinuePressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onContinuePressed() {
    if (_passwordController.text != _confirmPasswordController.text) {
      snackError(context, 'Passwords do not match');
      return;
    }
    if (_passwordStrength < 0.5) {
      snackError(context, 'Please choose a stronger password');
      return;
    }
    AuthService().setCurrentPassword(_passwordController.text);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SecurityOptionsScreen(masterPassword: _passwordController.text,)));
  }

  double _calculatePasswordStrength(String password) {
    // This is a simple password strength calculation.
    // In a real app, you'd want a more sophisticated algorithm.
    if (password.length < 8) return 0.0;
    double strength = 0.0;
    if (password.length >= 12) strength += 0.2 + (password.length - 12) * 0.04;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;
    return strength;
  }

  Color _getColorForStrength(double strength) {
    if (strength < 0.3) return Colors.red;
    if (strength < 0.7) return Colors.orange;
    return Colors.green;
  }

  String _getPasswordStrengthLabel(double strength) {
    if (strength < 0.3) return 'Weak';
    if (strength < 0.7) return 'Moderate';
    return 'Strong';
  }
}