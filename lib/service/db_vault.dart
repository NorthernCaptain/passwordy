
import 'package:passwordy/service/auth_service.dart';
import 'package:passwordy/service/database.dart';
import 'package:passwordy/service/log.dart';

abstract class Vault {
  static const String masterDB = 'master.edb';
  static Future<bool> exists(String name) async {
    var exists = await databaseExists(name);
    return exists;
  }

  Future<bool> openDB({String name = Vault.masterDB});
}

class DBVault implements Vault {
  VaultDatabase? _db;

  @override
  Future<bool> openDB({String name = Vault.masterDB}) async {
    try {
      await _db?.close();
      final password = await AuthService().getCurrentPassword();
      if(password == null) {
        return false;
      }
      _db = VaultDatabase(name, password);
      final rows = await _db!.select(_db!.setupValues).get();
      lg?.i('DBVault setup: ${rows.length} rows');
    } catch (e) {
      lg?.e('Error opening database', error: e);
      return false;
    }
    return true;
  }
}
