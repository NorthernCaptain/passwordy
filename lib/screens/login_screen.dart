import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passwordy/screens/home_screen.dart';
import 'package:passwordy/service/auth_service.dart';
import 'package:passwordy/service/db_vault.dart';
import 'package:passwordy/service/log.dart';
import 'package:passwordy/widgets/password_field.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService = AuthService();

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showBiometricsButton = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    setState(() => _isLoading = false);

    try {
      bool isBiometricsEnabled = await widget.authService.isBiometricsEnabled();
      setState(() {
        _showBiometricsButton = isBiometricsEnabled;
      });
      if (isBiometricsEnabled) {
        bool isAuthenticated = await widget.authService.authenticateWithBiometrics();
        if (isAuthenticated) {
          // Navigate to the next screen or perform necessary actions
          lg?.i('Biometric authentication successful');
          await nextScreen();
        }
      }
    } catch (e) {
      lg?.i('Error checking biometrics: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> nextScreen() async {
    Vault dbVault = DBVault();
    final result = await dbVault.openDB();
    if(!result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password does not match'), backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }
    lg?.i('DB opened: $result');
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  void _onContinuePressed() {
    // Implement your login logic here
    lg?.i('Password entered: ${_passwordController.text}');
    widget.authService.setCurrentPassword(_passwordController.text);
    nextScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
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
              const SizedBox(height: 48),
              const Text(
                'Sign in to the Vault',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PasswordTextField(controller: _passwordController, hintText: 'Enter your master password', labelText: "Master password",),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _onContinuePressed,
                child: const Text('Continue'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              if (_showBiometricsButton) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _checkBiometrics,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Use biometrics'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}