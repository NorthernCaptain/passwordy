
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static final Preferences instance = Preferences();

  late SharedPreferences prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }
}