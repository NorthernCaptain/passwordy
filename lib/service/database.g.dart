// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SetupValuesTable extends SetupValues
    with TableInfo<$SetupValuesTable, SetupValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetupValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setup_values';
  @override
  VerificationContext validateIntegrity(Insertable<SetupValue> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SetupValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetupValue(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SetupValuesTable createAlias(String alias) {
    return $SetupValuesTable(attachedDatabase, alias);
  }
}

class SetupValue extends DataClass implements Insertable<SetupValue> {
  final int id;
  final String key;
  final String value;
  const SetupValue({required this.id, required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SetupValuesCompanion toCompanion(bool nullToAbsent) {
    return SetupValuesCompanion(
      id: Value(id),
      key: Value(key),
      value: Value(value),
    );
  }

  factory SetupValue.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetupValue(
      id: serializer.fromJson<int>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SetupValue copyWith({int? id, String? key, String? value}) => SetupValue(
        id: id ?? this.id,
        key: key ?? this.key,
        value: value ?? this.value,
      );
  SetupValue copyWithCompanion(SetupValuesCompanion data) {
    return SetupValue(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetupValue(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetupValue &&
          other.id == this.id &&
          other.key == this.key &&
          other.value == this.value);
}

class SetupValuesCompanion extends UpdateCompanion<SetupValue> {
  final Value<int> id;
  final Value<String> key;
  final Value<String> value;
  const SetupValuesCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
  });
  SetupValuesCompanion.insert({
    this.id = const Value.absent(),
    required String key,
    required String value,
  })  : key = Value(key),
        value = Value(value);
  static Insertable<SetupValue> custom({
    Expression<int>? id,
    Expression<String>? key,
    Expression<String>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
    });
  }

  SetupValuesCompanion copyWith(
      {Value<int>? id, Value<String>? key, Value<String>? value}) {
    return SetupValuesCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetupValuesCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $TemplatesTable extends Templates
    with TableInfo<$TemplatesTable, Template> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => generateId());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isVisibleMeta =
      const VerificationMeta('isVisible');
  @override
  late final GeneratedColumn<bool> isVisible = GeneratedColumn<bool>(
      'is_visible', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_visible" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
      'sort', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, updatedAt, isDeleted, isVisible, title, category, icon, color, sort];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'templates';
  @override
  VerificationContext validateIntegrity(Insertable<Template> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('is_visible')) {
      context.handle(_isVisibleMeta,
          isVisible.isAcceptableOrUnknown(data['is_visible']!, _isVisibleMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('sort')) {
      context.handle(
          _sortMeta, sort.isAcceptableOrUnknown(data['sort']!, _sortMeta));
    } else if (isInserting) {
      context.missing(_sortMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Template map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Template(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      isVisible: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_visible'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      sort: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort'])!,
    );
  }

  @override
  $TemplatesTable createAlias(String alias) {
    return $TemplatesTable(attachedDatabase, alias);
  }
}

class Template extends DataClass implements Insertable<Template> {
  final String id;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isVisible;
  final String title;
  final String? category;
  final String icon;
  final String color;
  final int sort;
  const Template(
      {required this.id,
      required this.updatedAt,
      required this.isDeleted,
      required this.isVisible,
      required this.title,
      this.category,
      required this.icon,
      required this.color,
      required this.sort});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_visible'] = Variable<bool>(isVisible);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<String>(color);
    map['sort'] = Variable<int>(sort);
    return map;
  }

  TemplatesCompanion toCompanion(bool nullToAbsent) {
    return TemplatesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isVisible: Value(isVisible),
      title: Value(title),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      icon: Value(icon),
      color: Value(color),
      sort: Value(sort),
    );
  }

  factory Template.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Template(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isVisible: serializer.fromJson<bool>(json['isVisible']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String?>(json['category']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<String>(json['color']),
      sort: serializer.fromJson<int>(json['sort']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isVisible': serializer.toJson<bool>(isVisible),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String?>(category),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<String>(color),
      'sort': serializer.toJson<int>(sort),
    };
  }

  Template copyWith(
          {String? id,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isVisible,
          String? title,
          Value<String?> category = const Value.absent(),
          String? icon,
          String? color,
          int? sort}) =>
      Template(
        id: id ?? this.id,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isVisible: isVisible ?? this.isVisible,
        title: title ?? this.title,
        category: category.present ? category.value : this.category,
        icon: icon ?? this.icon,
        color: color ?? this.color,
        sort: sort ?? this.sort,
      );
  Template copyWithCompanion(TemplatesCompanion data) {
    return Template(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isVisible: data.isVisible.present ? data.isVisible.value : this.isVisible,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      sort: data.sort.present ? data.sort.value : this.sort,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Template(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isVisible: $isVisible, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sort: $sort')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, updatedAt, isDeleted, isVisible, title, category, icon, color, sort);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Template &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isVisible == this.isVisible &&
          other.title == this.title &&
          other.category == this.category &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.sort == this.sort);
}

class TemplatesCompanion extends UpdateCompanion<Template> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isVisible;
  final Value<String> title;
  final Value<String?> category;
  final Value<String> icon;
  final Value<String> color;
  final Value<int> sort;
  final Value<int> rowid;
  const TemplatesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.sort = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TemplatesCompanion.insert({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isVisible = const Value.absent(),
    required String title,
    this.category = const Value.absent(),
    required String icon,
    required String color,
    required int sort,
    this.rowid = const Value.absent(),
  })  : title = Value(title),
        icon = Value(icon),
        color = Value(color),
        sort = Value(sort);
  static Insertable<Template> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isVisible,
    Expression<String>? title,
    Expression<String>? category,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<int>? sort,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isVisible != null) 'is_visible': isVisible,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (sort != null) 'sort': sort,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TemplatesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isVisible,
      Value<String>? title,
      Value<String?>? category,
      Value<String>? icon,
      Value<String>? color,
      Value<int>? sort,
      Value<int>? rowid}) {
    return TemplatesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isVisible: isVisible ?? this.isVisible,
      title: title ?? this.title,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sort: sort ?? this.sort,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isVisible.present) {
      map['is_visible'] = Variable<bool>(isVisible.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemplatesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isVisible: $isVisible, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sort: $sort, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TemplateDetailsTable extends TemplateDetails
    with TableInfo<$TemplateDetailsTable, TemplateDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplateDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => generateId());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fieldTypeMeta =
      const VerificationMeta('fieldType');
  @override
  late final GeneratedColumnWithTypeConverter<FieldType, String> fieldType =
      GeneratedColumn<String>('field_type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<FieldType>($TemplateDetailsTable.$converterfieldType);
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
      'sort', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _templateIdMeta =
      const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
      'template_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES templates (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, updatedAt, isDeleted, title, fieldType, sort, templateId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'template_details';
  @override
  VerificationContext validateIntegrity(Insertable<TemplateDetail> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    context.handle(_fieldTypeMeta, const VerificationResult.success());
    if (data.containsKey('sort')) {
      context.handle(
          _sortMeta, sort.isAcceptableOrUnknown(data['sort']!, _sortMeta));
    } else if (isInserting) {
      context.missing(_sortMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemplateDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemplateDetail(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      fieldType: $TemplateDetailsTable.$converterfieldType.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}field_type'])!),
      sort: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort'])!,
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_id'])!,
    );
  }

  @override
  $TemplateDetailsTable createAlias(String alias) {
    return $TemplateDetailsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FieldType, String, String> $converterfieldType =
      const EnumNameConverter<FieldType>(FieldType.values);
}

class TemplateDetail extends DataClass implements Insertable<TemplateDetail> {
  final String id;
  final DateTime updatedAt;
  final bool isDeleted;
  final String title;
  final FieldType fieldType;
  final int sort;
  final String templateId;
  const TemplateDetail(
      {required this.id,
      required this.updatedAt,
      required this.isDeleted,
      required this.title,
      required this.fieldType,
      required this.sort,
      required this.templateId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['title'] = Variable<String>(title);
    {
      map['field_type'] = Variable<String>(
          $TemplateDetailsTable.$converterfieldType.toSql(fieldType));
    }
    map['sort'] = Variable<int>(sort);
    map['template_id'] = Variable<String>(templateId);
    return map;
  }

  TemplateDetailsCompanion toCompanion(bool nullToAbsent) {
    return TemplateDetailsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      title: Value(title),
      fieldType: Value(fieldType),
      sort: Value(sort),
      templateId: Value(templateId),
    );
  }

  factory TemplateDetail.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemplateDetail(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      title: serializer.fromJson<String>(json['title']),
      fieldType: $TemplateDetailsTable.$converterfieldType
          .fromJson(serializer.fromJson<String>(json['fieldType'])),
      sort: serializer.fromJson<int>(json['sort']),
      templateId: serializer.fromJson<String>(json['templateId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'title': serializer.toJson<String>(title),
      'fieldType': serializer.toJson<String>(
          $TemplateDetailsTable.$converterfieldType.toJson(fieldType)),
      'sort': serializer.toJson<int>(sort),
      'templateId': serializer.toJson<String>(templateId),
    };
  }

  TemplateDetail copyWith(
          {String? id,
          DateTime? updatedAt,
          bool? isDeleted,
          String? title,
          FieldType? fieldType,
          int? sort,
          String? templateId}) =>
      TemplateDetail(
        id: id ?? this.id,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        title: title ?? this.title,
        fieldType: fieldType ?? this.fieldType,
        sort: sort ?? this.sort,
        templateId: templateId ?? this.templateId,
      );
  TemplateDetail copyWithCompanion(TemplateDetailsCompanion data) {
    return TemplateDetail(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      title: data.title.present ? data.title.value : this.title,
      fieldType: data.fieldType.present ? data.fieldType.value : this.fieldType,
      sort: data.sort.present ? data.sort.value : this.sort,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemplateDetail(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('title: $title, ')
          ..write('fieldType: $fieldType, ')
          ..write('sort: $sort, ')
          ..write('templateId: $templateId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, isDeleted, title, fieldType, sort, templateId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemplateDetail &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.title == this.title &&
          other.fieldType == this.fieldType &&
          other.sort == this.sort &&
          other.templateId == this.templateId);
}

class TemplateDetailsCompanion extends UpdateCompanion<TemplateDetail> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<String> title;
  final Value<FieldType> fieldType;
  final Value<int> sort;
  final Value<String> templateId;
  final Value<int> rowid;
  const TemplateDetailsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.title = const Value.absent(),
    this.fieldType = const Value.absent(),
    this.sort = const Value.absent(),
    this.templateId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TemplateDetailsCompanion.insert({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String title,
    required FieldType fieldType,
    required int sort,
    required String templateId,
    this.rowid = const Value.absent(),
  })  : title = Value(title),
        fieldType = Value(fieldType),
        sort = Value(sort),
        templateId = Value(templateId);
  static Insertable<TemplateDetail> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? title,
    Expression<String>? fieldType,
    Expression<int>? sort,
    Expression<String>? templateId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (title != null) 'title': title,
      if (fieldType != null) 'field_type': fieldType,
      if (sort != null) 'sort': sort,
      if (templateId != null) 'template_id': templateId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TemplateDetailsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<String>? title,
      Value<FieldType>? fieldType,
      Value<int>? sort,
      Value<String>? templateId,
      Value<int>? rowid}) {
    return TemplateDetailsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      title: title ?? this.title,
      fieldType: fieldType ?? this.fieldType,
      sort: sort ?? this.sort,
      templateId: templateId ?? this.templateId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (fieldType.present) {
      map['field_type'] = Variable<String>(
          $TemplateDetailsTable.$converterfieldType.toSql(fieldType.value));
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemplateDetailsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('title: $title, ')
          ..write('fieldType: $fieldType, ')
          ..write('sort: $sort, ')
          ..write('templateId: $templateId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$VaultDatabase extends GeneratedDatabase {
  _$VaultDatabase(QueryExecutor e) : super(e);
  $VaultDatabaseManager get managers => $VaultDatabaseManager(this);
  late final $SetupValuesTable setupValues = $SetupValuesTable(this);
  late final $TemplatesTable templates = $TemplatesTable(this);
  late final $TemplateDetailsTable templateDetails =
      $TemplateDetailsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [setupValues, templates, templateDetails];
}

typedef $$SetupValuesTableCreateCompanionBuilder = SetupValuesCompanion
    Function({
  Value<int> id,
  required String key,
  required String value,
});
typedef $$SetupValuesTableUpdateCompanionBuilder = SetupValuesCompanion
    Function({
  Value<int> id,
  Value<String> key,
  Value<String> value,
});

class $$SetupValuesTableTableManager extends RootTableManager<
    _$VaultDatabase,
    $SetupValuesTable,
    SetupValue,
    $$SetupValuesTableFilterComposer,
    $$SetupValuesTableOrderingComposer,
    $$SetupValuesTableCreateCompanionBuilder,
    $$SetupValuesTableUpdateCompanionBuilder> {
  $$SetupValuesTableTableManager(_$VaultDatabase db, $SetupValuesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SetupValuesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SetupValuesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
          }) =>
              SetupValuesCompanion(
            id: id,
            key: key,
            value: value,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String key,
            required String value,
          }) =>
              SetupValuesCompanion.insert(
            id: id,
            key: key,
            value: value,
          ),
        ));
}

class $$SetupValuesTableFilterComposer
    extends FilterComposer<_$VaultDatabase, $SetupValuesTable> {
  $$SetupValuesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get key => $state.composableBuilder(
      column: $state.table.key,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SetupValuesTableOrderingComposer
    extends OrderingComposer<_$VaultDatabase, $SetupValuesTable> {
  $$SetupValuesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get key => $state.composableBuilder(
      column: $state.table.key,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$TemplatesTableCreateCompanionBuilder = TemplatesCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isVisible,
  required String title,
  Value<String?> category,
  required String icon,
  required String color,
  required int sort,
  Value<int> rowid,
});
typedef $$TemplatesTableUpdateCompanionBuilder = TemplatesCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isVisible,
  Value<String> title,
  Value<String?> category,
  Value<String> icon,
  Value<String> color,
  Value<int> sort,
  Value<int> rowid,
});

class $$TemplatesTableTableManager extends RootTableManager<
    _$VaultDatabase,
    $TemplatesTable,
    Template,
    $$TemplatesTableFilterComposer,
    $$TemplatesTableOrderingComposer,
    $$TemplatesTableCreateCompanionBuilder,
    $$TemplatesTableUpdateCompanionBuilder> {
  $$TemplatesTableTableManager(_$VaultDatabase db, $TemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TemplatesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TemplatesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isVisible = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<int> sort = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TemplatesCompanion(
            id: id,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isVisible: isVisible,
            title: title,
            category: category,
            icon: icon,
            color: color,
            sort: sort,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isVisible = const Value.absent(),
            required String title,
            Value<String?> category = const Value.absent(),
            required String icon,
            required String color,
            required int sort,
            Value<int> rowid = const Value.absent(),
          }) =>
              TemplatesCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isVisible: isVisible,
            title: title,
            category: category,
            icon: icon,
            color: color,
            sort: sort,
            rowid: rowid,
          ),
        ));
}

class $$TemplatesTableFilterComposer
    extends FilterComposer<_$VaultDatabase, $TemplatesTable> {
  $$TemplatesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isDeleted => $state.composableBuilder(
      column: $state.table.isDeleted,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isVisible => $state.composableBuilder(
      column: $state.table.isVisible,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get icon => $state.composableBuilder(
      column: $state.table.icon,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sort => $state.composableBuilder(
      column: $state.table.sort,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter templateDetailsRefs(
      ComposableFilter Function($$TemplateDetailsTableFilterComposer f) f) {
    final $$TemplateDetailsTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.templateDetails,
            getReferencedColumn: (t) => t.templateId,
            builder: (joinBuilder, parentComposers) =>
                $$TemplateDetailsTableFilterComposer(ComposerState($state.db,
                    $state.db.templateDetails, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$TemplatesTableOrderingComposer
    extends OrderingComposer<_$VaultDatabase, $TemplatesTable> {
  $$TemplatesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isDeleted => $state.composableBuilder(
      column: $state.table.isDeleted,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isVisible => $state.composableBuilder(
      column: $state.table.isVisible,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get icon => $state.composableBuilder(
      column: $state.table.icon,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sort => $state.composableBuilder(
      column: $state.table.sort,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$TemplateDetailsTableCreateCompanionBuilder = TemplateDetailsCompanion
    Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  required String title,
  required FieldType fieldType,
  required int sort,
  required String templateId,
  Value<int> rowid,
});
typedef $$TemplateDetailsTableUpdateCompanionBuilder = TemplateDetailsCompanion
    Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<String> title,
  Value<FieldType> fieldType,
  Value<int> sort,
  Value<String> templateId,
  Value<int> rowid,
});

class $$TemplateDetailsTableTableManager extends RootTableManager<
    _$VaultDatabase,
    $TemplateDetailsTable,
    TemplateDetail,
    $$TemplateDetailsTableFilterComposer,
    $$TemplateDetailsTableOrderingComposer,
    $$TemplateDetailsTableCreateCompanionBuilder,
    $$TemplateDetailsTableUpdateCompanionBuilder> {
  $$TemplateDetailsTableTableManager(
      _$VaultDatabase db, $TemplateDetailsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TemplateDetailsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TemplateDetailsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<FieldType> fieldType = const Value.absent(),
            Value<int> sort = const Value.absent(),
            Value<String> templateId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TemplateDetailsCompanion(
            id: id,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            title: title,
            fieldType: fieldType,
            sort: sort,
            templateId: templateId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            required String title,
            required FieldType fieldType,
            required int sort,
            required String templateId,
            Value<int> rowid = const Value.absent(),
          }) =>
              TemplateDetailsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            title: title,
            fieldType: fieldType,
            sort: sort,
            templateId: templateId,
            rowid: rowid,
          ),
        ));
}

class $$TemplateDetailsTableFilterComposer
    extends FilterComposer<_$VaultDatabase, $TemplateDetailsTable> {
  $$TemplateDetailsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isDeleted => $state.composableBuilder(
      column: $state.table.isDeleted,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<FieldType, FieldType, String> get fieldType =>
      $state.composableBuilder(
          column: $state.table.fieldType,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<int> get sort => $state.composableBuilder(
      column: $state.table.sort,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$TemplatesTableFilterComposer get templateId {
    final $$TemplatesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $state.db.templates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$TemplatesTableFilterComposer(ComposerState(
                $state.db, $state.db.templates, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$TemplateDetailsTableOrderingComposer
    extends OrderingComposer<_$VaultDatabase, $TemplateDetailsTable> {
  $$TemplateDetailsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isDeleted => $state.composableBuilder(
      column: $state.table.isDeleted,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fieldType => $state.composableBuilder(
      column: $state.table.fieldType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sort => $state.composableBuilder(
      column: $state.table.sort,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$TemplatesTableOrderingComposer get templateId {
    final $$TemplatesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $state.db.templates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$TemplatesTableOrderingComposer(ComposerState(
                $state.db, $state.db.templates, joinBuilder, parentComposers)));
    return composer;
  }
}

class $VaultDatabaseManager {
  final _$VaultDatabase _db;
  $VaultDatabaseManager(this._db);
  $$SetupValuesTableTableManager get setupValues =>
      $$SetupValuesTableTableManager(_db, _db.setupValues);
  $$TemplatesTableTableManager get templates =>
      $$TemplatesTableTableManager(_db, _db.templates);
  $$TemplateDetailsTableTableManager get templateDetails =>
      $$TemplateDetailsTableTableManager(_db, _db.templateDetails);
}
