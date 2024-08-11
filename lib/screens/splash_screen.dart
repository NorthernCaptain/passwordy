import 'package:flutter/material.dart';
import 'package:passwordy/screens/login_screen.dart';
import 'master_password.dart';
import '../service/auth_service.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    var service = AuthService();

    var authState = await service.loginState();

    switch(authState) {
      case AuthStatus.authorized:
        break;
      case AuthStatus.notLoggedIn:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
        break;
      case AuthStatus.newVault:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MasterPasswordScreen(),
          ),
        );
        break;
    }

  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}