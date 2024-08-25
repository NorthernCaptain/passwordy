import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:passwordy/service/enums.dart';
import 'package:passwordy/service/log.dart';
import 'package:passwordy/service/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:path/path.dart' as p;
import 'package:passwordy/service/db/template_dao.dart';
import 'package:passwordy/service/db/datavalues_dao.dart';

part 'database.g.dart';

Future<bool> databaseExists(String dbName) async {
  final path = await getApplicationDocumentsDirectory();
  return File(p.join(path.path, dbName)).exists();
}

Future<String> databasePath(String dbName) async {
  final path = await getApplicationDocumentsDirectory();
  return p.join(path.path, dbName);
}

QueryExecutor _openDatabase(String name, String password) {
  return LazyDatabase(() async {
    final dbfile = File(await databasePath(name));
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

// This is the main table that stores the template headers
// When the user creates a secret based on this template
// the template is cloned and isData set to true
// then DataValues is used to store the secret values with reference to the template
// and it's details
class Templates extends Table {
  TextColumn get id => text().clientDefault(() => generateId())();

  @override
  Set<Column> get primaryKey => {id};
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isVisible => boolean().withDefault(const Constant(true))();
  // If the template is a data template, it will be used to store secret values
  BoolColumn get isData => boolean().withDefault(const Constant(false))();

  TextColumn get title => text()();
  TextColumn get category => text().nullable()();
  TextColumn get icon => text()();
  TextColumn get color => text()();
  IntColumn get sort => integer()();
}

class TemplateDetails extends Table {
  TextColumn get id => text().clientDefault(() => generateId())();
  @override
  Set<Column> get primaryKey => {id};
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  TextColumn get title => text()();
  TextColumn get fieldType => textEnum<FieldType>()();
  IntColumn get sort => integer()();
  TextColumn get templateId => text().references(Templates, #id)();
}

class DataValues extends Table {
  TextColumn get id => text().clientDefault(() => generateId())();
  @override
  Set<Column> get primaryKey => {id};
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  TextColumn get value => text()();

  TextColumn get templateId => text().references(Templates, #id)();
  TextColumn get templateDetailId => text().references(TemplateDetails, #id)();
}


@DriftDatabase(tables: [SetupValues, TemplateDetails, Templates, DataValues], daos: [TemplateDao, DataValuesDao])
class VaultDatabase extends _$VaultDatabase {
  final String dbName;

  VaultDatabase(this.dbName,
      String password) : super(_openDatabase(dbName, password));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {},
      onCreate: (Migrator m) async {
        await m.createAll();
        await templateDao.insertDefaults();
      },
    );
  }
}
