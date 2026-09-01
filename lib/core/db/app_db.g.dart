// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $TaskListsTableTable extends TaskListsTable
    with TableInfo<$TaskListsTableTable, TaskListsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskListsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta =
      const VerificationMeta('localId');
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
      'local_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('anonymous'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
      'color_hex', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#CCCCCC'));
  static const VerificationMeta _isHiddenMeta =
      const VerificationMeta('isHidden');
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
      'is_hidden', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_hidden" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
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
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        localId,
        serverId,
        accountId,
        name,
        colorHex,
        isHidden,
        isDirty,
        isDeleted,
        version,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_lists_table';
  @override
  VerificationContext validateIntegrity(Insertable<TaskListsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(_localIdMeta,
          localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    }
    if (data.containsKey('is_hidden')) {
      context.handle(_isHiddenMeta,
          isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  TaskListsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskListsTableData(
      localId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex'])!,
      isHidden: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_hidden'])!,
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $TaskListsTableTable createAlias(String alias) {
    return $TaskListsTableTable(attachedDatabase, alias);
  }
}

class TaskListsTableData extends DataClass
    implements Insertable<TaskListsTableData> {
  final int localId;
  final String? serverId;
  final String accountId;
  final String name;
  final String colorHex;
  final bool isHidden;
  final bool isDirty;
  final bool isDeleted;
  final int version;
  final DateTime? createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const TaskListsTableData(
      {required this.localId,
      this.serverId,
      required this.accountId,
      required this.name,
      required this.colorHex,
      required this.isHidden,
      required this.isDirty,
      required this.isDeleted,
      required this.version,
      this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['account_id'] = Variable<String>(accountId);
    map['name'] = Variable<String>(name);
    map['color_hex'] = Variable<String>(colorHex);
    map['is_hidden'] = Variable<bool>(isHidden);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TaskListsTableCompanion toCompanion(bool nullToAbsent) {
    return TaskListsTableCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      accountId: Value(accountId),
      name: Value(name),
      colorHex: Value(colorHex),
      isHidden: Value(isHidden),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      version: Value(version),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TaskListsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskListsTableData(
      localId: serializer.fromJson<int>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      version: serializer.fromJson<int>(json['version']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'accountId': serializer.toJson<String>(accountId),
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<String>(colorHex),
      'isHidden': serializer.toJson<bool>(isHidden),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TaskListsTableData copyWith(
          {int? localId,
          Value<String?> serverId = const Value.absent(),
          String? accountId,
          String? name,
          String? colorHex,
          bool? isHidden,
          bool? isDirty,
          bool? isDeleted,
          int? version,
          Value<DateTime?> createdAt = const Value.absent(),
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      TaskListsTableData(
        localId: localId ?? this.localId,
        serverId: serverId.present ? serverId.value : this.serverId,
        accountId: accountId ?? this.accountId,
        name: name ?? this.name,
        colorHex: colorHex ?? this.colorHex,
        isHidden: isHidden ?? this.isHidden,
        isDirty: isDirty ?? this.isDirty,
        isDeleted: isDeleted ?? this.isDeleted,
        version: version ?? this.version,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  TaskListsTableData copyWithCompanion(TaskListsTableCompanion data) {
    return TaskListsTableData(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      name: data.name.present ? data.name.value : this.name,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      version: data.version.present ? data.version.value : this.version,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskListsTableData(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('accountId: $accountId, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('isHidden: $isHidden, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(localId, serverId, accountId, name, colorHex,
      isHidden, isDirty, isDeleted, version, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskListsTableData &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.accountId == this.accountId &&
          other.name == this.name &&
          other.colorHex == this.colorHex &&
          other.isHidden == this.isHidden &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TaskListsTableCompanion extends UpdateCompanion<TaskListsTableData> {
  final Value<int> localId;
  final Value<String?> serverId;
  final Value<String> accountId;
  final Value<String> name;
  final Value<String> colorHex;
  final Value<bool> isHidden;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<int> version;
  final Value<DateTime?> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const TaskListsTableCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  TaskListsTableCompanion.insert({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.accountId = const Value.absent(),
    required String name,
    this.colorHex = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<TaskListsTableData> custom({
    Expression<int>? localId,
    Expression<String>? serverId,
    Expression<String>? accountId,
    Expression<String>? name,
    Expression<String>? colorHex,
    Expression<bool>? isHidden,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<int>? version,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (accountId != null) 'account_id': accountId,
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
      if (isHidden != null) 'is_hidden': isHidden,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  TaskListsTableCompanion copyWith(
      {Value<int>? localId,
      Value<String?>? serverId,
      Value<String>? accountId,
      Value<String>? name,
      Value<String>? colorHex,
      Value<bool>? isHidden,
      Value<bool>? isDirty,
      Value<bool>? isDeleted,
      Value<int>? version,
      Value<DateTime?>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt}) {
    return TaskListsTableCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      isHidden: isHidden ?? this.isHidden,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskListsTableCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('accountId: $accountId, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('isHidden: $isHidden, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $TasksTableTable extends TasksTable
    with TableInfo<$TasksTableTable, TasksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta =
      const VerificationMeta('localId');
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
      'local_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('anonymous'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateYmdMeta =
      const VerificationMeta('dateYmd');
  @override
  late final GeneratedColumn<String> dateYmd = GeneratedColumn<String>(
      'date_ymd', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notificationTimeMeta =
      const VerificationMeta('notificationTime');
  @override
  late final GeneratedColumn<String> notificationTime = GeneratedColumn<String>(
      'notification_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _trashedMeta =
      const VerificationMeta('trashed');
  @override
  late final GeneratedColumn<bool> trashed = GeneratedColumn<bool>(
      'trashed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("trashed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _urgencyMeta =
      const VerificationMeta('urgency');
  @override
  late final GeneratedColumn<String> urgency = GeneratedColumn<String>(
      'urgency', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _taskListLocalIdMeta =
      const VerificationMeta('taskListLocalId');
  @override
  late final GeneratedColumn<int> taskListLocalId = GeneratedColumn<int>(
      'task_list_local_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _taskListServerIdMeta =
      const VerificationMeta('taskListServerId');
  @override
  late final GeneratedColumn<String> taskListServerId = GeneratedColumn<String>(
      'task_list_server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parentLocalIdMeta =
      const VerificationMeta('parentLocalId');
  @override
  late final GeneratedColumn<int> parentLocalId = GeneratedColumn<int>(
      'parent_local_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _parentServerIdMeta =
      const VerificationMeta('parentServerId');
  @override
  late final GeneratedColumn<String> parentServerId = GeneratedColumn<String>(
      'parent_server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
      'hash', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSharedMeta =
      const VerificationMeta('isShared');
  @override
  late final GeneratedColumn<bool> isShared = GeneratedColumn<bool>(
      'is_shared', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_shared" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _collaborationRoleMeta =
      const VerificationMeta('collaborationRole');
  @override
  late final GeneratedColumn<String> collaborationRole =
      GeneratedColumn<String>('collaboration_role', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _collaboratorsJsonMeta =
      const VerificationMeta('collaboratorsJson');
  @override
  late final GeneratedColumn<String> collaboratorsJson =
      GeneratedColumn<String>('collaborators_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
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
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        localId,
        serverId,
        accountId,
        name,
        dateYmd,
        note,
        notificationTime,
        isCompleted,
        trashed,
        urgency,
        position,
        taskListLocalId,
        taskListServerId,
        parentLocalId,
        parentServerId,
        hash,
        isShared,
        collaborationRole,
        collaboratorsJson,
        version,
        isDirty,
        isDeleted,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks_table';
  @override
  VerificationContext validateIntegrity(Insertable<TasksTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(_localIdMeta,
          localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('date_ymd')) {
      context.handle(_dateYmdMeta,
          dateYmd.isAcceptableOrUnknown(data['date_ymd']!, _dateYmdMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('notification_time')) {
      context.handle(
          _notificationTimeMeta,
          notificationTime.isAcceptableOrUnknown(
              data['notification_time']!, _notificationTimeMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('trashed')) {
      context.handle(_trashedMeta,
          trashed.isAcceptableOrUnknown(data['trashed']!, _trashedMeta));
    }
    if (data.containsKey('urgency')) {
      context.handle(_urgencyMeta,
          urgency.isAcceptableOrUnknown(data['urgency']!, _urgencyMeta));
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    if (data.containsKey('task_list_local_id')) {
      context.handle(
          _taskListLocalIdMeta,
          taskListLocalId.isAcceptableOrUnknown(
              data['task_list_local_id']!, _taskListLocalIdMeta));
    }
    if (data.containsKey('task_list_server_id')) {
      context.handle(
          _taskListServerIdMeta,
          taskListServerId.isAcceptableOrUnknown(
              data['task_list_server_id']!, _taskListServerIdMeta));
    }
    if (data.containsKey('parent_local_id')) {
      context.handle(
          _parentLocalIdMeta,
          parentLocalId.isAcceptableOrUnknown(
              data['parent_local_id']!, _parentLocalIdMeta));
    }
    if (data.containsKey('parent_server_id')) {
      context.handle(
          _parentServerIdMeta,
          parentServerId.isAcceptableOrUnknown(
              data['parent_server_id']!, _parentServerIdMeta));
    }
    if (data.containsKey('hash')) {
      context.handle(
          _hashMeta, hash.isAcceptableOrUnknown(data['hash']!, _hashMeta));
    }
    if (data.containsKey('is_shared')) {
      context.handle(_isSharedMeta,
          isShared.isAcceptableOrUnknown(data['is_shared']!, _isSharedMeta));
    }
    if (data.containsKey('collaboration_role')) {
      context.handle(
          _collaborationRoleMeta,
          collaborationRole.isAcceptableOrUnknown(
              data['collaboration_role']!, _collaborationRoleMeta));
    }
    if (data.containsKey('collaborators_json')) {
      context.handle(
          _collaboratorsJsonMeta,
          collaboratorsJson.isAcceptableOrUnknown(
              data['collaborators_json']!, _collaboratorsJsonMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  TasksTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TasksTableData(
      localId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      dateYmd: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_ymd']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      notificationTime: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}notification_time']),
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      trashed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}trashed'])!,
      urgency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}urgency']),
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position']),
      taskListLocalId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}task_list_local_id']),
      taskListServerId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}task_list_server_id']),
      parentLocalId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parent_local_id']),
      parentServerId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}parent_server_id']),
      hash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hash']),
      isShared: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_shared'])!,
      collaborationRole: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}collaboration_role']),
      collaboratorsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}collaborators_json']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $TasksTableTable createAlias(String alias) {
    return $TasksTableTable(attachedDatabase, alias);
  }
}

class TasksTableData extends DataClass implements Insertable<TasksTableData> {
  final int localId;
  final String? serverId;
  final String accountId;
  final String name;
  final String? dateYmd;
  final String? note;
  final String? notificationTime;
  final bool isCompleted;
  final bool trashed;
  final String? urgency;
  final int? position;
  final int? taskListLocalId;
  final String? taskListServerId;
  final int? parentLocalId;
  final String? parentServerId;
  final String? hash;
  final bool isShared;
  final String? collaborationRole;
  final String? collaboratorsJson;
  final int version;
  final bool isDirty;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const TasksTableData(
      {required this.localId,
      this.serverId,
      required this.accountId,
      required this.name,
      this.dateYmd,
      this.note,
      this.notificationTime,
      required this.isCompleted,
      required this.trashed,
      this.urgency,
      this.position,
      this.taskListLocalId,
      this.taskListServerId,
      this.parentLocalId,
      this.parentServerId,
      this.hash,
      required this.isShared,
      this.collaborationRole,
      this.collaboratorsJson,
      required this.version,
      required this.isDirty,
      required this.isDeleted,
      this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['account_id'] = Variable<String>(accountId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || dateYmd != null) {
      map['date_ymd'] = Variable<String>(dateYmd);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || notificationTime != null) {
      map['notification_time'] = Variable<String>(notificationTime);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['trashed'] = Variable<bool>(trashed);
    if (!nullToAbsent || urgency != null) {
      map['urgency'] = Variable<String>(urgency);
    }
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<int>(position);
    }
    if (!nullToAbsent || taskListLocalId != null) {
      map['task_list_local_id'] = Variable<int>(taskListLocalId);
    }
    if (!nullToAbsent || taskListServerId != null) {
      map['task_list_server_id'] = Variable<String>(taskListServerId);
    }
    if (!nullToAbsent || parentLocalId != null) {
      map['parent_local_id'] = Variable<int>(parentLocalId);
    }
    if (!nullToAbsent || parentServerId != null) {
      map['parent_server_id'] = Variable<String>(parentServerId);
    }
    if (!nullToAbsent || hash != null) {
      map['hash'] = Variable<String>(hash);
    }
    map['is_shared'] = Variable<bool>(isShared);
    if (!nullToAbsent || collaborationRole != null) {
      map['collaboration_role'] = Variable<String>(collaborationRole);
    }
    if (!nullToAbsent || collaboratorsJson != null) {
      map['collaborators_json'] = Variable<String>(collaboratorsJson);
    }
    map['version'] = Variable<int>(version);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TasksTableCompanion toCompanion(bool nullToAbsent) {
    return TasksTableCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      accountId: Value(accountId),
      name: Value(name),
      dateYmd: dateYmd == null && nullToAbsent
          ? const Value.absent()
          : Value(dateYmd),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      notificationTime: notificationTime == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationTime),
      isCompleted: Value(isCompleted),
      trashed: Value(trashed),
      urgency: urgency == null && nullToAbsent
          ? const Value.absent()
          : Value(urgency),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
      taskListLocalId: taskListLocalId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskListLocalId),
      taskListServerId: taskListServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskListServerId),
      parentLocalId: parentLocalId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentLocalId),
      parentServerId: parentServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentServerId),
      hash: hash == null && nullToAbsent ? const Value.absent() : Value(hash),
      isShared: Value(isShared),
      collaborationRole: collaborationRole == null && nullToAbsent
          ? const Value.absent()
          : Value(collaborationRole),
      collaboratorsJson: collaboratorsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(collaboratorsJson),
      version: Value(version),
      isDirty: Value(isDirty),
      isDeleted: Value(isDeleted),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TasksTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TasksTableData(
      localId: serializer.fromJson<int>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      name: serializer.fromJson<String>(json['name']),
      dateYmd: serializer.fromJson<String?>(json['dateYmd']),
      note: serializer.fromJson<String?>(json['note']),
      notificationTime: serializer.fromJson<String?>(json['notificationTime']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      trashed: serializer.fromJson<bool>(json['trashed']),
      urgency: serializer.fromJson<String?>(json['urgency']),
      position: serializer.fromJson<int?>(json['position']),
      taskListLocalId: serializer.fromJson<int?>(json['taskListLocalId']),
      taskListServerId: serializer.fromJson<String?>(json['taskListServerId']),
      parentLocalId: serializer.fromJson<int?>(json['parentLocalId']),
      parentServerId: serializer.fromJson<String?>(json['parentServerId']),
      hash: serializer.fromJson<String?>(json['hash']),
      isShared: serializer.fromJson<bool>(json['isShared']),
      collaborationRole:
          serializer.fromJson<String?>(json['collaborationRole']),
      collaboratorsJson:
          serializer.fromJson<String?>(json['collaboratorsJson']),
      version: serializer.fromJson<int>(json['version']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'accountId': serializer.toJson<String>(accountId),
      'name': serializer.toJson<String>(name),
      'dateYmd': serializer.toJson<String?>(dateYmd),
      'note': serializer.toJson<String?>(note),
      'notificationTime': serializer.toJson<String?>(notificationTime),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'trashed': serializer.toJson<bool>(trashed),
      'urgency': serializer.toJson<String?>(urgency),
      'position': serializer.toJson<int?>(position),
      'taskListLocalId': serializer.toJson<int?>(taskListLocalId),
      'taskListServerId': serializer.toJson<String?>(taskListServerId),
      'parentLocalId': serializer.toJson<int?>(parentLocalId),
      'parentServerId': serializer.toJson<String?>(parentServerId),
      'hash': serializer.toJson<String?>(hash),
      'isShared': serializer.toJson<bool>(isShared),
      'collaborationRole': serializer.toJson<String?>(collaborationRole),
      'collaboratorsJson': serializer.toJson<String?>(collaboratorsJson),
      'version': serializer.toJson<int>(version),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TasksTableData copyWith(
          {int? localId,
          Value<String?> serverId = const Value.absent(),
          String? accountId,
          String? name,
          Value<String?> dateYmd = const Value.absent(),
          Value<String?> note = const Value.absent(),
          Value<String?> notificationTime = const Value.absent(),
          bool? isCompleted,
          bool? trashed,
          Value<String?> urgency = const Value.absent(),
          Value<int?> position = const Value.absent(),
          Value<int?> taskListLocalId = const Value.absent(),
          Value<String?> taskListServerId = const Value.absent(),
          Value<int?> parentLocalId = const Value.absent(),
          Value<String?> parentServerId = const Value.absent(),
          Value<String?> hash = const Value.absent(),
          bool? isShared,
          Value<String?> collaborationRole = const Value.absent(),
          Value<String?> collaboratorsJson = const Value.absent(),
          int? version,
          bool? isDirty,
          bool? isDeleted,
          Value<DateTime?> createdAt = const Value.absent(),
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      TasksTableData(
        localId: localId ?? this.localId,
        serverId: serverId.present ? serverId.value : this.serverId,
        accountId: accountId ?? this.accountId,
        name: name ?? this.name,
        dateYmd: dateYmd.present ? dateYmd.value : this.dateYmd,
        note: note.present ? note.value : this.note,
        notificationTime: notificationTime.present
            ? notificationTime.value
            : this.notificationTime,
        isCompleted: isCompleted ?? this.isCompleted,
        trashed: trashed ?? this.trashed,
        urgency: urgency.present ? urgency.value : this.urgency,
        position: position.present ? position.value : this.position,
        taskListLocalId: taskListLocalId.present
            ? taskListLocalId.value
            : this.taskListLocalId,
        taskListServerId: taskListServerId.present
            ? taskListServerId.value
            : this.taskListServerId,
        parentLocalId:
            parentLocalId.present ? parentLocalId.value : this.parentLocalId,
        parentServerId:
            parentServerId.present ? parentServerId.value : this.parentServerId,
        hash: hash.present ? hash.value : this.hash,
        isShared: isShared ?? this.isShared,
        collaborationRole: collaborationRole.present
            ? collaborationRole.value
            : this.collaborationRole,
        collaboratorsJson: collaboratorsJson.present
            ? collaboratorsJson.value
            : this.collaboratorsJson,
        version: version ?? this.version,
        isDirty: isDirty ?? this.isDirty,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  TasksTableData copyWithCompanion(TasksTableCompanion data) {
    return TasksTableData(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      name: data.name.present ? data.name.value : this.name,
      dateYmd: data.dateYmd.present ? data.dateYmd.value : this.dateYmd,
      note: data.note.present ? data.note.value : this.note,
      notificationTime: data.notificationTime.present
          ? data.notificationTime.value
          : this.notificationTime,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      trashed: data.trashed.present ? data.trashed.value : this.trashed,
      urgency: data.urgency.present ? data.urgency.value : this.urgency,
      position: data.position.present ? data.position.value : this.position,
      taskListLocalId: data.taskListLocalId.present
          ? data.taskListLocalId.value
          : this.taskListLocalId,
      taskListServerId: data.taskListServerId.present
          ? data.taskListServerId.value
          : this.taskListServerId,
      parentLocalId: data.parentLocalId.present
          ? data.parentLocalId.value
          : this.parentLocalId,
      parentServerId: data.parentServerId.present
          ? data.parentServerId.value
          : this.parentServerId,
      hash: data.hash.present ? data.hash.value : this.hash,
      isShared: data.isShared.present ? data.isShared.value : this.isShared,
      collaborationRole: data.collaborationRole.present
          ? data.collaborationRole.value
          : this.collaborationRole,
      collaboratorsJson: data.collaboratorsJson.present
          ? data.collaboratorsJson.value
          : this.collaboratorsJson,
      version: data.version.present ? data.version.value : this.version,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TasksTableData(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('accountId: $accountId, ')
          ..write('name: $name, ')
          ..write('dateYmd: $dateYmd, ')
          ..write('note: $note, ')
          ..write('notificationTime: $notificationTime, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('trashed: $trashed, ')
          ..write('urgency: $urgency, ')
          ..write('position: $position, ')
          ..write('taskListLocalId: $taskListLocalId, ')
          ..write('taskListServerId: $taskListServerId, ')
          ..write('parentLocalId: $parentLocalId, ')
          ..write('parentServerId: $parentServerId, ')
          ..write('hash: $hash, ')
          ..write('isShared: $isShared, ')
          ..write('collaborationRole: $collaborationRole, ')
          ..write('collaboratorsJson: $collaboratorsJson, ')
          ..write('version: $version, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        localId,
        serverId,
        accountId,
        name,
        dateYmd,
        note,
        notificationTime,
        isCompleted,
        trashed,
        urgency,
        position,
        taskListLocalId,
        taskListServerId,
        parentLocalId,
        parentServerId,
        hash,
        isShared,
        collaborationRole,
        collaboratorsJson,
        version,
        isDirty,
        isDeleted,
        createdAt,
        updatedAt,
        deletedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TasksTableData &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.accountId == this.accountId &&
          other.name == this.name &&
          other.dateYmd == this.dateYmd &&
          other.note == this.note &&
          other.notificationTime == this.notificationTime &&
          other.isCompleted == this.isCompleted &&
          other.trashed == this.trashed &&
          other.urgency == this.urgency &&
          other.position == this.position &&
          other.taskListLocalId == this.taskListLocalId &&
          other.taskListServerId == this.taskListServerId &&
          other.parentLocalId == this.parentLocalId &&
          other.parentServerId == this.parentServerId &&
          other.hash == this.hash &&
          other.isShared == this.isShared &&
          other.collaborationRole == this.collaborationRole &&
          other.collaboratorsJson == this.collaboratorsJson &&
          other.version == this.version &&
          other.isDirty == this.isDirty &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TasksTableCompanion extends UpdateCompanion<TasksTableData> {
  final Value<int> localId;
  final Value<String?> serverId;
  final Value<String> accountId;
  final Value<String> name;
  final Value<String?> dateYmd;
  final Value<String?> note;
  final Value<String?> notificationTime;
  final Value<bool> isCompleted;
  final Value<bool> trashed;
  final Value<String?> urgency;
  final Value<int?> position;
  final Value<int?> taskListLocalId;
  final Value<String?> taskListServerId;
  final Value<int?> parentLocalId;
  final Value<String?> parentServerId;
  final Value<String?> hash;
  final Value<bool> isShared;
  final Value<String?> collaborationRole;
  final Value<String?> collaboratorsJson;
  final Value<int> version;
  final Value<bool> isDirty;
  final Value<bool> isDeleted;
  final Value<DateTime?> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const TasksTableCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.name = const Value.absent(),
    this.dateYmd = const Value.absent(),
    this.note = const Value.absent(),
    this.notificationTime = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.trashed = const Value.absent(),
    this.urgency = const Value.absent(),
    this.position = const Value.absent(),
    this.taskListLocalId = const Value.absent(),
    this.taskListServerId = const Value.absent(),
    this.parentLocalId = const Value.absent(),
    this.parentServerId = const Value.absent(),
    this.hash = const Value.absent(),
    this.isShared = const Value.absent(),
    this.collaborationRole = const Value.absent(),
    this.collaboratorsJson = const Value.absent(),
    this.version = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  TasksTableCompanion.insert({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.accountId = const Value.absent(),
    required String name,
    this.dateYmd = const Value.absent(),
    this.note = const Value.absent(),
    this.notificationTime = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.trashed = const Value.absent(),
    this.urgency = const Value.absent(),
    this.position = const Value.absent(),
    this.taskListLocalId = const Value.absent(),
    this.taskListServerId = const Value.absent(),
    this.parentLocalId = const Value.absent(),
    this.parentServerId = const Value.absent(),
    this.hash = const Value.absent(),
    this.isShared = const Value.absent(),
    this.collaborationRole = const Value.absent(),
    this.collaboratorsJson = const Value.absent(),
    this.version = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<TasksTableData> custom({
    Expression<int>? localId,
    Expression<String>? serverId,
    Expression<String>? accountId,
    Expression<String>? name,
    Expression<String>? dateYmd,
    Expression<String>? note,
    Expression<String>? notificationTime,
    Expression<bool>? isCompleted,
    Expression<bool>? trashed,
    Expression<String>? urgency,
    Expression<int>? position,
    Expression<int>? taskListLocalId,
    Expression<String>? taskListServerId,
    Expression<int>? parentLocalId,
    Expression<String>? parentServerId,
    Expression<String>? hash,
    Expression<bool>? isShared,
    Expression<String>? collaborationRole,
    Expression<String>? collaboratorsJson,
    Expression<int>? version,
    Expression<bool>? isDirty,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (accountId != null) 'account_id': accountId,
      if (name != null) 'name': name,
      if (dateYmd != null) 'date_ymd': dateYmd,
      if (note != null) 'note': note,
      if (notificationTime != null) 'notification_time': notificationTime,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (trashed != null) 'trashed': trashed,
      if (urgency != null) 'urgency': urgency,
      if (position != null) 'position': position,
      if (taskListLocalId != null) 'task_list_local_id': taskListLocalId,
      if (taskListServerId != null) 'task_list_server_id': taskListServerId,
      if (parentLocalId != null) 'parent_local_id': parentLocalId,
      if (parentServerId != null) 'parent_server_id': parentServerId,
      if (hash != null) 'hash': hash,
      if (isShared != null) 'is_shared': isShared,
      if (collaborationRole != null) 'collaboration_role': collaborationRole,
      if (collaboratorsJson != null) 'collaborators_json': collaboratorsJson,
      if (version != null) 'version': version,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  TasksTableCompanion copyWith(
      {Value<int>? localId,
      Value<String?>? serverId,
      Value<String>? accountId,
      Value<String>? name,
      Value<String?>? dateYmd,
      Value<String?>? note,
      Value<String?>? notificationTime,
      Value<bool>? isCompleted,
      Value<bool>? trashed,
      Value<String?>? urgency,
      Value<int?>? position,
      Value<int?>? taskListLocalId,
      Value<String?>? taskListServerId,
      Value<int?>? parentLocalId,
      Value<String?>? parentServerId,
      Value<String?>? hash,
      Value<bool>? isShared,
      Value<String?>? collaborationRole,
      Value<String?>? collaboratorsJson,
      Value<int>? version,
      Value<bool>? isDirty,
      Value<bool>? isDeleted,
      Value<DateTime?>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt}) {
    return TasksTableCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      dateYmd: dateYmd ?? this.dateYmd,
      note: note ?? this.note,
      notificationTime: notificationTime ?? this.notificationTime,
      isCompleted: isCompleted ?? this.isCompleted,
      trashed: trashed ?? this.trashed,
      urgency: urgency ?? this.urgency,
      position: position ?? this.position,
      taskListLocalId: taskListLocalId ?? this.taskListLocalId,
      taskListServerId: taskListServerId ?? this.taskListServerId,
      parentLocalId: parentLocalId ?? this.parentLocalId,
      parentServerId: parentServerId ?? this.parentServerId,
      hash: hash ?? this.hash,
      isShared: isShared ?? this.isShared,
      collaborationRole: collaborationRole ?? this.collaborationRole,
      collaboratorsJson: collaboratorsJson ?? this.collaboratorsJson,
      version: version ?? this.version,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dateYmd.present) {
      map['date_ymd'] = Variable<String>(dateYmd.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (notificationTime.present) {
      map['notification_time'] = Variable<String>(notificationTime.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (trashed.present) {
      map['trashed'] = Variable<bool>(trashed.value);
    }
    if (urgency.present) {
      map['urgency'] = Variable<String>(urgency.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (taskListLocalId.present) {
      map['task_list_local_id'] = Variable<int>(taskListLocalId.value);
    }
    if (taskListServerId.present) {
      map['task_list_server_id'] = Variable<String>(taskListServerId.value);
    }
    if (parentLocalId.present) {
      map['parent_local_id'] = Variable<int>(parentLocalId.value);
    }
    if (parentServerId.present) {
      map['parent_server_id'] = Variable<String>(parentServerId.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (isShared.present) {
      map['is_shared'] = Variable<bool>(isShared.value);
    }
    if (collaborationRole.present) {
      map['collaboration_role'] = Variable<String>(collaborationRole.value);
    }
    if (collaboratorsJson.present) {
      map['collaborators_json'] = Variable<String>(collaboratorsJson.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksTableCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('accountId: $accountId, ')
          ..write('name: $name, ')
          ..write('dateYmd: $dateYmd, ')
          ..write('note: $note, ')
          ..write('notificationTime: $notificationTime, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('trashed: $trashed, ')
          ..write('urgency: $urgency, ')
          ..write('position: $position, ')
          ..write('taskListLocalId: $taskListLocalId, ')
          ..write('taskListServerId: $taskListServerId, ')
          ..write('parentLocalId: $parentLocalId, ')
          ..write('parentServerId: $parentServerId, ')
          ..write('hash: $hash, ')
          ..write('isShared: $isShared, ')
          ..write('collaborationRole: $collaborationRole, ')
          ..write('collaboratorsJson: $collaboratorsJson, ')
          ..write('version: $version, ')
          ..write('isDirty: $isDirty, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $CollaboratorsTableTable extends CollaboratorsTable
    with TableInfo<$CollaboratorsTableTable, CollaboratorsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollaboratorsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [taskId, userId, name, role, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collaborators_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<CollaboratorsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId, userId};
  @override
  CollaboratorsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollaboratorsTableData(
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CollaboratorsTableTable createAlias(String alias) {
    return $CollaboratorsTableTable(attachedDatabase, alias);
  }
}

class CollaboratorsTableData extends DataClass
    implements Insertable<CollaboratorsTableData> {
  final String taskId;
  final String userId;
  final String? name;
  final String role;
  final DateTime updatedAt;
  const CollaboratorsTableData(
      {required this.taskId,
      required this.userId,
      this.name,
      required this.role,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<String>(taskId);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['role'] = Variable<String>(role);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CollaboratorsTableCompanion toCompanion(bool nullToAbsent) {
    return CollaboratorsTableCompanion(
      taskId: Value(taskId),
      userId: Value(userId),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      role: Value(role),
      updatedAt: Value(updatedAt),
    );
  }

  factory CollaboratorsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollaboratorsTableData(
      taskId: serializer.fromJson<String>(json['taskId']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String?>(json['name']),
      role: serializer.fromJson<String>(json['role']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<String>(taskId),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String?>(name),
      'role': serializer.toJson<String>(role),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CollaboratorsTableData copyWith(
          {String? taskId,
          String? userId,
          Value<String?> name = const Value.absent(),
          String? role,
          DateTime? updatedAt}) =>
      CollaboratorsTableData(
        taskId: taskId ?? this.taskId,
        userId: userId ?? this.userId,
        name: name.present ? name.value : this.name,
        role: role ?? this.role,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CollaboratorsTableData copyWithCompanion(CollaboratorsTableCompanion data) {
    return CollaboratorsTableData(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollaboratorsTableData(')
          ..write('taskId: $taskId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(taskId, userId, name, role, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollaboratorsTableData &&
          other.taskId == this.taskId &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.role == this.role &&
          other.updatedAt == this.updatedAt);
}

class CollaboratorsTableCompanion
    extends UpdateCompanion<CollaboratorsTableData> {
  final Value<String> taskId;
  final Value<String> userId;
  final Value<String?> name;
  final Value<String> role;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CollaboratorsTableCompanion({
    this.taskId = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollaboratorsTableCompanion.insert({
    required String taskId,
    required String userId,
    this.name = const Value.absent(),
    required String role,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : taskId = Value(taskId),
        userId = Value(userId),
        role = Value(role);
  static Insertable<CollaboratorsTableData> custom({
    Expression<String>? taskId,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? role,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollaboratorsTableCompanion copyWith(
      {Value<String>? taskId,
      Value<String>? userId,
      Value<String?>? name,
      Value<String>? role,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CollaboratorsTableCompanion(
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      role: role ?? this.role,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollaboratorsTableCompanion(')
          ..write('taskId: $taskId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTableTable extends OutboxTable
    with TableInfo<$OutboxTableTable, OutboxTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _operationIdMeta =
      const VerificationMeta('operationId');
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
      'operation_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('anonymous'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientTimestampMeta =
      const VerificationMeta('clientTimestamp');
  @override
  late final GeneratedColumn<DateTime> clientTimestamp =
      GeneratedColumn<DateTime>('client_timestamp', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nextAttemptAtMeta =
      const VerificationMeta('nextAttemptAt');
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>('next_attempt_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isTerminalMeta =
      const VerificationMeta('isTerminal');
  @override
  late final GeneratedColumn<bool> isTerminal = GeneratedColumn<bool>(
      'is_terminal', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_terminal" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        operationId,
        deviceId,
        accountId,
        type,
        entityId,
        payloadJson,
        clientTimestamp,
        retryCount,
        nextAttemptAt,
        lastError,
        isTerminal,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_table';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('operation_id')) {
      context.handle(
          _operationIdMeta,
          operationId.isAcceptableOrUnknown(
              data['operation_id']!, _operationIdMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('client_timestamp')) {
      context.handle(
          _clientTimestampMeta,
          clientTimestamp.isAcceptableOrUnknown(
              data['client_timestamp']!, _clientTimestampMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
          _nextAttemptAtMeta,
          nextAttemptAt.isAcceptableOrUnknown(
              data['next_attempt_at']!, _nextAttemptAtMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('is_terminal')) {
      context.handle(
          _isTerminalMeta,
          isTerminal.isAcceptableOrUnknown(
              data['is_terminal']!, _isTerminalMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      operationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation_id']),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id']),
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      clientTimestamp: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}client_timestamp'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_attempt_at'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      isTerminal: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_terminal'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OutboxTableTable createAlias(String alias) {
    return $OutboxTableTable(attachedDatabase, alias);
  }
}

class OutboxTableData extends DataClass implements Insertable<OutboxTableData> {
  final int id;
  final String? operationId;
  final String? deviceId;
  final String accountId;
  final String type;
  final String? entityId;
  final String payloadJson;
  final DateTime clientTimestamp;
  final int retryCount;
  final DateTime nextAttemptAt;
  final String? lastError;
  final bool isTerminal;
  final DateTime createdAt;
  const OutboxTableData(
      {required this.id,
      this.operationId,
      this.deviceId,
      required this.accountId,
      required this.type,
      this.entityId,
      required this.payloadJson,
      required this.clientTimestamp,
      required this.retryCount,
      required this.nextAttemptAt,
      this.lastError,
      required this.isTerminal,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || operationId != null) {
      map['operation_id'] = Variable<String>(operationId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['account_id'] = Variable<String>(accountId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    map['payload_json'] = Variable<String>(payloadJson);
    map['client_timestamp'] = Variable<DateTime>(clientTimestamp);
    map['retry_count'] = Variable<int>(retryCount);
    map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['is_terminal'] = Variable<bool>(isTerminal);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxTableCompanion toCompanion(bool nullToAbsent) {
    return OutboxTableCompanion(
      id: Value(id),
      operationId: operationId == null && nullToAbsent
          ? const Value.absent()
          : Value(operationId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      accountId: Value(accountId),
      type: Value(type),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      payloadJson: Value(payloadJson),
      clientTimestamp: Value(clientTimestamp),
      retryCount: Value(retryCount),
      nextAttemptAt: Value(nextAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      isTerminal: Value(isTerminal),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxTableData(
      id: serializer.fromJson<int>(json['id']),
      operationId: serializer.fromJson<String?>(json['operationId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      type: serializer.fromJson<String>(json['type']),
      entityId: serializer.fromJson<String?>(json['entityId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      clientTimestamp: serializer.fromJson<DateTime>(json['clientTimestamp']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      nextAttemptAt: serializer.fromJson<DateTime>(json['nextAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      isTerminal: serializer.fromJson<bool>(json['isTerminal']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'operationId': serializer.toJson<String?>(operationId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'accountId': serializer.toJson<String>(accountId),
      'type': serializer.toJson<String>(type),
      'entityId': serializer.toJson<String?>(entityId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'clientTimestamp': serializer.toJson<DateTime>(clientTimestamp),
      'retryCount': serializer.toJson<int>(retryCount),
      'nextAttemptAt': serializer.toJson<DateTime>(nextAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
      'isTerminal': serializer.toJson<bool>(isTerminal),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxTableData copyWith(
          {int? id,
          Value<String?> operationId = const Value.absent(),
          Value<String?> deviceId = const Value.absent(),
          String? accountId,
          String? type,
          Value<String?> entityId = const Value.absent(),
          String? payloadJson,
          DateTime? clientTimestamp,
          int? retryCount,
          DateTime? nextAttemptAt,
          Value<String?> lastError = const Value.absent(),
          bool? isTerminal,
          DateTime? createdAt}) =>
      OutboxTableData(
        id: id ?? this.id,
        operationId: operationId.present ? operationId.value : this.operationId,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
        accountId: accountId ?? this.accountId,
        type: type ?? this.type,
        entityId: entityId.present ? entityId.value : this.entityId,
        payloadJson: payloadJson ?? this.payloadJson,
        clientTimestamp: clientTimestamp ?? this.clientTimestamp,
        retryCount: retryCount ?? this.retryCount,
        nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
        lastError: lastError.present ? lastError.value : this.lastError,
        isTerminal: isTerminal ?? this.isTerminal,
        createdAt: createdAt ?? this.createdAt,
      );
  OutboxTableData copyWithCompanion(OutboxTableCompanion data) {
    return OutboxTableData(
      id: data.id.present ? data.id.value : this.id,
      operationId:
          data.operationId.present ? data.operationId.value : this.operationId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      type: data.type.present ? data.type.value : this.type,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      clientTimestamp: data.clientTimestamp.present
          ? data.clientTimestamp.value
          : this.clientTimestamp,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      isTerminal:
          data.isTerminal.present ? data.isTerminal.value : this.isTerminal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxTableData(')
          ..write('id: $id, ')
          ..write('operationId: $operationId, ')
          ..write('deviceId: $deviceId, ')
          ..write('accountId: $accountId, ')
          ..write('type: $type, ')
          ..write('entityId: $entityId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('clientTimestamp: $clientTimestamp, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('isTerminal: $isTerminal, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      operationId,
      deviceId,
      accountId,
      type,
      entityId,
      payloadJson,
      clientTimestamp,
      retryCount,
      nextAttemptAt,
      lastError,
      isTerminal,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxTableData &&
          other.id == this.id &&
          other.operationId == this.operationId &&
          other.deviceId == this.deviceId &&
          other.accountId == this.accountId &&
          other.type == this.type &&
          other.entityId == this.entityId &&
          other.payloadJson == this.payloadJson &&
          other.clientTimestamp == this.clientTimestamp &&
          other.retryCount == this.retryCount &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastError == this.lastError &&
          other.isTerminal == this.isTerminal &&
          other.createdAt == this.createdAt);
}

class OutboxTableCompanion extends UpdateCompanion<OutboxTableData> {
  final Value<int> id;
  final Value<String?> operationId;
  final Value<String?> deviceId;
  final Value<String> accountId;
  final Value<String> type;
  final Value<String?> entityId;
  final Value<String> payloadJson;
  final Value<DateTime> clientTimestamp;
  final Value<int> retryCount;
  final Value<DateTime> nextAttemptAt;
  final Value<String?> lastError;
  final Value<bool> isTerminal;
  final Value<DateTime> createdAt;
  const OutboxTableCompanion({
    this.id = const Value.absent(),
    this.operationId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.type = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.clientTimestamp = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.isTerminal = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxTableCompanion.insert({
    this.id = const Value.absent(),
    this.operationId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.accountId = const Value.absent(),
    required String type,
    this.entityId = const Value.absent(),
    required String payloadJson,
    this.clientTimestamp = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.isTerminal = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : type = Value(type),
        payloadJson = Value(payloadJson);
  static Insertable<OutboxTableData> custom({
    Expression<int>? id,
    Expression<String>? operationId,
    Expression<String>? deviceId,
    Expression<String>? accountId,
    Expression<String>? type,
    Expression<String>? entityId,
    Expression<String>? payloadJson,
    Expression<DateTime>? clientTimestamp,
    Expression<int>? retryCount,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? lastError,
    Expression<bool>? isTerminal,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operationId != null) 'operation_id': operationId,
      if (deviceId != null) 'device_id': deviceId,
      if (accountId != null) 'account_id': accountId,
      if (type != null) 'type': type,
      if (entityId != null) 'entity_id': entityId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (clientTimestamp != null) 'client_timestamp': clientTimestamp,
      if (retryCount != null) 'retry_count': retryCount,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (isTerminal != null) 'is_terminal': isTerminal,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxTableCompanion copyWith(
      {Value<int>? id,
      Value<String?>? operationId,
      Value<String?>? deviceId,
      Value<String>? accountId,
      Value<String>? type,
      Value<String?>? entityId,
      Value<String>? payloadJson,
      Value<DateTime>? clientTimestamp,
      Value<int>? retryCount,
      Value<DateTime>? nextAttemptAt,
      Value<String?>? lastError,
      Value<bool>? isTerminal,
      Value<DateTime>? createdAt}) {
    return OutboxTableCompanion(
      id: id ?? this.id,
      operationId: operationId ?? this.operationId,
      deviceId: deviceId ?? this.deviceId,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      entityId: entityId ?? this.entityId,
      payloadJson: payloadJson ?? this.payloadJson,
      clientTimestamp: clientTimestamp ?? this.clientTimestamp,
      retryCount: retryCount ?? this.retryCount,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastError: lastError ?? this.lastError,
      isTerminal: isTerminal ?? this.isTerminal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (clientTimestamp.present) {
      map['client_timestamp'] = Variable<DateTime>(clientTimestamp.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (isTerminal.present) {
      map['is_terminal'] = Variable<bool>(isTerminal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxTableCompanion(')
          ..write('id: $id, ')
          ..write('operationId: $operationId, ')
          ..write('deviceId: $deviceId, ')
          ..write('accountId: $accountId, ')
          ..write('type: $type, ')
          ..write('entityId: $entityId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('clientTimestamp: $clientTimestamp, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('isTerminal: $isTerminal, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SyncStatesTableTable extends SyncStatesTable
    with TableInfo<$SyncStatesTableTable, SyncStatesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<String> cursor = GeneratedColumn<String>(
      'cursor', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncAtMeta =
      const VerificationMeta('lastSyncAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
      'last_sync_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [userId, cursor, lastSyncAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_states_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<SyncStatesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(_cursorMeta,
          cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta));
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
          _lastSyncAtMeta,
          lastSyncAt.isAcceptableOrUnknown(
              data['last_sync_at']!, _lastSyncAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  SyncStatesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStatesTableData(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      cursor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cursor']),
      lastSyncAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_sync_at']),
    );
  }

  @override
  $SyncStatesTableTable createAlias(String alias) {
    return $SyncStatesTableTable(attachedDatabase, alias);
  }
}

class SyncStatesTableData extends DataClass
    implements Insertable<SyncStatesTableData> {
  final String userId;
  final String? cursor;
  final DateTime? lastSyncAt;
  const SyncStatesTableData(
      {required this.userId, this.cursor, this.lastSyncAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || cursor != null) {
      map['cursor'] = Variable<String>(cursor);
    }
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    return map;
  }

  SyncStatesTableCompanion toCompanion(bool nullToAbsent) {
    return SyncStatesTableCompanion(
      userId: Value(userId),
      cursor:
          cursor == null && nullToAbsent ? const Value.absent() : Value(cursor),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
    );
  }

  factory SyncStatesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStatesTableData(
      userId: serializer.fromJson<String>(json['userId']),
      cursor: serializer.fromJson<String?>(json['cursor']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'cursor': serializer.toJson<String?>(cursor),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
    };
  }

  SyncStatesTableData copyWith(
          {String? userId,
          Value<String?> cursor = const Value.absent(),
          Value<DateTime?> lastSyncAt = const Value.absent()}) =>
      SyncStatesTableData(
        userId: userId ?? this.userId,
        cursor: cursor.present ? cursor.value : this.cursor,
        lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
      );
  SyncStatesTableData copyWithCompanion(SyncStatesTableCompanion data) {
    return SyncStatesTableData(
      userId: data.userId.present ? data.userId.value : this.userId,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      lastSyncAt:
          data.lastSyncAt.present ? data.lastSyncAt.value : this.lastSyncAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatesTableData(')
          ..write('userId: $userId, ')
          ..write('cursor: $cursor, ')
          ..write('lastSyncAt: $lastSyncAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, cursor, lastSyncAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStatesTableData &&
          other.userId == this.userId &&
          other.cursor == this.cursor &&
          other.lastSyncAt == this.lastSyncAt);
}

class SyncStatesTableCompanion extends UpdateCompanion<SyncStatesTableData> {
  final Value<String> userId;
  final Value<String?> cursor;
  final Value<DateTime?> lastSyncAt;
  final Value<int> rowid;
  const SyncStatesTableCompanion({
    this.userId = const Value.absent(),
    this.cursor = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStatesTableCompanion.insert({
    required String userId,
    this.cursor = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<SyncStatesTableData> custom({
    Expression<String>? userId,
    Expression<String>? cursor,
    Expression<DateTime>? lastSyncAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (cursor != null) 'cursor': cursor,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStatesTableCompanion copyWith(
      {Value<String>? userId,
      Value<String?>? cursor,
      Value<DateTime?>? lastSyncAt,
      Value<int>? rowid}) {
    return SyncStatesTableCompanion(
      userId: userId ?? this.userId,
      cursor: cursor ?? this.cursor,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<String>(cursor.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatesTableCompanion(')
          ..write('userId: $userId, ')
          ..write('cursor: $cursor, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $TaskListsTableTable taskListsTable = $TaskListsTableTable(this);
  late final $TasksTableTable tasksTable = $TasksTableTable(this);
  late final $CollaboratorsTableTable collaboratorsTable =
      $CollaboratorsTableTable(this);
  late final $OutboxTableTable outboxTable = $OutboxTableTable(this);
  late final $SyncStatesTableTable syncStatesTable =
      $SyncStatesTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        taskListsTable,
        tasksTable,
        collaboratorsTable,
        outboxTable,
        syncStatesTable
      ];
}

typedef $$TaskListsTableTableCreateCompanionBuilder = TaskListsTableCompanion
    Function({
  Value<int> localId,
  Value<String?> serverId,
  Value<String> accountId,
  required String name,
  Value<String> colorHex,
  Value<bool> isHidden,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<int> version,
  Value<DateTime?> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
});
typedef $$TaskListsTableTableUpdateCompanionBuilder = TaskListsTableCompanion
    Function({
  Value<int> localId,
  Value<String?> serverId,
  Value<String> accountId,
  Value<String> name,
  Value<String> colorHex,
  Value<bool> isHidden,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<int> version,
  Value<DateTime?> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
});

class $$TaskListsTableTableFilterComposer
    extends Composer<_$AppDb, $TaskListsTableTable> {
  $$TaskListsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isHidden => $composableBuilder(
      column: $table.isHidden, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$TaskListsTableTableOrderingComposer
    extends Composer<_$AppDb, $TaskListsTableTable> {
  $$TaskListsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isHidden => $composableBuilder(
      column: $table.isHidden, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$TaskListsTableTableAnnotationComposer
    extends Composer<_$AppDb, $TaskListsTableTable> {
  $$TaskListsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TaskListsTableTableTableManager extends RootTableManager<
    _$AppDb,
    $TaskListsTableTable,
    TaskListsTableData,
    $$TaskListsTableTableFilterComposer,
    $$TaskListsTableTableOrderingComposer,
    $$TaskListsTableTableAnnotationComposer,
    $$TaskListsTableTableCreateCompanionBuilder,
    $$TaskListsTableTableUpdateCompanionBuilder,
    (
      TaskListsTableData,
      BaseReferences<_$AppDb, $TaskListsTableTable, TaskListsTableData>
    ),
    TaskListsTableData,
    PrefetchHooks Function()> {
  $$TaskListsTableTableTableManager(_$AppDb db, $TaskListsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskListsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskListsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskListsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> colorHex = const Value.absent(),
            Value<bool> isHidden = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              TaskListsTableCompanion(
            localId: localId,
            serverId: serverId,
            accountId: accountId,
            name: name,
            colorHex: colorHex,
            isHidden: isHidden,
            isDirty: isDirty,
            isDeleted: isDeleted,
            version: version,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
          ),
          createCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            required String name,
            Value<String> colorHex = const Value.absent(),
            Value<bool> isHidden = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              TaskListsTableCompanion.insert(
            localId: localId,
            serverId: serverId,
            accountId: accountId,
            name: name,
            colorHex: colorHex,
            isHidden: isHidden,
            isDirty: isDirty,
            isDeleted: isDeleted,
            version: version,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TaskListsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDb,
    $TaskListsTableTable,
    TaskListsTableData,
    $$TaskListsTableTableFilterComposer,
    $$TaskListsTableTableOrderingComposer,
    $$TaskListsTableTableAnnotationComposer,
    $$TaskListsTableTableCreateCompanionBuilder,
    $$TaskListsTableTableUpdateCompanionBuilder,
    (
      TaskListsTableData,
      BaseReferences<_$AppDb, $TaskListsTableTable, TaskListsTableData>
    ),
    TaskListsTableData,
    PrefetchHooks Function()>;
typedef $$TasksTableTableCreateCompanionBuilder = TasksTableCompanion Function({
  Value<int> localId,
  Value<String?> serverId,
  Value<String> accountId,
  required String name,
  Value<String?> dateYmd,
  Value<String?> note,
  Value<String?> notificationTime,
  Value<bool> isCompleted,
  Value<bool> trashed,
  Value<String?> urgency,
  Value<int?> position,
  Value<int?> taskListLocalId,
  Value<String?> taskListServerId,
  Value<int?> parentLocalId,
  Value<String?> parentServerId,
  Value<String?> hash,
  Value<bool> isShared,
  Value<String?> collaborationRole,
  Value<String?> collaboratorsJson,
  Value<int> version,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
});
typedef $$TasksTableTableUpdateCompanionBuilder = TasksTableCompanion Function({
  Value<int> localId,
  Value<String?> serverId,
  Value<String> accountId,
  Value<String> name,
  Value<String?> dateYmd,
  Value<String?> note,
  Value<String?> notificationTime,
  Value<bool> isCompleted,
  Value<bool> trashed,
  Value<String?> urgency,
  Value<int?> position,
  Value<int?> taskListLocalId,
  Value<String?> taskListServerId,
  Value<int?> parentLocalId,
  Value<String?> parentServerId,
  Value<String?> hash,
  Value<bool> isShared,
  Value<String?> collaborationRole,
  Value<String?> collaboratorsJson,
  Value<int> version,
  Value<bool> isDirty,
  Value<bool> isDeleted,
  Value<DateTime?> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
});

class $$TasksTableTableFilterComposer
    extends Composer<_$AppDb, $TasksTableTable> {
  $$TasksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateYmd => $composableBuilder(
      column: $table.dateYmd, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notificationTime => $composableBuilder(
      column: $table.notificationTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get trashed => $composableBuilder(
      column: $table.trashed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get urgency => $composableBuilder(
      column: $table.urgency, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get taskListLocalId => $composableBuilder(
      column: $table.taskListLocalId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskListServerId => $composableBuilder(
      column: $table.taskListServerId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get parentLocalId => $composableBuilder(
      column: $table.parentLocalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentServerId => $composableBuilder(
      column: $table.parentServerId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hash => $composableBuilder(
      column: $table.hash, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isShared => $composableBuilder(
      column: $table.isShared, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collaborationRole => $composableBuilder(
      column: $table.collaborationRole,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collaboratorsJson => $composableBuilder(
      column: $table.collaboratorsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$TasksTableTableOrderingComposer
    extends Composer<_$AppDb, $TasksTableTable> {
  $$TasksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateYmd => $composableBuilder(
      column: $table.dateYmd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notificationTime => $composableBuilder(
      column: $table.notificationTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get trashed => $composableBuilder(
      column: $table.trashed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get urgency => $composableBuilder(
      column: $table.urgency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get taskListLocalId => $composableBuilder(
      column: $table.taskListLocalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskListServerId => $composableBuilder(
      column: $table.taskListServerId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get parentLocalId => $composableBuilder(
      column: $table.parentLocalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentServerId => $composableBuilder(
      column: $table.parentServerId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hash => $composableBuilder(
      column: $table.hash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isShared => $composableBuilder(
      column: $table.isShared, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collaborationRole => $composableBuilder(
      column: $table.collaborationRole,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collaboratorsJson => $composableBuilder(
      column: $table.collaboratorsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$TasksTableTableAnnotationComposer
    extends Composer<_$AppDb, $TasksTableTable> {
  $$TasksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get dateYmd =>
      $composableBuilder(column: $table.dateYmd, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get notificationTime => $composableBuilder(
      column: $table.notificationTime, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<bool> get trashed =>
      $composableBuilder(column: $table.trashed, builder: (column) => column);

  GeneratedColumn<String> get urgency =>
      $composableBuilder(column: $table.urgency, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get taskListLocalId => $composableBuilder(
      column: $table.taskListLocalId, builder: (column) => column);

  GeneratedColumn<String> get taskListServerId => $composableBuilder(
      column: $table.taskListServerId, builder: (column) => column);

  GeneratedColumn<int> get parentLocalId => $composableBuilder(
      column: $table.parentLocalId, builder: (column) => column);

  GeneratedColumn<String> get parentServerId => $composableBuilder(
      column: $table.parentServerId, builder: (column) => column);

  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<bool> get isShared =>
      $composableBuilder(column: $table.isShared, builder: (column) => column);

  GeneratedColumn<String> get collaborationRole => $composableBuilder(
      column: $table.collaborationRole, builder: (column) => column);

  GeneratedColumn<String> get collaboratorsJson => $composableBuilder(
      column: $table.collaboratorsJson, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TasksTableTableTableManager extends RootTableManager<
    _$AppDb,
    $TasksTableTable,
    TasksTableData,
    $$TasksTableTableFilterComposer,
    $$TasksTableTableOrderingComposer,
    $$TasksTableTableAnnotationComposer,
    $$TasksTableTableCreateCompanionBuilder,
    $$TasksTableTableUpdateCompanionBuilder,
    (TasksTableData, BaseReferences<_$AppDb, $TasksTableTable, TasksTableData>),
    TasksTableData,
    PrefetchHooks Function()> {
  $$TasksTableTableTableManager(_$AppDb db, $TasksTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> dateYmd = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> notificationTime = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> trashed = const Value.absent(),
            Value<String?> urgency = const Value.absent(),
            Value<int?> position = const Value.absent(),
            Value<int?> taskListLocalId = const Value.absent(),
            Value<String?> taskListServerId = const Value.absent(),
            Value<int?> parentLocalId = const Value.absent(),
            Value<String?> parentServerId = const Value.absent(),
            Value<String?> hash = const Value.absent(),
            Value<bool> isShared = const Value.absent(),
            Value<String?> collaborationRole = const Value.absent(),
            Value<String?> collaboratorsJson = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              TasksTableCompanion(
            localId: localId,
            serverId: serverId,
            accountId: accountId,
            name: name,
            dateYmd: dateYmd,
            note: note,
            notificationTime: notificationTime,
            isCompleted: isCompleted,
            trashed: trashed,
            urgency: urgency,
            position: position,
            taskListLocalId: taskListLocalId,
            taskListServerId: taskListServerId,
            parentLocalId: parentLocalId,
            parentServerId: parentServerId,
            hash: hash,
            isShared: isShared,
            collaborationRole: collaborationRole,
            collaboratorsJson: collaboratorsJson,
            version: version,
            isDirty: isDirty,
            isDeleted: isDeleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
          ),
          createCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            required String name,
            Value<String?> dateYmd = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> notificationTime = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> trashed = const Value.absent(),
            Value<String?> urgency = const Value.absent(),
            Value<int?> position = const Value.absent(),
            Value<int?> taskListLocalId = const Value.absent(),
            Value<String?> taskListServerId = const Value.absent(),
            Value<int?> parentLocalId = const Value.absent(),
            Value<String?> parentServerId = const Value.absent(),
            Value<String?> hash = const Value.absent(),
            Value<bool> isShared = const Value.absent(),
            Value<String?> collaborationRole = const Value.absent(),
            Value<String?> collaboratorsJson = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              TasksTableCompanion.insert(
            localId: localId,
            serverId: serverId,
            accountId: accountId,
            name: name,
            dateYmd: dateYmd,
            note: note,
            notificationTime: notificationTime,
            isCompleted: isCompleted,
            trashed: trashed,
            urgency: urgency,
            position: position,
            taskListLocalId: taskListLocalId,
            taskListServerId: taskListServerId,
            parentLocalId: parentLocalId,
            parentServerId: parentServerId,
            hash: hash,
            isShared: isShared,
            collaborationRole: collaborationRole,
            collaboratorsJson: collaboratorsJson,
            version: version,
            isDirty: isDirty,
            isDeleted: isDeleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TasksTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDb,
    $TasksTableTable,
    TasksTableData,
    $$TasksTableTableFilterComposer,
    $$TasksTableTableOrderingComposer,
    $$TasksTableTableAnnotationComposer,
    $$TasksTableTableCreateCompanionBuilder,
    $$TasksTableTableUpdateCompanionBuilder,
    (TasksTableData, BaseReferences<_$AppDb, $TasksTableTable, TasksTableData>),
    TasksTableData,
    PrefetchHooks Function()>;
typedef $$CollaboratorsTableTableCreateCompanionBuilder
    = CollaboratorsTableCompanion Function({
  required String taskId,
  required String userId,
  Value<String?> name,
  required String role,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$CollaboratorsTableTableUpdateCompanionBuilder
    = CollaboratorsTableCompanion Function({
  Value<String> taskId,
  Value<String> userId,
  Value<String?> name,
  Value<String> role,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CollaboratorsTableTableFilterComposer
    extends Composer<_$AppDb, $CollaboratorsTableTable> {
  $$CollaboratorsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CollaboratorsTableTableOrderingComposer
    extends Composer<_$AppDb, $CollaboratorsTableTable> {
  $$CollaboratorsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CollaboratorsTableTableAnnotationComposer
    extends Composer<_$AppDb, $CollaboratorsTableTable> {
  $$CollaboratorsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CollaboratorsTableTableTableManager extends RootTableManager<
    _$AppDb,
    $CollaboratorsTableTable,
    CollaboratorsTableData,
    $$CollaboratorsTableTableFilterComposer,
    $$CollaboratorsTableTableOrderingComposer,
    $$CollaboratorsTableTableAnnotationComposer,
    $$CollaboratorsTableTableCreateCompanionBuilder,
    $$CollaboratorsTableTableUpdateCompanionBuilder,
    (
      CollaboratorsTableData,
      BaseReferences<_$AppDb, $CollaboratorsTableTable, CollaboratorsTableData>
    ),
    CollaboratorsTableData,
    PrefetchHooks Function()> {
  $$CollaboratorsTableTableTableManager(
      _$AppDb db, $CollaboratorsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollaboratorsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollaboratorsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollaboratorsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> taskId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CollaboratorsTableCompanion(
            taskId: taskId,
            userId: userId,
            name: name,
            role: role,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String taskId,
            required String userId,
            Value<String?> name = const Value.absent(),
            required String role,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CollaboratorsTableCompanion.insert(
            taskId: taskId,
            userId: userId,
            name: name,
            role: role,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CollaboratorsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDb,
    $CollaboratorsTableTable,
    CollaboratorsTableData,
    $$CollaboratorsTableTableFilterComposer,
    $$CollaboratorsTableTableOrderingComposer,
    $$CollaboratorsTableTableAnnotationComposer,
    $$CollaboratorsTableTableCreateCompanionBuilder,
    $$CollaboratorsTableTableUpdateCompanionBuilder,
    (
      CollaboratorsTableData,
      BaseReferences<_$AppDb, $CollaboratorsTableTable, CollaboratorsTableData>
    ),
    CollaboratorsTableData,
    PrefetchHooks Function()>;
typedef $$OutboxTableTableCreateCompanionBuilder = OutboxTableCompanion
    Function({
  Value<int> id,
  Value<String?> operationId,
  Value<String?> deviceId,
  Value<String> accountId,
  required String type,
  Value<String?> entityId,
  required String payloadJson,
  Value<DateTime> clientTimestamp,
  Value<int> retryCount,
  Value<DateTime> nextAttemptAt,
  Value<String?> lastError,
  Value<bool> isTerminal,
  Value<DateTime> createdAt,
});
typedef $$OutboxTableTableUpdateCompanionBuilder = OutboxTableCompanion
    Function({
  Value<int> id,
  Value<String?> operationId,
  Value<String?> deviceId,
  Value<String> accountId,
  Value<String> type,
  Value<String?> entityId,
  Value<String> payloadJson,
  Value<DateTime> clientTimestamp,
  Value<int> retryCount,
  Value<DateTime> nextAttemptAt,
  Value<String?> lastError,
  Value<bool> isTerminal,
  Value<DateTime> createdAt,
});

class $$OutboxTableTableFilterComposer
    extends Composer<_$AppDb, $OutboxTableTable> {
  $$OutboxTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operationId => $composableBuilder(
      column: $table.operationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get clientTimestamp => $composableBuilder(
      column: $table.clientTimestamp,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isTerminal => $composableBuilder(
      column: $table.isTerminal, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$OutboxTableTableOrderingComposer
    extends Composer<_$AppDb, $OutboxTableTable> {
  $$OutboxTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operationId => $composableBuilder(
      column: $table.operationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get clientTimestamp => $composableBuilder(
      column: $table.clientTimestamp,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isTerminal => $composableBuilder(
      column: $table.isTerminal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OutboxTableTableAnnotationComposer
    extends Composer<_$AppDb, $OutboxTableTable> {
  $$OutboxTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operationId => $composableBuilder(
      column: $table.operationId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get clientTimestamp => $composableBuilder(
      column: $table.clientTimestamp, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<bool> get isTerminal => $composableBuilder(
      column: $table.isTerminal, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxTableTableTableManager extends RootTableManager<
    _$AppDb,
    $OutboxTableTable,
    OutboxTableData,
    $$OutboxTableTableFilterComposer,
    $$OutboxTableTableOrderingComposer,
    $$OutboxTableTableAnnotationComposer,
    $$OutboxTableTableCreateCompanionBuilder,
    $$OutboxTableTableUpdateCompanionBuilder,
    (
      OutboxTableData,
      BaseReferences<_$AppDb, $OutboxTableTable, OutboxTableData>
    ),
    OutboxTableData,
    PrefetchHooks Function()> {
  $$OutboxTableTableTableManager(_$AppDb db, $OutboxTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> operationId = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> entityId = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> clientTimestamp = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime> nextAttemptAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<bool> isTerminal = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OutboxTableCompanion(
            id: id,
            operationId: operationId,
            deviceId: deviceId,
            accountId: accountId,
            type: type,
            entityId: entityId,
            payloadJson: payloadJson,
            clientTimestamp: clientTimestamp,
            retryCount: retryCount,
            nextAttemptAt: nextAttemptAt,
            lastError: lastError,
            isTerminal: isTerminal,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> operationId = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            required String type,
            Value<String?> entityId = const Value.absent(),
            required String payloadJson,
            Value<DateTime> clientTimestamp = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime> nextAttemptAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<bool> isTerminal = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OutboxTableCompanion.insert(
            id: id,
            operationId: operationId,
            deviceId: deviceId,
            accountId: accountId,
            type: type,
            entityId: entityId,
            payloadJson: payloadJson,
            clientTimestamp: clientTimestamp,
            retryCount: retryCount,
            nextAttemptAt: nextAttemptAt,
            lastError: lastError,
            isTerminal: isTerminal,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDb,
    $OutboxTableTable,
    OutboxTableData,
    $$OutboxTableTableFilterComposer,
    $$OutboxTableTableOrderingComposer,
    $$OutboxTableTableAnnotationComposer,
    $$OutboxTableTableCreateCompanionBuilder,
    $$OutboxTableTableUpdateCompanionBuilder,
    (
      OutboxTableData,
      BaseReferences<_$AppDb, $OutboxTableTable, OutboxTableData>
    ),
    OutboxTableData,
    PrefetchHooks Function()>;
typedef $$SyncStatesTableTableCreateCompanionBuilder = SyncStatesTableCompanion
    Function({
  required String userId,
  Value<String?> cursor,
  Value<DateTime?> lastSyncAt,
  Value<int> rowid,
});
typedef $$SyncStatesTableTableUpdateCompanionBuilder = SyncStatesTableCompanion
    Function({
  Value<String> userId,
  Value<String?> cursor,
  Value<DateTime?> lastSyncAt,
  Value<int> rowid,
});

class $$SyncStatesTableTableFilterComposer
    extends Composer<_$AppDb, $SyncStatesTableTable> {
  $$SyncStatesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cursor => $composableBuilder(
      column: $table.cursor, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnFilters(column));
}

class $$SyncStatesTableTableOrderingComposer
    extends Composer<_$AppDb, $SyncStatesTableTable> {
  $$SyncStatesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cursor => $composableBuilder(
      column: $table.cursor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncStatesTableTableAnnotationComposer
    extends Composer<_$AppDb, $SyncStatesTableTable> {
  $$SyncStatesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => column);
}

class $$SyncStatesTableTableTableManager extends RootTableManager<
    _$AppDb,
    $SyncStatesTableTable,
    SyncStatesTableData,
    $$SyncStatesTableTableFilterComposer,
    $$SyncStatesTableTableOrderingComposer,
    $$SyncStatesTableTableAnnotationComposer,
    $$SyncStatesTableTableCreateCompanionBuilder,
    $$SyncStatesTableTableUpdateCompanionBuilder,
    (
      SyncStatesTableData,
      BaseReferences<_$AppDb, $SyncStatesTableTable, SyncStatesTableData>
    ),
    SyncStatesTableData,
    PrefetchHooks Function()> {
  $$SyncStatesTableTableTableManager(_$AppDb db, $SyncStatesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStatesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStatesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStatesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<String?> cursor = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStatesTableCompanion(
            userId: userId,
            cursor: cursor,
            lastSyncAt: lastSyncAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            Value<String?> cursor = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStatesTableCompanion.insert(
            userId: userId,
            cursor: cursor,
            lastSyncAt: lastSyncAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncStatesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDb,
    $SyncStatesTableTable,
    SyncStatesTableData,
    $$SyncStatesTableTableFilterComposer,
    $$SyncStatesTableTableOrderingComposer,
    $$SyncStatesTableTableAnnotationComposer,
    $$SyncStatesTableTableCreateCompanionBuilder,
    $$SyncStatesTableTableUpdateCompanionBuilder,
    (
      SyncStatesTableData,
      BaseReferences<_$AppDb, $SyncStatesTableTable, SyncStatesTableData>
    ),
    SyncStatesTableData,
    PrefetchHooks Function()>;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$TaskListsTableTableTableManager get taskListsTable =>
      $$TaskListsTableTableTableManager(_db, _db.taskListsTable);
  $$TasksTableTableTableManager get tasksTable =>
      $$TasksTableTableTableManager(_db, _db.tasksTable);
  $$CollaboratorsTableTableTableManager get collaboratorsTable =>
      $$CollaboratorsTableTableTableManager(_db, _db.collaboratorsTable);
  $$OutboxTableTableTableManager get outboxTable =>
      $$OutboxTableTableTableManager(_db, _db.outboxTable);
  $$SyncStatesTableTableTableManager get syncStatesTable =>
      $$SyncStatesTableTableTableManager(_db, _db.syncStatesTable);
}
