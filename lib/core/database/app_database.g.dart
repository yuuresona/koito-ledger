// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoryRecordsTable extends CategoryRecords
    with TableInfo<$CategoryRecordsTable, CategoryRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryTypeMeta = const VerificationMeta(
    'entryType',
  );
  @override
  late final GeneratedColumn<int> entryType = GeneratedColumn<int>(
    'entry_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (entry_type IN (0, 1))',
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _createdAtMicrosMeta = const VerificationMeta(
    'createdAtMicros',
  );
  @override
  late final GeneratedColumn<int> createdAtMicros = GeneratedColumn<int>(
    'created_at_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMicrosMeta = const VerificationMeta(
    'updatedAtMicros',
  );
  @override
  late final GeneratedColumn<int> updatedAtMicros = GeneratedColumn<int>(
    'updated_at_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    normalizedName,
    entryType,
    parentId,
    createdAtMicros,
    updatedAtMicros,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('entry_type')) {
      context.handle(
        _entryTypeMeta,
        entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('created_at_micros')) {
      context.handle(
        _createdAtMicrosMeta,
        createdAtMicros.isAcceptableOrUnknown(
          data['created_at_micros']!,
          _createdAtMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMicrosMeta);
    }
    if (data.containsKey('updated_at_micros')) {
      context.handle(
        _updatedAtMicrosMeta,
        updatedAtMicros.isAcceptableOrUnknown(
          data['updated_at_micros']!,
          _updatedAtMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMicrosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      entryType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_type'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      createdAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_micros'],
      )!,
      updatedAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_micros'],
      )!,
    );
  }

  @override
  $CategoryRecordsTable createAlias(String alias) {
    return $CategoryRecordsTable(attachedDatabase, alias);
  }
}

class CategoryRecord extends DataClass implements Insertable<CategoryRecord> {
  final int id;
  final String name;
  final String normalizedName;
  final int entryType;
  final int? parentId;
  final int createdAtMicros;
  final int updatedAtMicros;
  const CategoryRecord({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.entryType,
    this.parentId,
    required this.createdAtMicros,
    required this.updatedAtMicros,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['entry_type'] = Variable<int>(entryType);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['created_at_micros'] = Variable<int>(createdAtMicros);
    map['updated_at_micros'] = Variable<int>(updatedAtMicros);
    return map;
  }

  CategoryRecordsCompanion toCompanion(bool nullToAbsent) {
    return CategoryRecordsCompanion(
      id: Value(id),
      name: Value(name),
      normalizedName: Value(normalizedName),
      entryType: Value(entryType),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      createdAtMicros: Value(createdAtMicros),
      updatedAtMicros: Value(updatedAtMicros),
    );
  }

  factory CategoryRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRecord(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      entryType: serializer.fromJson<int>(json['entryType']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      createdAtMicros: serializer.fromJson<int>(json['createdAtMicros']),
      updatedAtMicros: serializer.fromJson<int>(json['updatedAtMicros']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'entryType': serializer.toJson<int>(entryType),
      'parentId': serializer.toJson<int?>(parentId),
      'createdAtMicros': serializer.toJson<int>(createdAtMicros),
      'updatedAtMicros': serializer.toJson<int>(updatedAtMicros),
    };
  }

  CategoryRecord copyWith({
    int? id,
    String? name,
    String? normalizedName,
    int? entryType,
    Value<int?> parentId = const Value.absent(),
    int? createdAtMicros,
    int? updatedAtMicros,
  }) => CategoryRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    entryType: entryType ?? this.entryType,
    parentId: parentId.present ? parentId.value : this.parentId,
    createdAtMicros: createdAtMicros ?? this.createdAtMicros,
    updatedAtMicros: updatedAtMicros ?? this.updatedAtMicros,
  );
  CategoryRecord copyWithCompanion(CategoryRecordsCompanion data) {
    return CategoryRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      createdAtMicros: data.createdAtMicros.present
          ? data.createdAtMicros.value
          : this.createdAtMicros,
      updatedAtMicros: data.updatedAtMicros.present
          ? data.updatedAtMicros.value
          : this.updatedAtMicros,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('entryType: $entryType, ')
          ..write('parentId: $parentId, ')
          ..write('createdAtMicros: $createdAtMicros, ')
          ..write('updatedAtMicros: $updatedAtMicros')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    normalizedName,
    entryType,
    parentId,
    createdAtMicros,
    updatedAtMicros,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.entryType == this.entryType &&
          other.parentId == this.parentId &&
          other.createdAtMicros == this.createdAtMicros &&
          other.updatedAtMicros == this.updatedAtMicros);
}

class CategoryRecordsCompanion extends UpdateCompanion<CategoryRecord> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<int> entryType;
  final Value<int?> parentId;
  final Value<int> createdAtMicros;
  final Value<int> updatedAtMicros;
  const CategoryRecordsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.entryType = const Value.absent(),
    this.parentId = const Value.absent(),
    this.createdAtMicros = const Value.absent(),
    this.updatedAtMicros = const Value.absent(),
  });
  CategoryRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String normalizedName,
    required int entryType,
    this.parentId = const Value.absent(),
    required int createdAtMicros,
    required int updatedAtMicros,
  }) : name = Value(name),
       normalizedName = Value(normalizedName),
       entryType = Value(entryType),
       createdAtMicros = Value(createdAtMicros),
       updatedAtMicros = Value(updatedAtMicros);
  static Insertable<CategoryRecord> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<int>? entryType,
    Expression<int>? parentId,
    Expression<int>? createdAtMicros,
    Expression<int>? updatedAtMicros,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (entryType != null) 'entry_type': entryType,
      if (parentId != null) 'parent_id': parentId,
      if (createdAtMicros != null) 'created_at_micros': createdAtMicros,
      if (updatedAtMicros != null) 'updated_at_micros': updatedAtMicros,
    });
  }

  CategoryRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<int>? entryType,
    Value<int?>? parentId,
    Value<int>? createdAtMicros,
    Value<int>? updatedAtMicros,
  }) {
    return CategoryRecordsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      entryType: entryType ?? this.entryType,
      parentId: parentId ?? this.parentId,
      createdAtMicros: createdAtMicros ?? this.createdAtMicros,
      updatedAtMicros: updatedAtMicros ?? this.updatedAtMicros,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<int>(entryType.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (createdAtMicros.present) {
      map['created_at_micros'] = Variable<int>(createdAtMicros.value);
    }
    if (updatedAtMicros.present) {
      map['updated_at_micros'] = Variable<int>(updatedAtMicros.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRecordsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('entryType: $entryType, ')
          ..write('parentId: $parentId, ')
          ..write('createdAtMicros: $createdAtMicros, ')
          ..write('updatedAtMicros: $updatedAtMicros')
          ..write(')'))
        .toString();
  }
}

class $LedgerTransactionsTable extends LedgerTransactions
    with TableInfo<$LedgerTransactionsTable, LedgerTransactionRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (amount_cents > 0 AND amount_cents <= 99999999999)',
  );
  static const VerificationMeta _dateEpochDayMeta = const VerificationMeta(
    'dateEpochDay',
  );
  @override
  late final GeneratedColumn<int> dateEpochDay = GeneratedColumn<int>(
    'date_epoch_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryTypeMeta = const VerificationMeta(
    'entryType',
  );
  @override
  late final GeneratedColumn<int> entryType = GeneratedColumn<int>(
    'entry_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (entry_type IN (0, 1))',
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _subcategoryIdMeta = const VerificationMeta(
    'subcategoryId',
  );
  @override
  late final GeneratedColumn<int> subcategoryId = GeneratedColumn<int>(
    'subcategory_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMicrosMeta = const VerificationMeta(
    'createdAtMicros',
  );
  @override
  late final GeneratedColumn<int> createdAtMicros = GeneratedColumn<int>(
    'created_at_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMicrosMeta = const VerificationMeta(
    'updatedAtMicros',
  );
  @override
  late final GeneratedColumn<int> updatedAtMicros = GeneratedColumn<int>(
    'updated_at_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountCents,
    dateEpochDay,
    entryType,
    categoryId,
    subcategoryId,
    note,
    createdAtMicros,
    updatedAtMicros,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerTransactionRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('date_epoch_day')) {
      context.handle(
        _dateEpochDayMeta,
        dateEpochDay.isAcceptableOrUnknown(
          data['date_epoch_day']!,
          _dateEpochDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateEpochDayMeta);
    }
    if (data.containsKey('entry_type')) {
      context.handle(
        _entryTypeMeta,
        entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('subcategory_id')) {
      context.handle(
        _subcategoryIdMeta,
        subcategoryId.isAcceptableOrUnknown(
          data['subcategory_id']!,
          _subcategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at_micros')) {
      context.handle(
        _createdAtMicrosMeta,
        createdAtMicros.isAcceptableOrUnknown(
          data['created_at_micros']!,
          _createdAtMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMicrosMeta);
    }
    if (data.containsKey('updated_at_micros')) {
      context.handle(
        _updatedAtMicrosMeta,
        updatedAtMicros.isAcceptableOrUnknown(
          data['updated_at_micros']!,
          _updatedAtMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMicrosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerTransactionRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerTransactionRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      dateEpochDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_epoch_day'],
      )!,
      entryType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_type'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      subcategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subcategory_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_micros'],
      )!,
      updatedAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_micros'],
      )!,
    );
  }

  @override
  $LedgerTransactionsTable createAlias(String alias) {
    return $LedgerTransactionsTable(attachedDatabase, alias);
  }
}

class LedgerTransactionRecord extends DataClass
    implements Insertable<LedgerTransactionRecord> {
  final int id;
  final int amountCents;
  final int dateEpochDay;
  final int entryType;
  final int categoryId;
  final int? subcategoryId;
  final String? note;
  final int createdAtMicros;
  final int updatedAtMicros;
  const LedgerTransactionRecord({
    required this.id,
    required this.amountCents,
    required this.dateEpochDay,
    required this.entryType,
    required this.categoryId,
    this.subcategoryId,
    this.note,
    required this.createdAtMicros,
    required this.updatedAtMicros,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount_cents'] = Variable<int>(amountCents);
    map['date_epoch_day'] = Variable<int>(dateEpochDay);
    map['entry_type'] = Variable<int>(entryType);
    map['category_id'] = Variable<int>(categoryId);
    if (!nullToAbsent || subcategoryId != null) {
      map['subcategory_id'] = Variable<int>(subcategoryId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at_micros'] = Variable<int>(createdAtMicros);
    map['updated_at_micros'] = Variable<int>(updatedAtMicros);
    return map;
  }

  LedgerTransactionsCompanion toCompanion(bool nullToAbsent) {
    return LedgerTransactionsCompanion(
      id: Value(id),
      amountCents: Value(amountCents),
      dateEpochDay: Value(dateEpochDay),
      entryType: Value(entryType),
      categoryId: Value(categoryId),
      subcategoryId: subcategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategoryId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAtMicros: Value(createdAtMicros),
      updatedAtMicros: Value(updatedAtMicros),
    );
  }

  factory LedgerTransactionRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerTransactionRecord(
      id: serializer.fromJson<int>(json['id']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      dateEpochDay: serializer.fromJson<int>(json['dateEpochDay']),
      entryType: serializer.fromJson<int>(json['entryType']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      subcategoryId: serializer.fromJson<int?>(json['subcategoryId']),
      note: serializer.fromJson<String?>(json['note']),
      createdAtMicros: serializer.fromJson<int>(json['createdAtMicros']),
      updatedAtMicros: serializer.fromJson<int>(json['updatedAtMicros']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amountCents': serializer.toJson<int>(amountCents),
      'dateEpochDay': serializer.toJson<int>(dateEpochDay),
      'entryType': serializer.toJson<int>(entryType),
      'categoryId': serializer.toJson<int>(categoryId),
      'subcategoryId': serializer.toJson<int?>(subcategoryId),
      'note': serializer.toJson<String?>(note),
      'createdAtMicros': serializer.toJson<int>(createdAtMicros),
      'updatedAtMicros': serializer.toJson<int>(updatedAtMicros),
    };
  }

  LedgerTransactionRecord copyWith({
    int? id,
    int? amountCents,
    int? dateEpochDay,
    int? entryType,
    int? categoryId,
    Value<int?> subcategoryId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? createdAtMicros,
    int? updatedAtMicros,
  }) => LedgerTransactionRecord(
    id: id ?? this.id,
    amountCents: amountCents ?? this.amountCents,
    dateEpochDay: dateEpochDay ?? this.dateEpochDay,
    entryType: entryType ?? this.entryType,
    categoryId: categoryId ?? this.categoryId,
    subcategoryId: subcategoryId.present
        ? subcategoryId.value
        : this.subcategoryId,
    note: note.present ? note.value : this.note,
    createdAtMicros: createdAtMicros ?? this.createdAtMicros,
    updatedAtMicros: updatedAtMicros ?? this.updatedAtMicros,
  );
  LedgerTransactionRecord copyWithCompanion(LedgerTransactionsCompanion data) {
    return LedgerTransactionRecord(
      id: data.id.present ? data.id.value : this.id,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      dateEpochDay: data.dateEpochDay.present
          ? data.dateEpochDay.value
          : this.dateEpochDay,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      subcategoryId: data.subcategoryId.present
          ? data.subcategoryId.value
          : this.subcategoryId,
      note: data.note.present ? data.note.value : this.note,
      createdAtMicros: data.createdAtMicros.present
          ? data.createdAtMicros.value
          : this.createdAtMicros,
      updatedAtMicros: data.updatedAtMicros.present
          ? data.updatedAtMicros.value
          : this.updatedAtMicros,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerTransactionRecord(')
          ..write('id: $id, ')
          ..write('amountCents: $amountCents, ')
          ..write('dateEpochDay: $dateEpochDay, ')
          ..write('entryType: $entryType, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('note: $note, ')
          ..write('createdAtMicros: $createdAtMicros, ')
          ..write('updatedAtMicros: $updatedAtMicros')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amountCents,
    dateEpochDay,
    entryType,
    categoryId,
    subcategoryId,
    note,
    createdAtMicros,
    updatedAtMicros,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerTransactionRecord &&
          other.id == this.id &&
          other.amountCents == this.amountCents &&
          other.dateEpochDay == this.dateEpochDay &&
          other.entryType == this.entryType &&
          other.categoryId == this.categoryId &&
          other.subcategoryId == this.subcategoryId &&
          other.note == this.note &&
          other.createdAtMicros == this.createdAtMicros &&
          other.updatedAtMicros == this.updatedAtMicros);
}

class LedgerTransactionsCompanion
    extends UpdateCompanion<LedgerTransactionRecord> {
  final Value<int> id;
  final Value<int> amountCents;
  final Value<int> dateEpochDay;
  final Value<int> entryType;
  final Value<int> categoryId;
  final Value<int?> subcategoryId;
  final Value<String?> note;
  final Value<int> createdAtMicros;
  final Value<int> updatedAtMicros;
  const LedgerTransactionsCompanion({
    this.id = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.dateEpochDay = const Value.absent(),
    this.entryType = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.subcategoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAtMicros = const Value.absent(),
    this.updatedAtMicros = const Value.absent(),
  });
  LedgerTransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int amountCents,
    required int dateEpochDay,
    required int entryType,
    required int categoryId,
    this.subcategoryId = const Value.absent(),
    this.note = const Value.absent(),
    required int createdAtMicros,
    required int updatedAtMicros,
  }) : amountCents = Value(amountCents),
       dateEpochDay = Value(dateEpochDay),
       entryType = Value(entryType),
       categoryId = Value(categoryId),
       createdAtMicros = Value(createdAtMicros),
       updatedAtMicros = Value(updatedAtMicros);
  static Insertable<LedgerTransactionRecord> custom({
    Expression<int>? id,
    Expression<int>? amountCents,
    Expression<int>? dateEpochDay,
    Expression<int>? entryType,
    Expression<int>? categoryId,
    Expression<int>? subcategoryId,
    Expression<String>? note,
    Expression<int>? createdAtMicros,
    Expression<int>? updatedAtMicros,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountCents != null) 'amount_cents': amountCents,
      if (dateEpochDay != null) 'date_epoch_day': dateEpochDay,
      if (entryType != null) 'entry_type': entryType,
      if (categoryId != null) 'category_id': categoryId,
      if (subcategoryId != null) 'subcategory_id': subcategoryId,
      if (note != null) 'note': note,
      if (createdAtMicros != null) 'created_at_micros': createdAtMicros,
      if (updatedAtMicros != null) 'updated_at_micros': updatedAtMicros,
    });
  }

  LedgerTransactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? amountCents,
    Value<int>? dateEpochDay,
    Value<int>? entryType,
    Value<int>? categoryId,
    Value<int?>? subcategoryId,
    Value<String?>? note,
    Value<int>? createdAtMicros,
    Value<int>? updatedAtMicros,
  }) {
    return LedgerTransactionsCompanion(
      id: id ?? this.id,
      amountCents: amountCents ?? this.amountCents,
      dateEpochDay: dateEpochDay ?? this.dateEpochDay,
      entryType: entryType ?? this.entryType,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      note: note ?? this.note,
      createdAtMicros: createdAtMicros ?? this.createdAtMicros,
      updatedAtMicros: updatedAtMicros ?? this.updatedAtMicros,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (dateEpochDay.present) {
      map['date_epoch_day'] = Variable<int>(dateEpochDay.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<int>(entryType.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (subcategoryId.present) {
      map['subcategory_id'] = Variable<int>(subcategoryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAtMicros.present) {
      map['created_at_micros'] = Variable<int>(createdAtMicros.value);
    }
    if (updatedAtMicros.present) {
      map['updated_at_micros'] = Variable<int>(updatedAtMicros.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amountCents: $amountCents, ')
          ..write('dateEpochDay: $dateEpochDay, ')
          ..write('entryType: $entryType, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('note: $note, ')
          ..write('createdAtMicros: $createdAtMicros, ')
          ..write('updatedAtMicros: $updatedAtMicros')
          ..write(')'))
        .toString();
  }
}

class $TransactionDraftRecordsTable extends TransactionDraftRecords
    with TableInfo<$TransactionDraftRecordsTable, TransactionDraftRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionDraftRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL CHECK (id = 1)',
  );
  static const VerificationMeta _amountTextMeta = const VerificationMeta(
    'amountText',
  );
  @override
  late final GeneratedColumn<String> amountText = GeneratedColumn<String>(
    'amount_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryTypeMeta = const VerificationMeta(
    'entryType',
  );
  @override
  late final GeneratedColumn<int> entryType = GeneratedColumn<int>(
    'entry_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (entry_type IN (0, 1))',
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _subcategoryIdMeta = const VerificationMeta(
    'subcategoryId',
  );
  @override
  late final GeneratedColumn<int> subcategoryId = GeneratedColumn<int>(
    'subcategory_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMicrosMeta = const VerificationMeta(
    'updatedAtMicros',
  );
  @override
  late final GeneratedColumn<int> updatedAtMicros = GeneratedColumn<int>(
    'updated_at_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountText,
    entryType,
    categoryId,
    subcategoryId,
    note,
    updatedAtMicros,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_draft_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionDraftRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount_text')) {
      context.handle(
        _amountTextMeta,
        amountText.isAcceptableOrUnknown(data['amount_text']!, _amountTextMeta),
      );
    } else if (isInserting) {
      context.missing(_amountTextMeta);
    }
    if (data.containsKey('entry_type')) {
      context.handle(
        _entryTypeMeta,
        entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('subcategory_id')) {
      context.handle(
        _subcategoryIdMeta,
        subcategoryId.isAcceptableOrUnknown(
          data['subcategory_id']!,
          _subcategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('updated_at_micros')) {
      context.handle(
        _updatedAtMicrosMeta,
        updatedAtMicros.isAcceptableOrUnknown(
          data['updated_at_micros']!,
          _updatedAtMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMicrosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionDraftRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionDraftRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amountText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount_text'],
      )!,
      entryType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_type'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      subcategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subcategory_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      updatedAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_micros'],
      )!,
    );
  }

  @override
  $TransactionDraftRecordsTable createAlias(String alias) {
    return $TransactionDraftRecordsTable(attachedDatabase, alias);
  }
}

class TransactionDraftRecord extends DataClass
    implements Insertable<TransactionDraftRecord> {
  final int id;
  final String amountText;
  final int entryType;
  final int? categoryId;
  final int? subcategoryId;
  final String note;
  final int updatedAtMicros;
  const TransactionDraftRecord({
    required this.id,
    required this.amountText,
    required this.entryType,
    this.categoryId,
    this.subcategoryId,
    required this.note,
    required this.updatedAtMicros,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount_text'] = Variable<String>(amountText);
    map['entry_type'] = Variable<int>(entryType);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || subcategoryId != null) {
      map['subcategory_id'] = Variable<int>(subcategoryId);
    }
    map['note'] = Variable<String>(note);
    map['updated_at_micros'] = Variable<int>(updatedAtMicros);
    return map;
  }

  TransactionDraftRecordsCompanion toCompanion(bool nullToAbsent) {
    return TransactionDraftRecordsCompanion(
      id: Value(id),
      amountText: Value(amountText),
      entryType: Value(entryType),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      subcategoryId: subcategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategoryId),
      note: Value(note),
      updatedAtMicros: Value(updatedAtMicros),
    );
  }

  factory TransactionDraftRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionDraftRecord(
      id: serializer.fromJson<int>(json['id']),
      amountText: serializer.fromJson<String>(json['amountText']),
      entryType: serializer.fromJson<int>(json['entryType']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      subcategoryId: serializer.fromJson<int?>(json['subcategoryId']),
      note: serializer.fromJson<String>(json['note']),
      updatedAtMicros: serializer.fromJson<int>(json['updatedAtMicros']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amountText': serializer.toJson<String>(amountText),
      'entryType': serializer.toJson<int>(entryType),
      'categoryId': serializer.toJson<int?>(categoryId),
      'subcategoryId': serializer.toJson<int?>(subcategoryId),
      'note': serializer.toJson<String>(note),
      'updatedAtMicros': serializer.toJson<int>(updatedAtMicros),
    };
  }

  TransactionDraftRecord copyWith({
    int? id,
    String? amountText,
    int? entryType,
    Value<int?> categoryId = const Value.absent(),
    Value<int?> subcategoryId = const Value.absent(),
    String? note,
    int? updatedAtMicros,
  }) => TransactionDraftRecord(
    id: id ?? this.id,
    amountText: amountText ?? this.amountText,
    entryType: entryType ?? this.entryType,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    subcategoryId: subcategoryId.present
        ? subcategoryId.value
        : this.subcategoryId,
    note: note ?? this.note,
    updatedAtMicros: updatedAtMicros ?? this.updatedAtMicros,
  );
  TransactionDraftRecord copyWithCompanion(
    TransactionDraftRecordsCompanion data,
  ) {
    return TransactionDraftRecord(
      id: data.id.present ? data.id.value : this.id,
      amountText: data.amountText.present
          ? data.amountText.value
          : this.amountText,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      subcategoryId: data.subcategoryId.present
          ? data.subcategoryId.value
          : this.subcategoryId,
      note: data.note.present ? data.note.value : this.note,
      updatedAtMicros: data.updatedAtMicros.present
          ? data.updatedAtMicros.value
          : this.updatedAtMicros,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionDraftRecord(')
          ..write('id: $id, ')
          ..write('amountText: $amountText, ')
          ..write('entryType: $entryType, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('note: $note, ')
          ..write('updatedAtMicros: $updatedAtMicros')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amountText,
    entryType,
    categoryId,
    subcategoryId,
    note,
    updatedAtMicros,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionDraftRecord &&
          other.id == this.id &&
          other.amountText == this.amountText &&
          other.entryType == this.entryType &&
          other.categoryId == this.categoryId &&
          other.subcategoryId == this.subcategoryId &&
          other.note == this.note &&
          other.updatedAtMicros == this.updatedAtMicros);
}

class TransactionDraftRecordsCompanion
    extends UpdateCompanion<TransactionDraftRecord> {
  final Value<int> id;
  final Value<String> amountText;
  final Value<int> entryType;
  final Value<int?> categoryId;
  final Value<int?> subcategoryId;
  final Value<String> note;
  final Value<int> updatedAtMicros;
  const TransactionDraftRecordsCompanion({
    this.id = const Value.absent(),
    this.amountText = const Value.absent(),
    this.entryType = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.subcategoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAtMicros = const Value.absent(),
  });
  TransactionDraftRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String amountText,
    required int entryType,
    this.categoryId = const Value.absent(),
    this.subcategoryId = const Value.absent(),
    required String note,
    required int updatedAtMicros,
  }) : amountText = Value(amountText),
       entryType = Value(entryType),
       note = Value(note),
       updatedAtMicros = Value(updatedAtMicros);
  static Insertable<TransactionDraftRecord> custom({
    Expression<int>? id,
    Expression<String>? amountText,
    Expression<int>? entryType,
    Expression<int>? categoryId,
    Expression<int>? subcategoryId,
    Expression<String>? note,
    Expression<int>? updatedAtMicros,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountText != null) 'amount_text': amountText,
      if (entryType != null) 'entry_type': entryType,
      if (categoryId != null) 'category_id': categoryId,
      if (subcategoryId != null) 'subcategory_id': subcategoryId,
      if (note != null) 'note': note,
      if (updatedAtMicros != null) 'updated_at_micros': updatedAtMicros,
    });
  }

  TransactionDraftRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? amountText,
    Value<int>? entryType,
    Value<int?>? categoryId,
    Value<int?>? subcategoryId,
    Value<String>? note,
    Value<int>? updatedAtMicros,
  }) {
    return TransactionDraftRecordsCompanion(
      id: id ?? this.id,
      amountText: amountText ?? this.amountText,
      entryType: entryType ?? this.entryType,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      note: note ?? this.note,
      updatedAtMicros: updatedAtMicros ?? this.updatedAtMicros,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amountText.present) {
      map['amount_text'] = Variable<String>(amountText.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<int>(entryType.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (subcategoryId.present) {
      map['subcategory_id'] = Variable<int>(subcategoryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (updatedAtMicros.present) {
      map['updated_at_micros'] = Variable<int>(updatedAtMicros.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionDraftRecordsCompanion(')
          ..write('id: $id, ')
          ..write('amountText: $amountText, ')
          ..write('entryType: $entryType, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('note: $note, ')
          ..write('updatedAtMicros: $updatedAtMicros')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoryRecordsTable categoryRecords = $CategoryRecordsTable(
    this,
  );
  late final $LedgerTransactionsTable ledgerTransactions =
      $LedgerTransactionsTable(this);
  late final $TransactionDraftRecordsTable transactionDraftRecords =
      $TransactionDraftRecordsTable(this);
  late final Index categoriesLevel2NameUnique = Index(
    'categories_level2_name_unique',
    'CREATE UNIQUE INDEX categories_level2_name_unique ON categories (entry_type, normalized_name) WHERE parent_id IS NULL',
  );
  late final Index categoriesLevel3NameUnique = Index(
    'categories_level3_name_unique',
    'CREATE UNIQUE INDEX categories_level3_name_unique ON categories (parent_id, normalized_name) WHERE parent_id IS NOT NULL',
  );
  late final Index categoriesCreationOrder = Index(
    'categories_creation_order',
    'CREATE INDEX categories_creation_order ON categories (entry_type, parent_id, created_at_micros, id)',
  );
  late final Index transactionsMonthOrder = Index(
    'transactions_month_order',
    'CREATE INDEX transactions_month_order ON ledger_transactions (date_epoch_day, created_at_micros)',
  );
  late final Index transactionsCategory = Index(
    'transactions_category',
    'CREATE INDEX transactions_category ON ledger_transactions (category_id)',
  );
  late final Index transactionsSubcategory = Index(
    'transactions_subcategory',
    'CREATE INDEX transactions_subcategory ON ledger_transactions (subcategory_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categoryRecords,
    ledgerTransactions,
    transactionDraftRecords,
    categoriesLevel2NameUnique,
    categoriesLevel3NameUnique,
    categoriesCreationOrder,
    transactionsMonthOrder,
    transactionsCategory,
    transactionsSubcategory,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('transaction_draft_records', kind: UpdateKind.update),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('transaction_draft_records', kind: UpdateKind.update),
      ],
    ),
  ]);
}

typedef $$CategoryRecordsTableCreateCompanionBuilder =
    CategoryRecordsCompanion Function({
      Value<int> id,
      required String name,
      required String normalizedName,
      required int entryType,
      Value<int?> parentId,
      required int createdAtMicros,
      required int updatedAtMicros,
    });
typedef $$CategoryRecordsTableUpdateCompanionBuilder =
    CategoryRecordsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> normalizedName,
      Value<int> entryType,
      Value<int?> parentId,
      Value<int> createdAtMicros,
      Value<int> updatedAtMicros,
    });

final class $$CategoryRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CategoryRecordsTable, CategoryRecord> {
  $$CategoryRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoryRecordsTable _parentIdTable(_$AppDatabase db) =>
      db.categoryRecords.createAlias('categories__parent_id__categories__id');

  $$CategoryRecordsTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<int>('parent_id');
    if ($_column == null) return null;
    final manager = $$CategoryRecordsTableTableManager(
      $_db,
      $_db.categoryRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $LedgerTransactionsTable,
    List<LedgerTransactionRecord>
  >
  _levelTwoCategoryTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ledgerTransactions,
    aliasName: 'categories__id__ledger_transactions__category_id',
  );

  $$LedgerTransactionsTableProcessedTableManager get levelTwoCategory {
    final manager = $$LedgerTransactionsTableTableManager(
      $_db,
      $_db.ledgerTransactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_levelTwoCategoryTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $LedgerTransactionsTable,
    List<LedgerTransactionRecord>
  >
  _levelThreeCategoryTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ledgerTransactions,
    aliasName: 'categories__id__ledger_transactions__subcategory_id',
  );

  $$LedgerTransactionsTableProcessedTableManager get levelThreeCategory {
    final manager = $$LedgerTransactionsTableTableManager(
      $_db,
      $_db.ledgerTransactions,
    ).filter((f) => f.subcategoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_levelThreeCategoryTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TransactionDraftRecordsTable,
    List<TransactionDraftRecord>
  >
  _draftLevelTwoCategoryTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionDraftRecords,
        aliasName: 'categories__id__transaction_draft_records__category_id',
      );

  $$TransactionDraftRecordsTableProcessedTableManager
  get draftLevelTwoCategory {
    final manager = $$TransactionDraftRecordsTableTableManager(
      $_db,
      $_db.transactionDraftRecords,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _draftLevelTwoCategoryTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TransactionDraftRecordsTable,
    List<TransactionDraftRecord>
  >
  _draftLevelThreeCategoryTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionDraftRecords,
        aliasName: 'categories__id__transaction_draft_records__subcategory_id',
      );

  $$TransactionDraftRecordsTableProcessedTableManager
  get draftLevelThreeCategory {
    final manager = $$TransactionDraftRecordsTableTableManager(
      $_db,
      $_db.transactionDraftRecords,
    ).filter((f) => f.subcategoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _draftLevelThreeCategoryTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoryRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryRecordsTable> {
  $$CategoryRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMicros => $composableBuilder(
    column: $table.createdAtMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMicros => $composableBuilder(
    column: $table.updatedAtMicros,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoryRecordsTableFilterComposer get parentId {
    final $$CategoryRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categoryRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRecordsTableFilterComposer(
            $db: $db,
            $table: $db.categoryRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> levelTwoCategory(
    Expression<bool> Function($$LedgerTransactionsTableFilterComposer f) f,
  ) {
    final $$LedgerTransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerTransactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerTransactionsTableFilterComposer(
            $db: $db,
            $table: $db.ledgerTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> levelThreeCategory(
    Expression<bool> Function($$LedgerTransactionsTableFilterComposer f) f,
  ) {
    final $$LedgerTransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerTransactions,
      getReferencedColumn: (t) => t.subcategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerTransactionsTableFilterComposer(
            $db: $db,
            $table: $db.ledgerTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> draftLevelTwoCategory(
    Expression<bool> Function($$TransactionDraftRecordsTableFilterComposer f) f,
  ) {
    final $$TransactionDraftRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionDraftRecords,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionDraftRecordsTableFilterComposer(
                $db: $db,
                $table: $db.transactionDraftRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> draftLevelThreeCategory(
    Expression<bool> Function($$TransactionDraftRecordsTableFilterComposer f) f,
  ) {
    final $$TransactionDraftRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionDraftRecords,
          getReferencedColumn: (t) => t.subcategoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionDraftRecordsTableFilterComposer(
                $db: $db,
                $table: $db.transactionDraftRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CategoryRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryRecordsTable> {
  $$CategoryRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMicros => $composableBuilder(
    column: $table.createdAtMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMicros => $composableBuilder(
    column: $table.updatedAtMicros,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoryRecordsTableOrderingComposer get parentId {
    final $$CategoryRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categoryRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.categoryRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryRecordsTable> {
  $$CategoryRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<int> get createdAtMicros => $composableBuilder(
    column: $table.createdAtMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMicros => $composableBuilder(
    column: $table.updatedAtMicros,
    builder: (column) => column,
  );

  $$CategoryRecordsTableAnnotationComposer get parentId {
    final $$CategoryRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categoryRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.categoryRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> levelTwoCategory<T extends Object>(
    Expression<T> Function($$LedgerTransactionsTableAnnotationComposer a) f,
  ) {
    final $$LedgerTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ledgerTransactions,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LedgerTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.ledgerTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> levelThreeCategory<T extends Object>(
    Expression<T> Function($$LedgerTransactionsTableAnnotationComposer a) f,
  ) {
    final $$LedgerTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.ledgerTransactions,
          getReferencedColumn: (t) => t.subcategoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LedgerTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.ledgerTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> draftLevelTwoCategory<T extends Object>(
    Expression<T> Function($$TransactionDraftRecordsTableAnnotationComposer a)
    f,
  ) {
    final $$TransactionDraftRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionDraftRecords,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionDraftRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionDraftRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> draftLevelThreeCategory<T extends Object>(
    Expression<T> Function($$TransactionDraftRecordsTableAnnotationComposer a)
    f,
  ) {
    final $$TransactionDraftRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionDraftRecords,
          getReferencedColumn: (t) => t.subcategoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionDraftRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionDraftRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CategoryRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryRecordsTable,
          CategoryRecord,
          $$CategoryRecordsTableFilterComposer,
          $$CategoryRecordsTableOrderingComposer,
          $$CategoryRecordsTableAnnotationComposer,
          $$CategoryRecordsTableCreateCompanionBuilder,
          $$CategoryRecordsTableUpdateCompanionBuilder,
          (CategoryRecord, $$CategoryRecordsTableReferences),
          CategoryRecord,
          PrefetchHooks Function({
            bool parentId,
            bool levelTwoCategory,
            bool levelThreeCategory,
            bool draftLevelTwoCategory,
            bool draftLevelThreeCategory,
          })
        > {
  $$CategoryRecordsTableTableManager(
    _$AppDatabase db,
    $CategoryRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<int> entryType = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<int> createdAtMicros = const Value.absent(),
                Value<int> updatedAtMicros = const Value.absent(),
              }) => CategoryRecordsCompanion(
                id: id,
                name: name,
                normalizedName: normalizedName,
                entryType: entryType,
                parentId: parentId,
                createdAtMicros: createdAtMicros,
                updatedAtMicros: updatedAtMicros,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String normalizedName,
                required int entryType,
                Value<int?> parentId = const Value.absent(),
                required int createdAtMicros,
                required int updatedAtMicros,
              }) => CategoryRecordsCompanion.insert(
                id: id,
                name: name,
                normalizedName: normalizedName,
                entryType: entryType,
                parentId: parentId,
                createdAtMicros: createdAtMicros,
                updatedAtMicros: updatedAtMicros,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoryRecordsTable, CategoryRecord>(table),
                  $$CategoryRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                parentId = false,
                levelTwoCategory = false,
                levelThreeCategory = false,
                draftLevelTwoCategory = false,
                draftLevelThreeCategory = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (levelTwoCategory) db.ledgerTransactions,
                    if (levelThreeCategory) db.ledgerTransactions,
                    if (draftLevelTwoCategory) db.transactionDraftRecords,
                    if (draftLevelThreeCategory) db.transactionDraftRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (parentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.parentId,
                            referencedTable: $$CategoryRecordsTableReferences
                                ._parentIdTable(db),
                            referencedColumn: $$CategoryRecordsTableReferences
                                ._parentIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (levelTwoCategory)
                        await $_getPrefetchedData<
                          CategoryRecord,
                          $CategoryRecordsTable,
                          LedgerTransactionRecord
                        >(
                          currentTable: table,
                          referencedTable: $$CategoryRecordsTableReferences
                              ._levelTwoCategoryTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoryRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).levelTwoCategory,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (levelThreeCategory)
                        await $_getPrefetchedData<
                          CategoryRecord,
                          $CategoryRecordsTable,
                          LedgerTransactionRecord
                        >(
                          currentTable: table,
                          referencedTable: $$CategoryRecordsTableReferences
                              ._levelThreeCategoryTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoryRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).levelThreeCategory,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.subcategoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (draftLevelTwoCategory)
                        await $_getPrefetchedData<
                          CategoryRecord,
                          $CategoryRecordsTable,
                          TransactionDraftRecord
                        >(
                          currentTable: table,
                          referencedTable: $$CategoryRecordsTableReferences
                              ._draftLevelTwoCategoryTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoryRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).draftLevelTwoCategory,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (draftLevelThreeCategory)
                        await $_getPrefetchedData<
                          CategoryRecord,
                          $CategoryRecordsTable,
                          TransactionDraftRecord
                        >(
                          currentTable: table,
                          referencedTable: $$CategoryRecordsTableReferences
                              ._draftLevelThreeCategoryTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoryRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).draftLevelThreeCategory,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.subcategoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoryRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryRecordsTable,
      CategoryRecord,
      $$CategoryRecordsTableFilterComposer,
      $$CategoryRecordsTableOrderingComposer,
      $$CategoryRecordsTableAnnotationComposer,
      $$CategoryRecordsTableCreateCompanionBuilder,
      $$CategoryRecordsTableUpdateCompanionBuilder,
      (CategoryRecord, $$CategoryRecordsTableReferences),
      CategoryRecord,
      PrefetchHooks Function({
        bool parentId,
        bool levelTwoCategory,
        bool levelThreeCategory,
        bool draftLevelTwoCategory,
        bool draftLevelThreeCategory,
      })
    >;
typedef $$LedgerTransactionsTableCreateCompanionBuilder =
    LedgerTransactionsCompanion Function({
      Value<int> id,
      required int amountCents,
      required int dateEpochDay,
      required int entryType,
      required int categoryId,
      Value<int?> subcategoryId,
      Value<String?> note,
      required int createdAtMicros,
      required int updatedAtMicros,
    });
typedef $$LedgerTransactionsTableUpdateCompanionBuilder =
    LedgerTransactionsCompanion Function({
      Value<int> id,
      Value<int> amountCents,
      Value<int> dateEpochDay,
      Value<int> entryType,
      Value<int> categoryId,
      Value<int?> subcategoryId,
      Value<String?> note,
      Value<int> createdAtMicros,
      Value<int> updatedAtMicros,
    });

final class $$LedgerTransactionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LedgerTransactionsTable,
          LedgerTransactionRecord
        > {
  $$LedgerTransactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoryRecordsTable _categoryIdTable(_$AppDatabase db) => db
      .categoryRecords
      .createAlias('ledger_transactions__category_id__categories__id');

  $$CategoryRecordsTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoryRecordsTableTableManager(
      $_db,
      $_db.categoryRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoryRecordsTable _subcategoryIdTable(_$AppDatabase db) => db
      .categoryRecords
      .createAlias('ledger_transactions__subcategory_id__categories__id');

  $$CategoryRecordsTableProcessedTableManager? get subcategoryId {
    final $_column = $_itemColumn<int>('subcategory_id');
    if ($_column == null) return null;
    final manager = $$CategoryRecordsTableTableManager(
      $_db,
      $_db.categoryRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subcategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LedgerTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerTransactionsTable> {
  $$LedgerTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateEpochDay => $composableBuilder(
    column: $table.dateEpochDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMicros => $composableBuilder(
    column: $table.createdAtMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMicros => $composableBuilder(
    column: $table.updatedAtMicros,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoryRecordsTableFilterComposer get categoryId {
    final $$CategoryRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categoryRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRecordsTableFilterComposer(
            $db: $db,
            $table: $db.categoryRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoryRecordsTableFilterComposer get subcategoryId {
    final $$CategoryRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoryId,
      referencedTable: $db.categoryRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRecordsTableFilterComposer(
            $db: $db,
            $table: $db.categoryRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LedgerTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerTransactionsTable> {
  $$LedgerTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateEpochDay => $composableBuilder(
    column: $table.dateEpochDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMicros => $composableBuilder(
    column: $table.createdAtMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMicros => $composableBuilder(
    column: $table.updatedAtMicros,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoryRecordsTableOrderingComposer get categoryId {
    final $$CategoryRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categoryRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.categoryRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoryRecordsTableOrderingComposer get subcategoryId {
    final $$CategoryRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoryId,
      referencedTable: $db.categoryRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.categoryRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LedgerTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerTransactionsTable> {
  $$LedgerTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dateEpochDay => $composableBuilder(
    column: $table.dateEpochDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAtMicros => $composableBuilder(
    column: $table.createdAtMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMicros => $composableBuilder(
    column: $table.updatedAtMicros,
    builder: (column) => column,
  );

  $$CategoryRecordsTableAnnotationComposer get categoryId {
    final $$CategoryRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categoryRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.categoryRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoryRecordsTableAnnotationComposer get subcategoryId {
    final $$CategoryRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoryId,
      referencedTable: $db.categoryRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.categoryRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LedgerTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LedgerTransactionsTable,
          LedgerTransactionRecord,
          $$LedgerTransactionsTableFilterComposer,
          $$LedgerTransactionsTableOrderingComposer,
          $$LedgerTransactionsTableAnnotationComposer,
          $$LedgerTransactionsTableCreateCompanionBuilder,
          $$LedgerTransactionsTableUpdateCompanionBuilder,
          (LedgerTransactionRecord, $$LedgerTransactionsTableReferences),
          LedgerTransactionRecord,
          PrefetchHooks Function({bool categoryId, bool subcategoryId})
        > {
  $$LedgerTransactionsTableTableManager(
    _$AppDatabase db,
    $LedgerTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<int> dateEpochDay = const Value.absent(),
                Value<int> entryType = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int?> subcategoryId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAtMicros = const Value.absent(),
                Value<int> updatedAtMicros = const Value.absent(),
              }) => LedgerTransactionsCompanion(
                id: id,
                amountCents: amountCents,
                dateEpochDay: dateEpochDay,
                entryType: entryType,
                categoryId: categoryId,
                subcategoryId: subcategoryId,
                note: note,
                createdAtMicros: createdAtMicros,
                updatedAtMicros: updatedAtMicros,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amountCents,
                required int dateEpochDay,
                required int entryType,
                required int categoryId,
                Value<int?> subcategoryId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required int createdAtMicros,
                required int updatedAtMicros,
              }) => LedgerTransactionsCompanion.insert(
                id: id,
                amountCents: amountCents,
                dateEpochDay: dateEpochDay,
                entryType: entryType,
                categoryId: categoryId,
                subcategoryId: subcategoryId,
                note: note,
                createdAtMicros: createdAtMicros,
                updatedAtMicros: updatedAtMicros,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $LedgerTransactionsTable,
                    LedgerTransactionRecord
                  >(table),
                  $$LedgerTransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false, subcategoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryId,
                        referencedTable: $$LedgerTransactionsTableReferences
                            ._categoryIdTable(db),
                        referencedColumn: $$LedgerTransactionsTableReferences
                            ._categoryIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (subcategoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.subcategoryId,
                        referencedTable: $$LedgerTransactionsTableReferences
                            ._subcategoryIdTable(db),
                        referencedColumn: $$LedgerTransactionsTableReferences
                            ._subcategoryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LedgerTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LedgerTransactionsTable,
      LedgerTransactionRecord,
      $$LedgerTransactionsTableFilterComposer,
      $$LedgerTransactionsTableOrderingComposer,
      $$LedgerTransactionsTableAnnotationComposer,
      $$LedgerTransactionsTableCreateCompanionBuilder,
      $$LedgerTransactionsTableUpdateCompanionBuilder,
      (LedgerTransactionRecord, $$LedgerTransactionsTableReferences),
      LedgerTransactionRecord,
      PrefetchHooks Function({bool categoryId, bool subcategoryId})
    >;
typedef $$TransactionDraftRecordsTableCreateCompanionBuilder =
    TransactionDraftRecordsCompanion Function({
      Value<int> id,
      required String amountText,
      required int entryType,
      Value<int?> categoryId,
      Value<int?> subcategoryId,
      required String note,
      required int updatedAtMicros,
    });
typedef $$TransactionDraftRecordsTableUpdateCompanionBuilder =
    TransactionDraftRecordsCompanion Function({
      Value<int> id,
      Value<String> amountText,
      Value<int> entryType,
      Value<int?> categoryId,
      Value<int?> subcategoryId,
      Value<String> note,
      Value<int> updatedAtMicros,
    });

final class $$TransactionDraftRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TransactionDraftRecordsTable,
          TransactionDraftRecord
        > {
  $$TransactionDraftRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoryRecordsTable _categoryIdTable(_$AppDatabase db) => db
      .categoryRecords
      .createAlias('transaction_draft_records__category_id__categories__id');

  $$CategoryRecordsTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoryRecordsTableTableManager(
      $_db,
      $_db.categoryRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoryRecordsTable _subcategoryIdTable(_$AppDatabase db) => db
      .categoryRecords
      .createAlias('transaction_draft_records__subcategory_id__categories__id');

  $$CategoryRecordsTableProcessedTableManager? get subcategoryId {
    final $_column = $_itemColumn<int>('subcategory_id');
    if ($_column == null) return null;
    final manager = $$CategoryRecordsTableTableManager(
      $_db,
      $_db.categoryRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subcategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionDraftRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionDraftRecordsTable> {
  $$TransactionDraftRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amountText => $composableBuilder(
    column: $table.amountText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMicros => $composableBuilder(
    column: $table.updatedAtMicros,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoryRecordsTableFilterComposer get categoryId {
    final $$CategoryRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categoryRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRecordsTableFilterComposer(
            $db: $db,
            $table: $db.categoryRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoryRecordsTableFilterComposer get subcategoryId {
    final $$CategoryRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoryId,
      referencedTable: $db.categoryRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRecordsTableFilterComposer(
            $db: $db,
            $table: $db.categoryRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionDraftRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionDraftRecordsTable> {
  $$TransactionDraftRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amountText => $composableBuilder(
    column: $table.amountText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMicros => $composableBuilder(
    column: $table.updatedAtMicros,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoryRecordsTableOrderingComposer get categoryId {
    final $$CategoryRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categoryRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.categoryRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoryRecordsTableOrderingComposer get subcategoryId {
    final $$CategoryRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoryId,
      referencedTable: $db.categoryRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.categoryRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionDraftRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionDraftRecordsTable> {
  $$TransactionDraftRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get amountText => $composableBuilder(
    column: $table.amountText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMicros => $composableBuilder(
    column: $table.updatedAtMicros,
    builder: (column) => column,
  );

  $$CategoryRecordsTableAnnotationComposer get categoryId {
    final $$CategoryRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categoryRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.categoryRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoryRecordsTableAnnotationComposer get subcategoryId {
    final $$CategoryRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoryId,
      referencedTable: $db.categoryRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.categoryRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionDraftRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionDraftRecordsTable,
          TransactionDraftRecord,
          $$TransactionDraftRecordsTableFilterComposer,
          $$TransactionDraftRecordsTableOrderingComposer,
          $$TransactionDraftRecordsTableAnnotationComposer,
          $$TransactionDraftRecordsTableCreateCompanionBuilder,
          $$TransactionDraftRecordsTableUpdateCompanionBuilder,
          (TransactionDraftRecord, $$TransactionDraftRecordsTableReferences),
          TransactionDraftRecord,
          PrefetchHooks Function({bool categoryId, bool subcategoryId})
        > {
  $$TransactionDraftRecordsTableTableManager(
    _$AppDatabase db,
    $TransactionDraftRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionDraftRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TransactionDraftRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TransactionDraftRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> amountText = const Value.absent(),
                Value<int> entryType = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int?> subcategoryId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> updatedAtMicros = const Value.absent(),
              }) => TransactionDraftRecordsCompanion(
                id: id,
                amountText: amountText,
                entryType: entryType,
                categoryId: categoryId,
                subcategoryId: subcategoryId,
                note: note,
                updatedAtMicros: updatedAtMicros,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String amountText,
                required int entryType,
                Value<int?> categoryId = const Value.absent(),
                Value<int?> subcategoryId = const Value.absent(),
                required String note,
                required int updatedAtMicros,
              }) => TransactionDraftRecordsCompanion.insert(
                id: id,
                amountText: amountText,
                entryType: entryType,
                categoryId: categoryId,
                subcategoryId: subcategoryId,
                note: note,
                updatedAtMicros: updatedAtMicros,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $TransactionDraftRecordsTable,
                    TransactionDraftRecord
                  >(table),
                  $$TransactionDraftRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false, subcategoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryId,
                        referencedTable:
                            $$TransactionDraftRecordsTableReferences
                                ._categoryIdTable(db),
                        referencedColumn:
                            $$TransactionDraftRecordsTableReferences
                                ._categoryIdTable(db)
                                .id,
                      ) as T;
                    }
                    if (subcategoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.subcategoryId,
                        referencedTable:
                            $$TransactionDraftRecordsTableReferences
                                ._subcategoryIdTable(db),
                        referencedColumn:
                            $$TransactionDraftRecordsTableReferences
                                ._subcategoryIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TransactionDraftRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionDraftRecordsTable,
      TransactionDraftRecord,
      $$TransactionDraftRecordsTableFilterComposer,
      $$TransactionDraftRecordsTableOrderingComposer,
      $$TransactionDraftRecordsTableAnnotationComposer,
      $$TransactionDraftRecordsTableCreateCompanionBuilder,
      $$TransactionDraftRecordsTableUpdateCompanionBuilder,
      (TransactionDraftRecord, $$TransactionDraftRecordsTableReferences),
      TransactionDraftRecord,
      PrefetchHooks Function({bool categoryId, bool subcategoryId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoryRecordsTableTableManager get categoryRecords =>
      $$CategoryRecordsTableTableManager(_db, _db.categoryRecords);
  $$LedgerTransactionsTableTableManager get ledgerTransactions =>
      $$LedgerTransactionsTableTableManager(_db, _db.ledgerTransactions);
  $$TransactionDraftRecordsTableTableManager get transactionDraftRecords =>
      $$TransactionDraftRecordsTableTableManager(
        _db,
        _db.transactionDraftRecords,
      );
}
