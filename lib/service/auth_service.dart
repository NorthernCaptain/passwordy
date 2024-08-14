
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth/local_auth.dart';
import 'package:passwordy/service/db/db_vault.dart';
import 'package:passwordy/service/log.dart';

enum AuthStatus { authorized, notLoggedIn, newVault }

class AuthService {

  AuthService._(); // Private constructor
  static final AuthService _instance = AuthService._();

  factory AuthService() => _instance;

  String? currentPassword;
  bool isAuthenticated = false;

  Future<AuthStatus> loginState() async {
    if (await Vault.exists(Vault.masterDB)) {
      return AuthStatus.notLoggedIn;
    }
    return AuthStatus.newVault;
  }

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ));

  Future<bool> authenticateWithBiometrics() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    if (!canCheckBiometrics) {
      return false;
    }

    try {
      isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
        authMessages: [const AndroidAuthMessages(cancelButton: 'Back to password')],
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return isAuthenticated;
    } on PlatformException catch (e) {
      lg?.e("Auth error", error: e);
      return false;
    }
  }

  Future<void> storeMasterPassword(String password) async {
    await _secureStorage.write(key: 'master_password', value: password);
  }

  Future<String?> getMasterPassword() async {
    return await _secureStorage.read(key: 'master_password');
  }

  void setCurrentPassword(String password) {
    currentPassword = password;
  }

  Future<String?> getCurrentPassword() async {
    if (currentPassword != null) {
      return currentPassword;
    }
    if(await isBiometricsEnabled()) {
      if(isAuthenticated) {
        currentPassword = await getMasterPassword();
        return currentPassword;
      }
    }
    return currentPassword;
  }

  Future<void> enableBiometrics() async {
    await _secureStorage.write(key: 'biometrics_enabled', value: 'true');
  }

  Future<void> disableBiometrics() async {
    await _secureStorage.write(key: 'biometrics_enabled', value: 'false');
  }

  Future<bool> isBiometricsEnabled() async {
    String? enabled = await _secureStorage.read(key: 'biometrics_enabled');
    return enabled == 'true';
  }
// ... other methods (login, signUp, etc.)
}