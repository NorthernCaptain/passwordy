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

class Templates extends Table {
  TextColumn get id => text().clientDefault(() => generateId())();

  @override
  Set<Column> get primaryKey => {id};
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isVisible => boolean().withDefault(const Constant(true))();

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

@DriftDatabase(tables: [SetupValues, TemplateDetails, Templates])
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
        await _insertDefaults();
      },
    );
  }

  Future<void> _insertDefaults() async {
    await insertTemplate(
      TemplatesCompanion.insert(title: "Email account", icon: "email", color: "#1010F0", sort: 1)
      , [
        TemplateDetailsCompanion.insert(title: "Email", fieldType: FieldType.email, sort: 1, templateId: ''),
        TemplateDetailsCompanion.insert(title: "Password", fieldType: FieldType.password, sort: 2, templateId: ''),
        TemplateDetailsCompanion.insert(title: "Website", fieldType: FieldType.url, sort: 3, templateId: ''),
        TemplateDetailsCompanion.insert(title: "User name", fieldType: FieldType.text, sort: 4, templateId: ''),
        TemplateDetailsCompanion.insert(title: "Notes", fieldType: FieldType.note, sort: 5, templateId: ''),
      ],
    );
    await insertTemplate(
      TemplatesCompanion.insert(title: "Web site", icon: "web", color: "#10F010", sort: 2)
      , [
        TemplateDetailsCompanion.insert(title: "Website", fieldType: FieldType.url, sort: 1, templateId: ''),
        TemplateDetailsCompanion.insert(title: "User name", fieldType: FieldType.text, sort: 2, templateId: ''),
        TemplateDetailsCompanion.insert(title: "Password", fieldType: FieldType.password, sort: 3, templateId: ''),
        TemplateDetailsCompanion.insert(title: "Email", fieldType: FieldType.email, sort: 4, templateId: ''),
        TemplateDetailsCompanion.insert(title: "Notes", fieldType: FieldType.note, sort: 5, templateId: ''),
      ],
    );
    await insertTemplate(
      TemplatesCompanion.insert(title: "Credit card", icon: "credit_card", color: "#F01010", sort: 3)
      , [
        TemplateDetailsCompanion.insert(title: "Bank", fieldType: FieldType.capText, sort: 1, templateId: ''),
        TemplateDetailsCompanion.insert(title: "Card number", fieldType: FieldType.number, sort: 2, templateId: ''),
        TemplateDetailsCompanion.insert(title: "Pin-code", fieldType: FieldType.pinCode, sort: 3, templateId: ''),
        TemplateDetailsCompanion.insert(title: "Phone", fieldType: FieldType.phone, sort: 4, templateId: ''),
        TemplateDetailsCompanion.insert(title: "Notes", fieldType: FieldType.note, sort: 5, templateId: ''),
      ],
    );
    await insertTemplate(
      TemplatesCompanion.insert(title: "Bank account", icon: "account_balance", color: "#F0F010", sort: 3)
      , [
        TemplateDetailsCompanion.insert(title: "Bank", fieldType: FieldType.capText, sort: 1, templateId: ''),
        TemplateDetailsCompanion.insert(title: "Route number", fieldType: FieldType.number, sort: 2, templateId: ''),
        TemplateDetailsCompanion.insert(title: "Account number", fieldType: FieldType.number, sort: 3, templateId: ''),
        TemplateDetailsCompanion.insert(title: "Phone", fieldType: FieldType.phone, sort: 4, templateId: ''),
        TemplateDetailsCompanion.insert(title: "Notes", fieldType: FieldType.note, sort: 5, templateId: ''),
      ],
    );
  }

  Future<Template> insertTemplate(
      TemplatesCompanion template,
      List<TemplateDetailsCompanion> details
      ) async {
    final Template row = await into(templates).insertReturning(template);
    for (final detail in details) {
      await into(templateDetails).insert(
        detail.copyWith(templateId: Value(row.id)),
      );
    }
    return row;
  }
  
  Future<List<Template>> getActiveTemplates() async {
    return
      (select(templates)
        ..where((t) => t.isVisible.equals(true) & t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm(expression: t.sort)])).get();
  }
}
