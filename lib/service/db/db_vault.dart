
import 'package:passwordy/service/auth_service.dart';
import 'package:passwordy/service/db/database.dart';
import 'package:passwordy/service/db/datavalues_dao.dart';
import 'package:passwordy/service/db/template_dao.dart';
import 'package:passwordy/service/log.dart';

abstract class Vault {
  VaultDatabase? _db;

  static const String masterDB = 'master.edb';
  static Vault vault = DBVault();
  static Future<bool> exists(String name) async {
    var exists = await databaseExists(name);
    return exists;
  }

  Future<bool> openDB({String name = Vault.masterDB});
  Future<List<Template>> getActiveTemplates();
  VaultDatabase? get db => (_db as DBVault)._db;
  DataValuesDao? get dataValuesDao => _db?.dataValuesDao;
  TemplateDao? get templateDao => _db?.templateDao;
}

class DBVault extends Vault {
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

  @override
  Future<List<Template>> getActiveTemplates() async {
    final templates = await _db?.templateDao.getActiveTemplates() ?? [];
    return templates;
  }
}
