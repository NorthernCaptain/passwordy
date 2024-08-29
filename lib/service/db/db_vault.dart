
import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:passwordy/service/auth_service.dart';
import 'package:passwordy/service/db/database.dart';
import 'package:passwordy/service/db/datavalues_dao.dart';
import 'package:passwordy/service/log.dart';
import 'package:passwordy/service/sync/sync_manager.dart';
import 'package:passwordy/service/utils.dart';
import 'package:rxdart/rxdart.dart';

abstract class Vault {
  static const String masterDB = 'master.edb';
  static Vault vault = DBVault();

  static Future<bool> exists(String name) async {
    var exists = await databaseExists(name);
    return exists;
  }

  static Future<void> resetDB({String name = Vault.masterDB}) async {
    final dbfile = File(await databasePath(name));
    if(await dbfile.exists()) {
      await dbfile.delete();
    }
  }

  void scheduleSync();

  Future<bool> openDB({String name = Vault.masterDB});
  bool get isConnected;
  Stream<bool> get connectionStream;

  Future<List<Template>> getActiveTemplates();

  Future<void> closeDB();

  // Transactions for CRUD operations. Every single DB change should go through transaction!
  Future<T> transaction<T>(Future<T> Function() action);

  Future<List<DataWithTemplate>> getDataWithTemplate(String templateId,
      {bool onlyData = false});

  Future<DataValue> insertDataValue(DataValuesCompanion dataValue);

  Future<void> updateDataValue(DataValue dataValue);

  Stream<List<DataWithAllTemplate>> watchActiveTokenTemplates();

  Stream<List<Template>> watchActiveDataTemplates({String filter = ""});

  Future<void> updateTemplate(Template template);

  Future<void> updateTemplateDetail(TemplateDetail detail);

  Future<(Map<String, String> old2new, Template template)>
  cloneTemplate(Template template, { bool isVisible = false, bool isData = false });

  Future<void> deleteTemplate(Template template);

  Future<List<Template>> getActiveTokenTemplates();
}

class DBVault extends Vault {
  VaultDatabase? _db;

  //this is raised when the DB needs some maintenance like opening or closing, backup etc
  final BarrierWaiter _dbMounted = BarrierWaiter("mounted");
  //this is raised when we have an active running DB operation like fetch or CRUD
  final BarrierWaiter _dbBusy = BarrierWaiter("busy");

  final _connectionController = BehaviorSubject<bool>.seeded(false);

  @override
  bool get isConnected => _connectionController.value;

  @override
  Stream<bool> get connectionStream => _connectionController.stream;

  @override
  Future<bool> openDB({String name = Vault.masterDB}) async {
    try {
      closeDB();

      final password = await AuthService().getCurrentPassword();
      if(password == null) {
        return false;
      }

      _db = VaultDatabase(name, password);
      final rows = await _db!.select(_db!.setupValues).get();
      lg?.i('DBVault setup: ${rows.length} rows');

      _setConnectionState(true);
      return true;
    } catch (e) {
      lg?.e('Error opening database', error: e);
      _setConnectionState(false);
      return false;
    }
  }

  @override
  Future<void> closeDB() async {
    if(_db == null) {
      return;
    }
    await _db?.close();
    _db = null;
    _setConnectionState(false);
  }

  void _setConnectionState(bool connected) {
    lg?.i("DBVault connection state: $connected");
    _connectionController.add(connected);
    if(connected) {
      _dbMounted.signalCompletion();
    } else {
      _dbMounted.start();
    }
  }

  Timer? _syncTimer = null;

  @override
  void scheduleSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(seconds: 5), () {
      syncDB();
    });
  }

  Future<bool> syncDB() async {
    lg?.i('DB sync started');
    final backup = await _dbBusy.safely(() async {
      if(_db == null) {
        lg?.e('DB not open, cannot sync');
        return null;
      }
      return await copyAndReopenDB();
    });
    lg?.i("DB sync got backup: $backup");
    if(backup == null) {
      return false;
    }
    await SyncManager.instance.uploadBackup(backup, dbName: _db!.dbName, removeLocal: true);
    lg?.i('DB sync finished');
    return true;
  }

  Future<String?> copyAndReopenDB() async {
    try {
      if(_db == null) {
        lg?.e('DB not open, cannot copy and reopen');
        return null;
      }

      final name = _db!.dbName;

      // Close the current database
      await closeDB();

      // Get the path to the current database file
      final path = await databasePath(name);
      final dbFile = File(path);

      // Create a backup copy
      final backupFile = File('${dbFile.path}.backup');
      if(await backupFile.exists()) {
        await backupFile.delete();
      }
      await dbFile.copy(backupFile.path);

      // Reopen the database
      final success = await openDB(name: name);

      if (!success) {
        // If reopening failed, restore from the backup
        await backupFile.copy(dbFile.path);
        await openDB(name: name);
      }

      return backupFile.path;
    } catch (e) {
      lg?.e('Error during copy and reopen', error: e);
      return null;
    }
  }

  @override
  Future<List<Template>> getActiveTemplates() async {
    return safely(() async {
      final templates = await _db?.templateDao.getActiveTemplates() ?? [];
      return templates;
    });
  }

  @override
  Future<List<DataWithTemplate>> getDataWithTemplate(String templateId,
      {bool onlyData = false}) async {
    return safely(() async {
      final data = await _db?.dataValuesDao.getDataWithTemplate(
          templateId, onlyData: onlyData) ?? [];
      return data;
    });
  }

  @override
  Stream<List<DataWithAllTemplate>> watchActiveTokenTemplates() {
    return connectionStream.switchMap((connected) {
      if (!connected) {
        return Stream.value(<DataWithAllTemplate>[]);
      }
      return _db?.dataValuesDao.watchActiveTokenTemplates() ?? Stream.value([]);
    });
  }

  @override
  Stream<List<Template>> watchActiveDataTemplates({String filter = ""}) {
    return connectionStream.switchMap((connected) {
      if (!connected) {
        return Stream.value([]);
      }
      if(_db == null) {
        return Stream.value([]);
      }
      return _db?.dataValuesDao.watchActiveDataTemplates(filter: filter) ?? Stream.value([]);
    });
  }

  @override
  Future<List<Template>> getActiveTokenTemplates() async {
    return safely(_db!.templateDao.getActiveTokenTemplates);
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    final ret = safely(() async => await _db!.transaction(action));
    scheduleSync();
    return ret;
  }

  @override
  Future<void> updateTemplate(Template template) async {
    await _db!.templateDao.updateTemplate(template);
  }

  @override
  Future<void> updateTemplateDetail(TemplateDetail detail) async {
    await _db!.templateDao.updateTemplateDetail(detail);
  }

  @override
  Future<(Map<String, String> old2new, Template template)>
  cloneTemplate(Template template, { bool isVisible = false, bool isData = false }) async {
    return _db!.templateDao.cloneTemplate(template, isVisible: isVisible, isData: isData);
  }

  @override
  Future<void> deleteTemplate(Template template) async {
    return safely(() => _db!.templateDao.deleteTemplate(template));
  }

  @override
  Future<DataValue> insertDataValue(DataValuesCompanion dataValue) async {
    return _db!.dataValuesDao.insertDataValue(dataValue);
  }

  @override
  Future<void> updateDataValue(DataValue dataValue) async {
    await _db!.dataValuesDao.updateDataValue(dataValue);
  }

  Future<T> safely<T>(Future<T> Function() action) async {
    return _dbMounted.safely(() async {
      try {
        _dbBusy.start();
        return await action();
      } catch (e) {
        lg?.e('Error in DBVault', error: e);
        rethrow;
      }
      finally {
        _dbBusy.signalCompletion();
      }
    });
  }
}
