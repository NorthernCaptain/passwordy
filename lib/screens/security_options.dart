import 'package:flutter/material.dart';
import 'package:passwordy/service/auth_service.dart';
import 'package:passwordy/service/db_vault.dart';
import 'package:passwordy/service/log.dart';
import 'package:passwordy/screens/home_screen.dart';
import 'package:passwordy/service/utils.dart';

class SecurityOptionsScreen extends StatefulWidget {
  final String masterPassword;

  const SecurityOptionsScreen({super.key, required this.masterPassword});

  @override
  _SecurityOptionsScreenState createState() => _SecurityOptionsScreenState();
}
class _SecurityOptionsScreenState extends State<SecurityOptionsScreen> {
  bool _enableBiometrics = false;
  bool _enablePinCode = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkBiometricsStatus();
  }

  Future<void> _checkBiometricsStatus() async {
    bool isEnabled = await _authService.isBiometricsEnabled();
    setState(() {
      _enableBiometrics = isEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Options'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enable Faster Login',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Choose additional security options for quicker access to your vault.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildOptionTile(
                icon: Icons.fingerprint,
                title: 'Enable Biometrics',
                subtitle: 'Use your fingerprint or face ID to unlock the app',
                value: _enableBiometrics,
                onChanged: (value) {
                  setState(() {
                    _enableBiometrics = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildOptionTile(
                icon: Icons.pin,
                title: 'Enable PIN Code',
                subtitle: 'Use a 4-digit PIN to unlock the app',
                value: _enablePinCode,
                onChanged: (value) {
                  setState(() {
                    _enablePinCode = value;
                  });
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _onContinuePressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Continue'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _onContinuePressed() async {
    if (_enableBiometrics) {
      bool authenticated = await _authService.authenticateWithBiometrics();
      if (authenticated) {
        await _authService.storeMasterPassword(widget.masterPassword);
        await _authService.enableBiometrics();
        // Navigate to the next screen or home screen
      } else {
        // Show error message
        snackError(context, 'Biometric authentication failed');
        await _authService.disableBiometrics();
        await _checkBiometricsStatus();
        return;
      }
    }

    await nextScreen();
  }

  Future<void> nextScreen() async {
    Vault dbVault = Vault.vault;
    final result = await dbVault.openDB();
    lg?.i('DB opened: $result');
    if (!result) {
      snackError(context, 'Incorrect password');
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }
}