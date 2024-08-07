import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:passwordy/service/log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

Future<bool> databaseExists(String dbName) async {
  final path = await getApplicationDocumentsDirectory();
  return File(p.join(path.path, dbName)).exists();
}

QueryExecutor _openDatabase(String name, String password) {
  return LazyDatabase(() async {
    final path = await getApplicationDocumentsDirectory();
    final dbfile = File(p.join(path.path, name));
    lg?.i("Opening database at ${dbfile.path}");
    return NativeDatabase.createInBackground(
      dbfile,
      isolateSetup: () async {
        open
          ..overrideFor(OperatingSystem.android, openCipherOnAndroid)
          ..overrideFor(OperatingSystem.linux,
                  () => DynamicLibrary.open('libsqlcipher.so'))
          ..overrideFor(OperatingSystem.windows,
                  () => DynamicLibrary.open('sqlcipher.dll'));
      },
      setup: (db) {
        // Check that we're actually running with SQLCipher by quering the
        // cipher_version pragma.
        final result = db.select('pragma cipher_version');
        if (result.isEmpty) {
          throw UnsupportedError(
            'This database needs to run with SQLCipher, but that library is '
                'not available!',
          );
        }
        lg?.i("Cipher in db: ${result.first['cipher_version']}");

        // Then, apply the key to encrypt the database. Unfortunately, this
        // pragma doesn't seem to support prepared statements so we inline the
        // key.
        final escapedKey = password.replaceAll("'", "''");
        db.execute("pragma key = '$escapedKey'");

        // Test that the key is correct by selecting from a table
        final rows = db.select('select count(*) from sqlite_master');
        lg?.i("Table count: ${rows.first.values.first}");
      },
    );
  });
}

class SetupValues extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text()();
  TextColumn get value => text()();
}

@DriftDatabase(tables: [SetupValues])
class VaultDatabase extends _$VaultDatabase {
  final String dbName;
  VaultDatabase(
      this.dbName,
      String password) : super(_openDatabase(dbName, password));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {},
    );
  }
}
