// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedTasksTable extends CachedTasks
    with TableInfo<$CachedTasksTable, CachedTaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledStartMeta = const VerificationMeta(
    'scheduledStart',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledStart =
      GeneratedColumn<DateTime>(
        'scheduled_start',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scheduledStart,
    payload,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedTaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scheduled_start')) {
      context.handle(
        _scheduledStartMeta,
        scheduledStart.isAcceptableOrUnknown(
          data['scheduled_start']!,
          _scheduledStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledStartMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedTaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedTaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scheduledStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_start'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CachedTasksTable createAlias(String alias) {
    return $CachedTasksTable(attachedDatabase, alias);
  }
}

class CachedTaskRow extends DataClass implements Insertable<CachedTaskRow> {
  final String id;
  final DateTime scheduledStart;
  final String payload;
  final DateTime updatedAt;
  const CachedTaskRow({
    required this.id,
    required this.scheduledStart,
    required this.payload,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scheduled_start'] = Variable<DateTime>(scheduledStart);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CachedTasksCompanion toCompanion(bool nullToAbsent) {
    return CachedTasksCompanion(
      id: Value(id),
      scheduledStart: Value(scheduledStart),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedTaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedTaskRow(
      id: serializer.fromJson<String>(json['id']),
      scheduledStart: serializer.fromJson<DateTime>(json['scheduledStart']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scheduledStart': serializer.toJson<DateTime>(scheduledStart),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CachedTaskRow copyWith({
    String? id,
    DateTime? scheduledStart,
    String? payload,
    DateTime? updatedAt,
  }) => CachedTaskRow(
    id: id ?? this.id,
    scheduledStart: scheduledStart ?? this.scheduledStart,
    payload: payload ?? this.payload,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CachedTaskRow copyWithCompanion(CachedTasksCompanion data) {
    return CachedTaskRow(
      id: data.id.present ? data.id.value : this.id,
      scheduledStart: data.scheduledStart.present
          ? data.scheduledStart.value
          : this.scheduledStart,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedTaskRow(')
          ..write('id: $id, ')
          ..write('scheduledStart: $scheduledStart, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, scheduledStart, payload, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedTaskRow &&
          other.id == this.id &&
          other.scheduledStart == this.scheduledStart &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt);
}

class CachedTasksCompanion extends UpdateCompanion<CachedTaskRow> {
  final Value<String> id;
  final Value<DateTime> scheduledStart;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CachedTasksCompanion({
    this.id = const Value.absent(),
    this.scheduledStart = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedTasksCompanion.insert({
    required String id,
    required DateTime scheduledStart,
    required String payload,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scheduledStart = Value(scheduledStart),
       payload = Value(payload),
       updatedAt = Value(updatedAt);
  static Insertable<CachedTaskRow> custom({
    Expression<String>? id,
    Expression<DateTime>? scheduledStart,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scheduledStart != null) 'scheduled_start': scheduledStart,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedTasksCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? scheduledStart,
    Value<String>? payload,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CachedTasksCompanion(
      id: id ?? this.id,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scheduledStart.present) {
      map['scheduled_start'] = Variable<DateTime>(scheduledStart.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
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
    return (StringBuffer('CachedTasksCompanion(')
          ..write('id: $id, ')
          ..write('scheduledStart: $scheduledStart, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimeEntriesTable extends TimeEntries
    with TableInfo<$TimeEntriesTable, TimeEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimeEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startLocationCheckIdMeta =
      const VerificationMeta('startLocationCheckId');
  @override
  late final GeneratedColumn<String> startLocationCheckId =
      GeneratedColumn<String>(
        'start_location_check_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    kind,
    startedAt,
    endedAt,
    startLocationCheckId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'time_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimeEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('start_location_check_id')) {
      context.handle(
        _startLocationCheckIdMeta,
        startLocationCheckId.isAcceptableOrUnknown(
          data['start_location_check_id']!,
          _startLocationCheckIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimeEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimeEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      startLocationCheckId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_location_check_id'],
      ),
    );
  }

  @override
  $TimeEntriesTable createAlias(String alias) {
    return $TimeEntriesTable(attachedDatabase, alias);
  }
}

class TimeEntryRow extends DataClass implements Insertable<TimeEntryRow> {
  final String id;
  final String taskId;
  final String kind;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? startLocationCheckId;
  const TimeEntryRow({
    required this.id,
    required this.taskId,
    required this.kind,
    required this.startedAt,
    this.endedAt,
    this.startLocationCheckId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['kind'] = Variable<String>(kind);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || startLocationCheckId != null) {
      map['start_location_check_id'] = Variable<String>(startLocationCheckId);
    }
    return map;
  }

  TimeEntriesCompanion toCompanion(bool nullToAbsent) {
    return TimeEntriesCompanion(
      id: Value(id),
      taskId: Value(taskId),
      kind: Value(kind),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      startLocationCheckId: startLocationCheckId == null && nullToAbsent
          ? const Value.absent()
          : Value(startLocationCheckId),
    );
  }

  factory TimeEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimeEntryRow(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      kind: serializer.fromJson<String>(json['kind']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      startLocationCheckId: serializer.fromJson<String?>(
        json['startLocationCheckId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'kind': serializer.toJson<String>(kind),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'startLocationCheckId': serializer.toJson<String?>(startLocationCheckId),
    };
  }

  TimeEntryRow copyWith({
    String? id,
    String? taskId,
    String? kind,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<String?> startLocationCheckId = const Value.absent(),
  }) => TimeEntryRow(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    kind: kind ?? this.kind,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    startLocationCheckId: startLocationCheckId.present
        ? startLocationCheckId.value
        : this.startLocationCheckId,
  );
  TimeEntryRow copyWithCompanion(TimeEntriesCompanion data) {
    return TimeEntryRow(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      kind: data.kind.present ? data.kind.value : this.kind,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      startLocationCheckId: data.startLocationCheckId.present
          ? data.startLocationCheckId.value
          : this.startLocationCheckId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimeEntryRow(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('kind: $kind, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('startLocationCheckId: $startLocationCheckId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, taskId, kind, startedAt, endedAt, startLocationCheckId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeEntryRow &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.kind == this.kind &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.startLocationCheckId == this.startLocationCheckId);
}

class TimeEntriesCompanion extends UpdateCompanion<TimeEntryRow> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> kind;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String?> startLocationCheckId;
  final Value<int> rowid;
  const TimeEntriesCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.kind = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.startLocationCheckId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimeEntriesCompanion.insert({
    required String id,
    required String taskId,
    required String kind,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.startLocationCheckId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       kind = Value(kind),
       startedAt = Value(startedAt);
  static Insertable<TimeEntryRow> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? kind,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? startLocationCheckId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (kind != null) 'kind': kind,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (startLocationCheckId != null)
        'start_location_check_id': startLocationCheckId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimeEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String>? kind,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<String?>? startLocationCheckId,
    Value<int>? rowid,
  }) {
    return TimeEntriesCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      kind: kind ?? this.kind,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      startLocationCheckId: startLocationCheckId ?? this.startLocationCheckId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (startLocationCheckId.present) {
      map['start_location_check_id'] = Variable<String>(
        startLocationCheckId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimeEntriesCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('kind: $kind, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('startLocationCheckId: $startLocationCheckId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocationChecksTable extends LocationChecks
    with TableInfo<$LocationChecksTable, LocationCheckRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationChecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMMeta = const VerificationMeta(
    'accuracyM',
  );
  @override
  late final GeneratedColumn<double> accuracyM = GeneratedColumn<double>(
    'accuracy_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isMockedMeta = const VerificationMeta(
    'isMocked',
  );
  @override
  late final GeneratedColumn<bool> isMocked = GeneratedColumn<bool>(
    'is_mocked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_mocked" IN (0, 1))',
    ),
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMMeta = const VerificationMeta(
    'distanceM',
  );
  @override
  late final GeneratedColumn<double> distanceM = GeneratedColumn<double>(
    'distance_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _radiusMMeta = const VerificationMeta(
    'radiusM',
  );
  @override
  late final GeneratedColumn<double> radiusM = GeneratedColumn<double>(
    'radius_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verifiedMeta = const VerificationMeta(
    'verified',
  );
  @override
  late final GeneratedColumn<bool> verified = GeneratedColumn<bool>(
    'verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("verified" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    purpose,
    latitude,
    longitude,
    accuracyM,
    isMocked,
    capturedAt,
    distanceM,
    radiusM,
    verified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'location_checks';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocationCheckRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    } else if (isInserting) {
      context.missing(_purposeMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('accuracy_m')) {
      context.handle(
        _accuracyMMeta,
        accuracyM.isAcceptableOrUnknown(data['accuracy_m']!, _accuracyMMeta),
      );
    } else if (isInserting) {
      context.missing(_accuracyMMeta);
    }
    if (data.containsKey('is_mocked')) {
      context.handle(
        _isMockedMeta,
        isMocked.isAcceptableOrUnknown(data['is_mocked']!, _isMockedMeta),
      );
    } else if (isInserting) {
      context.missing(_isMockedMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('distance_m')) {
      context.handle(
        _distanceMMeta,
        distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta),
      );
    } else if (isInserting) {
      context.missing(_distanceMMeta);
    }
    if (data.containsKey('radius_m')) {
      context.handle(
        _radiusMMeta,
        radiusM.isAcceptableOrUnknown(data['radius_m']!, _radiusMMeta),
      );
    } else if (isInserting) {
      context.missing(_radiusMMeta);
    }
    if (data.containsKey('verified')) {
      context.handle(
        _verifiedMeta,
        verified.isAcceptableOrUnknown(data['verified']!, _verifiedMeta),
      );
    } else if (isInserting) {
      context.missing(_verifiedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationCheckRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationCheckRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      accuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_m'],
      )!,
      isMocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_mocked'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      distanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_m'],
      )!,
      radiusM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}radius_m'],
      )!,
      verified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}verified'],
      )!,
    );
  }

  @override
  $LocationChecksTable createAlias(String alias) {
    return $LocationChecksTable(attachedDatabase, alias);
  }
}

class LocationCheckRow extends DataClass
    implements Insertable<LocationCheckRow> {
  final String id;
  final String taskId;
  final String purpose;
  final double latitude;
  final double longitude;
  final double accuracyM;
  final bool isMocked;
  final DateTime capturedAt;
  final double distanceM;
  final double radiusM;
  final bool verified;
  const LocationCheckRow({
    required this.id,
    required this.taskId,
    required this.purpose,
    required this.latitude,
    required this.longitude,
    required this.accuracyM,
    required this.isMocked,
    required this.capturedAt,
    required this.distanceM,
    required this.radiusM,
    required this.verified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['purpose'] = Variable<String>(purpose);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['accuracy_m'] = Variable<double>(accuracyM);
    map['is_mocked'] = Variable<bool>(isMocked);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    map['distance_m'] = Variable<double>(distanceM);
    map['radius_m'] = Variable<double>(radiusM);
    map['verified'] = Variable<bool>(verified);
    return map;
  }

  LocationChecksCompanion toCompanion(bool nullToAbsent) {
    return LocationChecksCompanion(
      id: Value(id),
      taskId: Value(taskId),
      purpose: Value(purpose),
      latitude: Value(latitude),
      longitude: Value(longitude),
      accuracyM: Value(accuracyM),
      isMocked: Value(isMocked),
      capturedAt: Value(capturedAt),
      distanceM: Value(distanceM),
      radiusM: Value(radiusM),
      verified: Value(verified),
    );
  }

  factory LocationCheckRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationCheckRow(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      purpose: serializer.fromJson<String>(json['purpose']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      accuracyM: serializer.fromJson<double>(json['accuracyM']),
      isMocked: serializer.fromJson<bool>(json['isMocked']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      distanceM: serializer.fromJson<double>(json['distanceM']),
      radiusM: serializer.fromJson<double>(json['radiusM']),
      verified: serializer.fromJson<bool>(json['verified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'purpose': serializer.toJson<String>(purpose),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'accuracyM': serializer.toJson<double>(accuracyM),
      'isMocked': serializer.toJson<bool>(isMocked),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'distanceM': serializer.toJson<double>(distanceM),
      'radiusM': serializer.toJson<double>(radiusM),
      'verified': serializer.toJson<bool>(verified),
    };
  }

  LocationCheckRow copyWith({
    String? id,
    String? taskId,
    String? purpose,
    double? latitude,
    double? longitude,
    double? accuracyM,
    bool? isMocked,
    DateTime? capturedAt,
    double? distanceM,
    double? radiusM,
    bool? verified,
  }) => LocationCheckRow(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    purpose: purpose ?? this.purpose,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    accuracyM: accuracyM ?? this.accuracyM,
    isMocked: isMocked ?? this.isMocked,
    capturedAt: capturedAt ?? this.capturedAt,
    distanceM: distanceM ?? this.distanceM,
    radiusM: radiusM ?? this.radiusM,
    verified: verified ?? this.verified,
  );
  LocationCheckRow copyWithCompanion(LocationChecksCompanion data) {
    return LocationCheckRow(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      accuracyM: data.accuracyM.present ? data.accuracyM.value : this.accuracyM,
      isMocked: data.isMocked.present ? data.isMocked.value : this.isMocked,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      radiusM: data.radiusM.present ? data.radiusM.value : this.radiusM,
      verified: data.verified.present ? data.verified.value : this.verified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationCheckRow(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('purpose: $purpose, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('isMocked: $isMocked, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('distanceM: $distanceM, ')
          ..write('radiusM: $radiusM, ')
          ..write('verified: $verified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    purpose,
    latitude,
    longitude,
    accuracyM,
    isMocked,
    capturedAt,
    distanceM,
    radiusM,
    verified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationCheckRow &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.purpose == this.purpose &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.accuracyM == this.accuracyM &&
          other.isMocked == this.isMocked &&
          other.capturedAt == this.capturedAt &&
          other.distanceM == this.distanceM &&
          other.radiusM == this.radiusM &&
          other.verified == this.verified);
}

class LocationChecksCompanion extends UpdateCompanion<LocationCheckRow> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> purpose;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> accuracyM;
  final Value<bool> isMocked;
  final Value<DateTime> capturedAt;
  final Value<double> distanceM;
  final Value<double> radiusM;
  final Value<bool> verified;
  final Value<int> rowid;
  const LocationChecksCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.purpose = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.isMocked = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.radiusM = const Value.absent(),
    this.verified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationChecksCompanion.insert({
    required String id,
    required String taskId,
    required String purpose,
    required double latitude,
    required double longitude,
    required double accuracyM,
    required bool isMocked,
    required DateTime capturedAt,
    required double distanceM,
    required double radiusM,
    required bool verified,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       purpose = Value(purpose),
       latitude = Value(latitude),
       longitude = Value(longitude),
       accuracyM = Value(accuracyM),
       isMocked = Value(isMocked),
       capturedAt = Value(capturedAt),
       distanceM = Value(distanceM),
       radiusM = Value(radiusM),
       verified = Value(verified);
  static Insertable<LocationCheckRow> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? purpose,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? accuracyM,
    Expression<bool>? isMocked,
    Expression<DateTime>? capturedAt,
    Expression<double>? distanceM,
    Expression<double>? radiusM,
    Expression<bool>? verified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (purpose != null) 'purpose': purpose,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (isMocked != null) 'is_mocked': isMocked,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (distanceM != null) 'distance_m': distanceM,
      if (radiusM != null) 'radius_m': radiusM,
      if (verified != null) 'verified': verified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationChecksCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String>? purpose,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double>? accuracyM,
    Value<bool>? isMocked,
    Value<DateTime>? capturedAt,
    Value<double>? distanceM,
    Value<double>? radiusM,
    Value<bool>? verified,
    Value<int>? rowid,
  }) {
    return LocationChecksCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      purpose: purpose ?? this.purpose,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyM: accuracyM ?? this.accuracyM,
      isMocked: isMocked ?? this.isMocked,
      capturedAt: capturedAt ?? this.capturedAt,
      distanceM: distanceM ?? this.distanceM,
      radiusM: radiusM ?? this.radiusM,
      verified: verified ?? this.verified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (accuracyM.present) {
      map['accuracy_m'] = Variable<double>(accuracyM.value);
    }
    if (isMocked.present) {
      map['is_mocked'] = Variable<bool>(isMocked.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<double>(distanceM.value);
    }
    if (radiusM.present) {
      map['radius_m'] = Variable<double>(radiusM.value);
    }
    if (verified.present) {
      map['verified'] = Variable<bool>(verified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationChecksCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('purpose: $purpose, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('isMocked: $isMocked, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('distanceM: $distanceM, ')
          ..write('radiusM: $radiusM, ')
          ..write('verified: $verified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, PhotoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uploadStateMeta = const VerificationMeta(
    'uploadState',
  );
  @override
  late final GeneratedColumn<String> uploadState = GeneratedColumn<String>(
    'upload_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    localPath,
    kind,
    takenAt,
    latitude,
    longitude,
    uploadState,
    progress,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhotoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('upload_state')) {
      context.handle(
        _uploadStateMeta,
        uploadState.isAcceptableOrUnknown(
          data['upload_state']!,
          _uploadStateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uploadStateMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhotoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhotoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      uploadState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upload_state'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }
}

class PhotoRow extends DataClass implements Insertable<PhotoRow> {
  final String id;
  final String taskId;
  final String? localPath;
  final String kind;
  final DateTime takenAt;
  final double? latitude;
  final double? longitude;
  final String uploadState;
  final double progress;
  final String? lastError;
  const PhotoRow({
    required this.id,
    required this.taskId,
    this.localPath,
    required this.kind,
    required this.takenAt,
    this.latitude,
    this.longitude,
    required this.uploadState,
    required this.progress,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    map['kind'] = Variable<String>(kind);
    map['taken_at'] = Variable<DateTime>(takenAt);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['upload_state'] = Variable<String>(uploadState);
    map['progress'] = Variable<double>(progress);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      taskId: Value(taskId),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      kind: Value(kind),
      takenAt: Value(takenAt),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      uploadState: Value(uploadState),
      progress: Value(progress),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory PhotoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhotoRow(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      kind: serializer.fromJson<String>(json['kind']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      uploadState: serializer.fromJson<String>(json['uploadState']),
      progress: serializer.fromJson<double>(json['progress']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'localPath': serializer.toJson<String?>(localPath),
      'kind': serializer.toJson<String>(kind),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'uploadState': serializer.toJson<String>(uploadState),
      'progress': serializer.toJson<double>(progress),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  PhotoRow copyWith({
    String? id,
    String? taskId,
    Value<String?> localPath = const Value.absent(),
    String? kind,
    DateTime? takenAt,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    String? uploadState,
    double? progress,
    Value<String?> lastError = const Value.absent(),
  }) => PhotoRow(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    localPath: localPath.present ? localPath.value : this.localPath,
    kind: kind ?? this.kind,
    takenAt: takenAt ?? this.takenAt,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    uploadState: uploadState ?? this.uploadState,
    progress: progress ?? this.progress,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  PhotoRow copyWithCompanion(PhotosCompanion data) {
    return PhotoRow(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      kind: data.kind.present ? data.kind.value : this.kind,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      uploadState: data.uploadState.present
          ? data.uploadState.value
          : this.uploadState,
      progress: data.progress.present ? data.progress.value : this.progress,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhotoRow(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('localPath: $localPath, ')
          ..write('kind: $kind, ')
          ..write('takenAt: $takenAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('uploadState: $uploadState, ')
          ..write('progress: $progress, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    localPath,
    kind,
    takenAt,
    latitude,
    longitude,
    uploadState,
    progress,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhotoRow &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.localPath == this.localPath &&
          other.kind == this.kind &&
          other.takenAt == this.takenAt &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.uploadState == this.uploadState &&
          other.progress == this.progress &&
          other.lastError == this.lastError);
}

class PhotosCompanion extends UpdateCompanion<PhotoRow> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String?> localPath;
  final Value<String> kind;
  final Value<DateTime> takenAt;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String> uploadState;
  final Value<double> progress;
  final Value<String?> lastError;
  final Value<int> rowid;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.kind = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.uploadState = const Value.absent(),
    this.progress = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosCompanion.insert({
    required String id,
    required String taskId,
    this.localPath = const Value.absent(),
    required String kind,
    required DateTime takenAt,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    required String uploadState,
    this.progress = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       kind = Value(kind),
       takenAt = Value(takenAt),
       uploadState = Value(uploadState);
  static Insertable<PhotoRow> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? localPath,
    Expression<String>? kind,
    Expression<DateTime>? takenAt,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? uploadState,
    Expression<double>? progress,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (localPath != null) 'local_path': localPath,
      if (kind != null) 'kind': kind,
      if (takenAt != null) 'taken_at': takenAt,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (uploadState != null) 'upload_state': uploadState,
      if (progress != null) 'progress': progress,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String?>? localPath,
    Value<String>? kind,
    Value<DateTime>? takenAt,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String>? uploadState,
    Value<double>? progress,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return PhotosCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      localPath: localPath ?? this.localPath,
      kind: kind ?? this.kind,
      takenAt: takenAt ?? this.takenAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      uploadState: uploadState ?? this.uploadState,
      progress: progress ?? this.progress,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (uploadState.present) {
      map['upload_state'] = Variable<String>(uploadState.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('localPath: $localPath, ')
          ..write('kind: $kind, ')
          ..write('takenAt: $takenAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('uploadState: $uploadState, ')
          ..write('progress: $progress, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MaterialsTable extends Materials
    with TableInfo<$MaterialsTable, MaterialRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaterialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catalogItemIdMeta = const VerificationMeta(
    'catalogItemId',
  );
  @override
  late final GeneratedColumn<String> catalogItemId = GeneratedColumn<String>(
    'catalog_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemNameMeta = const VerificationMeta(
    'itemName',
  );
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
    'item_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _movementMeta = const VerificationMeta(
    'movement',
  );
  @override
  late final GeneratedColumn<String> movement = GeneratedColumn<String>(
    'movement',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    catalogItemId,
    itemName,
    unit,
    quantity,
    movement,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'materials';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaterialRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('catalog_item_id')) {
      context.handle(
        _catalogItemIdMeta,
        catalogItemId.isAcceptableOrUnknown(
          data['catalog_item_id']!,
          _catalogItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_catalogItemIdMeta);
    }
    if (data.containsKey('item_name')) {
      context.handle(
        _itemNameMeta,
        itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta),
      );
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('movement')) {
      context.handle(
        _movementMeta,
        movement.isAcceptableOrUnknown(data['movement']!, _movementMeta),
      );
    } else if (isInserting) {
      context.missing(_movementMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaterialRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaterialRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      catalogItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_item_id'],
      )!,
      itemName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      movement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movement'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $MaterialsTable createAlias(String alias) {
    return $MaterialsTable(attachedDatabase, alias);
  }
}

class MaterialRow extends DataClass implements Insertable<MaterialRow> {
  final String id;
  final String taskId;
  final String catalogItemId;
  final String itemName;
  final String unit;
  final double quantity;
  final String movement;
  final String? note;
  const MaterialRow({
    required this.id,
    required this.taskId,
    required this.catalogItemId,
    required this.itemName,
    required this.unit,
    required this.quantity,
    required this.movement,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['catalog_item_id'] = Variable<String>(catalogItemId);
    map['item_name'] = Variable<String>(itemName);
    map['unit'] = Variable<String>(unit);
    map['quantity'] = Variable<double>(quantity);
    map['movement'] = Variable<String>(movement);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  MaterialsCompanion toCompanion(bool nullToAbsent) {
    return MaterialsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      catalogItemId: Value(catalogItemId),
      itemName: Value(itemName),
      unit: Value(unit),
      quantity: Value(quantity),
      movement: Value(movement),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory MaterialRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaterialRow(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      catalogItemId: serializer.fromJson<String>(json['catalogItemId']),
      itemName: serializer.fromJson<String>(json['itemName']),
      unit: serializer.fromJson<String>(json['unit']),
      quantity: serializer.fromJson<double>(json['quantity']),
      movement: serializer.fromJson<String>(json['movement']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'catalogItemId': serializer.toJson<String>(catalogItemId),
      'itemName': serializer.toJson<String>(itemName),
      'unit': serializer.toJson<String>(unit),
      'quantity': serializer.toJson<double>(quantity),
      'movement': serializer.toJson<String>(movement),
      'note': serializer.toJson<String?>(note),
    };
  }

  MaterialRow copyWith({
    String? id,
    String? taskId,
    String? catalogItemId,
    String? itemName,
    String? unit,
    double? quantity,
    String? movement,
    Value<String?> note = const Value.absent(),
  }) => MaterialRow(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    catalogItemId: catalogItemId ?? this.catalogItemId,
    itemName: itemName ?? this.itemName,
    unit: unit ?? this.unit,
    quantity: quantity ?? this.quantity,
    movement: movement ?? this.movement,
    note: note.present ? note.value : this.note,
  );
  MaterialRow copyWithCompanion(MaterialsCompanion data) {
    return MaterialRow(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      catalogItemId: data.catalogItemId.present
          ? data.catalogItemId.value
          : this.catalogItemId,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      unit: data.unit.present ? data.unit.value : this.unit,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      movement: data.movement.present ? data.movement.value : this.movement,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaterialRow(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('catalogItemId: $catalogItemId, ')
          ..write('itemName: $itemName, ')
          ..write('unit: $unit, ')
          ..write('quantity: $quantity, ')
          ..write('movement: $movement, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    catalogItemId,
    itemName,
    unit,
    quantity,
    movement,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaterialRow &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.catalogItemId == this.catalogItemId &&
          other.itemName == this.itemName &&
          other.unit == this.unit &&
          other.quantity == this.quantity &&
          other.movement == this.movement &&
          other.note == this.note);
}

class MaterialsCompanion extends UpdateCompanion<MaterialRow> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> catalogItemId;
  final Value<String> itemName;
  final Value<String> unit;
  final Value<double> quantity;
  final Value<String> movement;
  final Value<String?> note;
  final Value<int> rowid;
  const MaterialsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.catalogItemId = const Value.absent(),
    this.itemName = const Value.absent(),
    this.unit = const Value.absent(),
    this.quantity = const Value.absent(),
    this.movement = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MaterialsCompanion.insert({
    required String id,
    required String taskId,
    required String catalogItemId,
    required String itemName,
    required String unit,
    required double quantity,
    required String movement,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       catalogItemId = Value(catalogItemId),
       itemName = Value(itemName),
       unit = Value(unit),
       quantity = Value(quantity),
       movement = Value(movement);
  static Insertable<MaterialRow> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? catalogItemId,
    Expression<String>? itemName,
    Expression<String>? unit,
    Expression<double>? quantity,
    Expression<String>? movement,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (catalogItemId != null) 'catalog_item_id': catalogItemId,
      if (itemName != null) 'item_name': itemName,
      if (unit != null) 'unit': unit,
      if (quantity != null) 'quantity': quantity,
      if (movement != null) 'movement': movement,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MaterialsCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String>? catalogItemId,
    Value<String>? itemName,
    Value<String>? unit,
    Value<double>? quantity,
    Value<String>? movement,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return MaterialsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      catalogItemId: catalogItemId ?? this.catalogItemId,
      itemName: itemName ?? this.itemName,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      movement: movement ?? this.movement,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (catalogItemId.present) {
      map['catalog_item_id'] = Variable<String>(catalogItemId.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (movement.present) {
      map['movement'] = Variable<String>(movement.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaterialsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('catalogItemId: $catalogItemId, ')
          ..write('itemName: $itemName, ')
          ..write('unit: $unit, ')
          ..write('quantity: $quantity, ')
          ..write('movement: $movement, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompletionsTable extends Completions
    with TableInfo<$CompletionsTable, CompletionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _workerIdMeta = const VerificationMeta(
    'workerId',
  );
  @override
  late final GeneratedColumn<String> workerId = GeneratedColumn<String>(
    'worker_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completionLocationCheckIdMeta =
      const VerificationMeta('completionLocationCheckId');
  @override
  late final GeneratedColumn<String> completionLocationCheckId =
      GeneratedColumn<String>(
        'completion_location_check_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalWorkMsMeta = const VerificationMeta(
    'totalWorkMs',
  );
  @override
  late final GeneratedColumn<int> totalWorkMs = GeneratedColumn<int>(
    'total_work_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalBreakMsMeta = const VerificationMeta(
    'totalBreakMs',
  );
  @override
  late final GeneratedColumn<int> totalBreakMs = GeneratedColumn<int>(
    'total_break_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confirmedMeta = const VerificationMeta(
    'confirmed',
  );
  @override
  late final GeneratedColumn<bool> confirmed = GeneratedColumn<bool>(
    'confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("confirmed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    workerId,
    completedAt,
    completionLocationCheckId,
    comment,
    totalWorkMs,
    totalBreakMs,
    confirmed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompletionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('worker_id')) {
      context.handle(
        _workerIdMeta,
        workerId.isAcceptableOrUnknown(data['worker_id']!, _workerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workerIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('completion_location_check_id')) {
      context.handle(
        _completionLocationCheckIdMeta,
        completionLocationCheckId.isAcceptableOrUnknown(
          data['completion_location_check_id']!,
          _completionLocationCheckIdMeta,
        ),
      );
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('total_work_ms')) {
      context.handle(
        _totalWorkMsMeta,
        totalWorkMs.isAcceptableOrUnknown(
          data['total_work_ms']!,
          _totalWorkMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalWorkMsMeta);
    }
    if (data.containsKey('total_break_ms')) {
      context.handle(
        _totalBreakMsMeta,
        totalBreakMs.isAcceptableOrUnknown(
          data['total_break_ms']!,
          _totalBreakMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalBreakMsMeta);
    }
    if (data.containsKey('confirmed')) {
      context.handle(
        _confirmedMeta,
        confirmed.isAcceptableOrUnknown(data['confirmed']!, _confirmedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompletionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      workerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}worker_id'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      completionLocationCheckId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completion_location_check_id'],
      ),
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
      totalWorkMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_work_ms'],
      )!,
      totalBreakMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_break_ms'],
      )!,
      confirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}confirmed'],
      )!,
    );
  }

  @override
  $CompletionsTable createAlias(String alias) {
    return $CompletionsTable(attachedDatabase, alias);
  }
}

class CompletionRow extends DataClass implements Insertable<CompletionRow> {
  final String id;
  final String taskId;
  final String workerId;
  final DateTime completedAt;
  final String? completionLocationCheckId;
  final String? comment;
  final int totalWorkMs;
  final int totalBreakMs;

  /// Server accepted it (task is `completed`).
  final bool confirmed;
  const CompletionRow({
    required this.id,
    required this.taskId,
    required this.workerId,
    required this.completedAt,
    this.completionLocationCheckId,
    this.comment,
    required this.totalWorkMs,
    required this.totalBreakMs,
    required this.confirmed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['worker_id'] = Variable<String>(workerId);
    map['completed_at'] = Variable<DateTime>(completedAt);
    if (!nullToAbsent || completionLocationCheckId != null) {
      map['completion_location_check_id'] = Variable<String>(
        completionLocationCheckId,
      );
    }
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    map['total_work_ms'] = Variable<int>(totalWorkMs);
    map['total_break_ms'] = Variable<int>(totalBreakMs);
    map['confirmed'] = Variable<bool>(confirmed);
    return map;
  }

  CompletionsCompanion toCompanion(bool nullToAbsent) {
    return CompletionsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      workerId: Value(workerId),
      completedAt: Value(completedAt),
      completionLocationCheckId:
          completionLocationCheckId == null && nullToAbsent
          ? const Value.absent()
          : Value(completionLocationCheckId),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      totalWorkMs: Value(totalWorkMs),
      totalBreakMs: Value(totalBreakMs),
      confirmed: Value(confirmed),
    );
  }

  factory CompletionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletionRow(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      workerId: serializer.fromJson<String>(json['workerId']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      completionLocationCheckId: serializer.fromJson<String?>(
        json['completionLocationCheckId'],
      ),
      comment: serializer.fromJson<String?>(json['comment']),
      totalWorkMs: serializer.fromJson<int>(json['totalWorkMs']),
      totalBreakMs: serializer.fromJson<int>(json['totalBreakMs']),
      confirmed: serializer.fromJson<bool>(json['confirmed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'workerId': serializer.toJson<String>(workerId),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'completionLocationCheckId': serializer.toJson<String?>(
        completionLocationCheckId,
      ),
      'comment': serializer.toJson<String?>(comment),
      'totalWorkMs': serializer.toJson<int>(totalWorkMs),
      'totalBreakMs': serializer.toJson<int>(totalBreakMs),
      'confirmed': serializer.toJson<bool>(confirmed),
    };
  }

  CompletionRow copyWith({
    String? id,
    String? taskId,
    String? workerId,
    DateTime? completedAt,
    Value<String?> completionLocationCheckId = const Value.absent(),
    Value<String?> comment = const Value.absent(),
    int? totalWorkMs,
    int? totalBreakMs,
    bool? confirmed,
  }) => CompletionRow(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    workerId: workerId ?? this.workerId,
    completedAt: completedAt ?? this.completedAt,
    completionLocationCheckId: completionLocationCheckId.present
        ? completionLocationCheckId.value
        : this.completionLocationCheckId,
    comment: comment.present ? comment.value : this.comment,
    totalWorkMs: totalWorkMs ?? this.totalWorkMs,
    totalBreakMs: totalBreakMs ?? this.totalBreakMs,
    confirmed: confirmed ?? this.confirmed,
  );
  CompletionRow copyWithCompanion(CompletionsCompanion data) {
    return CompletionRow(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      workerId: data.workerId.present ? data.workerId.value : this.workerId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      completionLocationCheckId: data.completionLocationCheckId.present
          ? data.completionLocationCheckId.value
          : this.completionLocationCheckId,
      comment: data.comment.present ? data.comment.value : this.comment,
      totalWorkMs: data.totalWorkMs.present
          ? data.totalWorkMs.value
          : this.totalWorkMs,
      totalBreakMs: data.totalBreakMs.present
          ? data.totalBreakMs.value
          : this.totalBreakMs,
      confirmed: data.confirmed.present ? data.confirmed.value : this.confirmed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompletionRow(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('workerId: $workerId, ')
          ..write('completedAt: $completedAt, ')
          ..write('completionLocationCheckId: $completionLocationCheckId, ')
          ..write('comment: $comment, ')
          ..write('totalWorkMs: $totalWorkMs, ')
          ..write('totalBreakMs: $totalBreakMs, ')
          ..write('confirmed: $confirmed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    workerId,
    completedAt,
    completionLocationCheckId,
    comment,
    totalWorkMs,
    totalBreakMs,
    confirmed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletionRow &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.workerId == this.workerId &&
          other.completedAt == this.completedAt &&
          other.completionLocationCheckId == this.completionLocationCheckId &&
          other.comment == this.comment &&
          other.totalWorkMs == this.totalWorkMs &&
          other.totalBreakMs == this.totalBreakMs &&
          other.confirmed == this.confirmed);
}

class CompletionsCompanion extends UpdateCompanion<CompletionRow> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> workerId;
  final Value<DateTime> completedAt;
  final Value<String?> completionLocationCheckId;
  final Value<String?> comment;
  final Value<int> totalWorkMs;
  final Value<int> totalBreakMs;
  final Value<bool> confirmed;
  final Value<int> rowid;
  const CompletionsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.workerId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.completionLocationCheckId = const Value.absent(),
    this.comment = const Value.absent(),
    this.totalWorkMs = const Value.absent(),
    this.totalBreakMs = const Value.absent(),
    this.confirmed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompletionsCompanion.insert({
    required String id,
    required String taskId,
    required String workerId,
    required DateTime completedAt,
    this.completionLocationCheckId = const Value.absent(),
    this.comment = const Value.absent(),
    required int totalWorkMs,
    required int totalBreakMs,
    this.confirmed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       workerId = Value(workerId),
       completedAt = Value(completedAt),
       totalWorkMs = Value(totalWorkMs),
       totalBreakMs = Value(totalBreakMs);
  static Insertable<CompletionRow> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? workerId,
    Expression<DateTime>? completedAt,
    Expression<String>? completionLocationCheckId,
    Expression<String>? comment,
    Expression<int>? totalWorkMs,
    Expression<int>? totalBreakMs,
    Expression<bool>? confirmed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (workerId != null) 'worker_id': workerId,
      if (completedAt != null) 'completed_at': completedAt,
      if (completionLocationCheckId != null)
        'completion_location_check_id': completionLocationCheckId,
      if (comment != null) 'comment': comment,
      if (totalWorkMs != null) 'total_work_ms': totalWorkMs,
      if (totalBreakMs != null) 'total_break_ms': totalBreakMs,
      if (confirmed != null) 'confirmed': confirmed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompletionsCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String>? workerId,
    Value<DateTime>? completedAt,
    Value<String?>? completionLocationCheckId,
    Value<String?>? comment,
    Value<int>? totalWorkMs,
    Value<int>? totalBreakMs,
    Value<bool>? confirmed,
    Value<int>? rowid,
  }) {
    return CompletionsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      workerId: workerId ?? this.workerId,
      completedAt: completedAt ?? this.completedAt,
      completionLocationCheckId:
          completionLocationCheckId ?? this.completionLocationCheckId,
      comment: comment ?? this.comment,
      totalWorkMs: totalWorkMs ?? this.totalWorkMs,
      totalBreakMs: totalBreakMs ?? this.totalBreakMs,
      confirmed: confirmed ?? this.confirmed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (workerId.present) {
      map['worker_id'] = Variable<String>(workerId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (completionLocationCheckId.present) {
      map['completion_location_check_id'] = Variable<String>(
        completionLocationCheckId.value,
      );
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (totalWorkMs.present) {
      map['total_work_ms'] = Variable<int>(totalWorkMs.value);
    }
    if (totalBreakMs.present) {
      map['total_break_ms'] = Variable<int>(totalBreakMs.value);
    }
    if (confirmed.present) {
      map['confirmed'] = Variable<bool>(confirmed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletionsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('workerId: $workerId, ')
          ..write('completedAt: $completedAt, ')
          ..write('completionLocationCheckId: $completionLocationCheckId, ')
          ..write('comment: $comment, ')
          ..write('totalWorkMs: $totalWorkMs, ')
          ..write('totalBreakMs: $totalBreakMs, ')
          ..write('confirmed: $confirmed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncItemsTable extends SyncItems
    with TableInfo<$SyncItemsTable, SyncItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMessageMeta = const VerificationMeta(
    'lastErrorMessage',
  );
  @override
  late final GeneratedColumn<String> lastErrorMessage = GeneratedColumn<String>(
    'last_error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    entityType,
    entityId,
    payload,
    state,
    attempts,
    lastErrorCode,
    lastErrorMessage,
    nextAttemptAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    if (data.containsKey('last_error_message')) {
      context.handle(
        _lastErrorMessageMeta,
        lastErrorMessage.isAcceptableOrUnknown(
          data['last_error_message']!,
          _lastErrorMessageMeta,
        ),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
      lastErrorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_message'],
      ),
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncItemsTable createAlias(String alias) {
    return $SyncItemsTable(attachedDatabase, alias);
  }
}

class SyncItemRow extends DataClass implements Insertable<SyncItemRow> {
  final int id;
  final String taskId;
  final String entityType;
  final String entityId;
  final String payload;
  final String state;
  final int attempts;
  final String? lastErrorCode;
  final String? lastErrorMessage;
  final DateTime? nextAttemptAt;
  final DateTime createdAt;
  const SyncItemRow({
    required this.id,
    required this.taskId,
    required this.entityType,
    required this.entityId,
    required this.payload,
    required this.state,
    required this.attempts,
    this.lastErrorCode,
    this.lastErrorMessage,
    this.nextAttemptAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_id'] = Variable<String>(taskId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['payload'] = Variable<String>(payload);
    map['state'] = Variable<String>(state);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    if (!nullToAbsent || lastErrorMessage != null) {
      map['last_error_message'] = Variable<String>(lastErrorMessage);
    }
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncItemsCompanion toCompanion(bool nullToAbsent) {
    return SyncItemsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      payload: Value(payload),
      state: Value(state),
      attempts: Value(attempts),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      lastErrorMessage: lastErrorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorMessage),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      createdAt: Value(createdAt),
    );
  }

  factory SyncItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncItemRow(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      payload: serializer.fromJson<String>(json['payload']),
      state: serializer.fromJson<String>(json['state']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
      lastErrorMessage: serializer.fromJson<String?>(json['lastErrorMessage']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<String>(taskId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'payload': serializer.toJson<String>(payload),
      'state': serializer.toJson<String>(state),
      'attempts': serializer.toJson<int>(attempts),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
      'lastErrorMessage': serializer.toJson<String?>(lastErrorMessage),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncItemRow copyWith({
    int? id,
    String? taskId,
    String? entityType,
    String? entityId,
    String? payload,
    String? state,
    int? attempts,
    Value<String?> lastErrorCode = const Value.absent(),
    Value<String?> lastErrorMessage = const Value.absent(),
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    DateTime? createdAt,
  }) => SyncItemRow(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    payload: payload ?? this.payload,
    state: state ?? this.state,
    attempts: attempts ?? this.attempts,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
    lastErrorMessage: lastErrorMessage.present
        ? lastErrorMessage.value
        : this.lastErrorMessage,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncItemRow copyWithCompanion(SyncItemsCompanion data) {
    return SyncItemRow(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payload: data.payload.present ? data.payload.value : this.payload,
      state: data.state.present ? data.state.value : this.state,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      lastErrorMessage: data.lastErrorMessage.present
          ? data.lastErrorMessage.value
          : this.lastErrorMessage,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncItemRow(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastErrorMessage: $lastErrorMessage, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    entityType,
    entityId,
    payload,
    state,
    attempts,
    lastErrorCode,
    lastErrorMessage,
    nextAttemptAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncItemRow &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.payload == this.payload &&
          other.state == this.state &&
          other.attempts == this.attempts &&
          other.lastErrorCode == this.lastErrorCode &&
          other.lastErrorMessage == this.lastErrorMessage &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.createdAt == this.createdAt);
}

class SyncItemsCompanion extends UpdateCompanion<SyncItemRow> {
  final Value<int> id;
  final Value<String> taskId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> payload;
  final Value<String> state;
  final Value<int> attempts;
  final Value<String?> lastErrorCode;
  final Value<String?> lastErrorMessage;
  final Value<DateTime?> nextAttemptAt;
  final Value<DateTime> createdAt;
  const SyncItemsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payload = const Value.absent(),
    this.state = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastErrorMessage = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncItemsCompanion.insert({
    this.id = const Value.absent(),
    required String taskId,
    required String entityType,
    required String entityId,
    required String payload,
    required String state,
    this.attempts = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastErrorMessage = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    required DateTime createdAt,
  }) : taskId = Value(taskId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       payload = Value(payload),
       state = Value(state),
       createdAt = Value(createdAt);
  static Insertable<SyncItemRow> custom({
    Expression<int>? id,
    Expression<String>? taskId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? payload,
    Expression<String>? state,
    Expression<int>? attempts,
    Expression<String>? lastErrorCode,
    Expression<String>? lastErrorMessage,
    Expression<DateTime>? nextAttemptAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (payload != null) 'payload': payload,
      if (state != null) 'state': state,
      if (attempts != null) 'attempts': attempts,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (lastErrorMessage != null) 'last_error_message': lastErrorMessage,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? taskId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? payload,
    Value<String>? state,
    Value<int>? attempts,
    Value<String?>? lastErrorCode,
    Value<String?>? lastErrorMessage,
    Value<DateTime?>? nextAttemptAt,
    Value<DateTime>? createdAt,
  }) {
    return SyncItemsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      state: state ?? this.state,
      attempts: attempts ?? this.attempts,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (lastErrorMessage.present) {
      map['last_error_message'] = Variable<String>(lastErrorMessage.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncItemsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastErrorMessage: $lastErrorMessage, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedTasksTable cachedTasks = $CachedTasksTable(this);
  late final $TimeEntriesTable timeEntries = $TimeEntriesTable(this);
  late final $LocationChecksTable locationChecks = $LocationChecksTable(this);
  late final $PhotosTable photos = $PhotosTable(this);
  late final $MaterialsTable materials = $MaterialsTable(this);
  late final $CompletionsTable completions = $CompletionsTable(this);
  late final $SyncItemsTable syncItems = $SyncItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedTasks,
    timeEntries,
    locationChecks,
    photos,
    materials,
    completions,
    syncItems,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$CachedTasksTableCreateCompanionBuilder =
    CachedTasksCompanion Function({
      required String id,
      required DateTime scheduledStart,
      required String payload,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CachedTasksTableUpdateCompanionBuilder =
    CachedTasksCompanion Function({
      Value<String> id,
      Value<DateTime> scheduledStart,
      Value<String> payload,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CachedTasksTableFilterComposer
    extends Composer<_$AppDatabase, $CachedTasksTable> {
  $$CachedTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledStart => $composableBuilder(
    column: $table.scheduledStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedTasksTable> {
  $$CachedTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledStart => $composableBuilder(
    column: $table.scheduledStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedTasksTable> {
  $$CachedTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledStart => $composableBuilder(
    column: $table.scheduledStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CachedTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedTasksTable,
          CachedTaskRow,
          $$CachedTasksTableFilterComposer,
          $$CachedTasksTableOrderingComposer,
          $$CachedTasksTableAnnotationComposer,
          $$CachedTasksTableCreateCompanionBuilder,
          $$CachedTasksTableUpdateCompanionBuilder,
          (
            CachedTaskRow,
            BaseReferences<_$AppDatabase, $CachedTasksTable, CachedTaskRow>,
          ),
          CachedTaskRow,
          PrefetchHooks Function()
        > {
  $$CachedTasksTableTableManager(_$AppDatabase db, $CachedTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> scheduledStart = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedTasksCompanion(
                id: id,
                scheduledStart: scheduledStart,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime scheduledStart,
                required String payload,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedTasksCompanion.insert(
                id: id,
                scheduledStart: scheduledStart,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedTasksTable, CachedTaskRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CachedTasksTable,
                    CachedTaskRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedTasksTable,
      CachedTaskRow,
      $$CachedTasksTableFilterComposer,
      $$CachedTasksTableOrderingComposer,
      $$CachedTasksTableAnnotationComposer,
      $$CachedTasksTableCreateCompanionBuilder,
      $$CachedTasksTableUpdateCompanionBuilder,
      (
        CachedTaskRow,
        BaseReferences<_$AppDatabase, $CachedTasksTable, CachedTaskRow>,
      ),
      CachedTaskRow,
      PrefetchHooks Function()
    >;
typedef $$TimeEntriesTableCreateCompanionBuilder =
    TimeEntriesCompanion Function({
      required String id,
      required String taskId,
      required String kind,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<String?> startLocationCheckId,
      Value<int> rowid,
    });
typedef $$TimeEntriesTableUpdateCompanionBuilder =
    TimeEntriesCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<String> kind,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<String?> startLocationCheckId,
      Value<int> rowid,
    });

class $$TimeEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TimeEntriesTable> {
  $$TimeEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startLocationCheckId => $composableBuilder(
    column: $table.startLocationCheckId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimeEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TimeEntriesTable> {
  $$TimeEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startLocationCheckId => $composableBuilder(
    column: $table.startLocationCheckId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimeEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimeEntriesTable> {
  $$TimeEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get startLocationCheckId => $composableBuilder(
    column: $table.startLocationCheckId,
    builder: (column) => column,
  );
}

class $$TimeEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimeEntriesTable,
          TimeEntryRow,
          $$TimeEntriesTableFilterComposer,
          $$TimeEntriesTableOrderingComposer,
          $$TimeEntriesTableAnnotationComposer,
          $$TimeEntriesTableCreateCompanionBuilder,
          $$TimeEntriesTableUpdateCompanionBuilder,
          (
            TimeEntryRow,
            BaseReferences<_$AppDatabase, $TimeEntriesTable, TimeEntryRow>,
          ),
          TimeEntryRow,
          PrefetchHooks Function()
        > {
  $$TimeEntriesTableTableManager(_$AppDatabase db, $TimeEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimeEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimeEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimeEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> startLocationCheckId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimeEntriesCompanion(
                id: id,
                taskId: taskId,
                kind: kind,
                startedAt: startedAt,
                endedAt: endedAt,
                startLocationCheckId: startLocationCheckId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required String kind,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> startLocationCheckId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimeEntriesCompanion.insert(
                id: id,
                taskId: taskId,
                kind: kind,
                startedAt: startedAt,
                endedAt: endedAt,
                startLocationCheckId: startLocationCheckId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TimeEntriesTable, TimeEntryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TimeEntriesTable,
                    TimeEntryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimeEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimeEntriesTable,
      TimeEntryRow,
      $$TimeEntriesTableFilterComposer,
      $$TimeEntriesTableOrderingComposer,
      $$TimeEntriesTableAnnotationComposer,
      $$TimeEntriesTableCreateCompanionBuilder,
      $$TimeEntriesTableUpdateCompanionBuilder,
      (
        TimeEntryRow,
        BaseReferences<_$AppDatabase, $TimeEntriesTable, TimeEntryRow>,
      ),
      TimeEntryRow,
      PrefetchHooks Function()
    >;
typedef $$LocationChecksTableCreateCompanionBuilder =
    LocationChecksCompanion Function({
      required String id,
      required String taskId,
      required String purpose,
      required double latitude,
      required double longitude,
      required double accuracyM,
      required bool isMocked,
      required DateTime capturedAt,
      required double distanceM,
      required double radiusM,
      required bool verified,
      Value<int> rowid,
    });
typedef $$LocationChecksTableUpdateCompanionBuilder =
    LocationChecksCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<String> purpose,
      Value<double> latitude,
      Value<double> longitude,
      Value<double> accuracyM,
      Value<bool> isMocked,
      Value<DateTime> capturedAt,
      Value<double> distanceM,
      Value<double> radiusM,
      Value<bool> verified,
      Value<int> rowid,
    });

class $$LocationChecksTableFilterComposer
    extends Composer<_$AppDatabase, $LocationChecksTable> {
  $$LocationChecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMocked => $composableBuilder(
    column: $table.isMocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get radiusM => $composableBuilder(
    column: $table.radiusM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get verified => $composableBuilder(
    column: $table.verified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocationChecksTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationChecksTable> {
  $$LocationChecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMocked => $composableBuilder(
    column: $table.isMocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get radiusM => $composableBuilder(
    column: $table.radiusM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get verified => $composableBuilder(
    column: $table.verified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocationChecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationChecksTable> {
  $$LocationChecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => column);

  GeneratedColumn<bool> get isMocked =>
      $composableBuilder(column: $table.isMocked, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => column);

  GeneratedColumn<double> get radiusM =>
      $composableBuilder(column: $table.radiusM, builder: (column) => column);

  GeneratedColumn<bool> get verified =>
      $composableBuilder(column: $table.verified, builder: (column) => column);
}

class $$LocationChecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationChecksTable,
          LocationCheckRow,
          $$LocationChecksTableFilterComposer,
          $$LocationChecksTableOrderingComposer,
          $$LocationChecksTableAnnotationComposer,
          $$LocationChecksTableCreateCompanionBuilder,
          $$LocationChecksTableUpdateCompanionBuilder,
          (
            LocationCheckRow,
            BaseReferences<
              _$AppDatabase,
              $LocationChecksTable,
              LocationCheckRow
            >,
          ),
          LocationCheckRow,
          PrefetchHooks Function()
        > {
  $$LocationChecksTableTableManager(
    _$AppDatabase db,
    $LocationChecksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationChecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationChecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationChecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> purpose = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double> accuracyM = const Value.absent(),
                Value<bool> isMocked = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<double> distanceM = const Value.absent(),
                Value<double> radiusM = const Value.absent(),
                Value<bool> verified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationChecksCompanion(
                id: id,
                taskId: taskId,
                purpose: purpose,
                latitude: latitude,
                longitude: longitude,
                accuracyM: accuracyM,
                isMocked: isMocked,
                capturedAt: capturedAt,
                distanceM: distanceM,
                radiusM: radiusM,
                verified: verified,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required String purpose,
                required double latitude,
                required double longitude,
                required double accuracyM,
                required bool isMocked,
                required DateTime capturedAt,
                required double distanceM,
                required double radiusM,
                required bool verified,
                Value<int> rowid = const Value.absent(),
              }) => LocationChecksCompanion.insert(
                id: id,
                taskId: taskId,
                purpose: purpose,
                latitude: latitude,
                longitude: longitude,
                accuracyM: accuracyM,
                isMocked: isMocked,
                capturedAt: capturedAt,
                distanceM: distanceM,
                radiusM: radiusM,
                verified: verified,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocationChecksTable, LocationCheckRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocationChecksTable,
                    LocationCheckRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocationChecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationChecksTable,
      LocationCheckRow,
      $$LocationChecksTableFilterComposer,
      $$LocationChecksTableOrderingComposer,
      $$LocationChecksTableAnnotationComposer,
      $$LocationChecksTableCreateCompanionBuilder,
      $$LocationChecksTableUpdateCompanionBuilder,
      (
        LocationCheckRow,
        BaseReferences<_$AppDatabase, $LocationChecksTable, LocationCheckRow>,
      ),
      LocationCheckRow,
      PrefetchHooks Function()
    >;
typedef $$PhotosTableCreateCompanionBuilder = PhotosCompanion Function({
  required String id,
  required String taskId,
  Value<String?> localPath,
  required String kind,
  required DateTime takenAt,
  Value<double?> latitude,
  Value<double?> longitude,
  required String uploadState,
  Value<double> progress,
  Value<String?> lastError,
  Value<int> rowid,
});
typedef $$PhotosTableUpdateCompanionBuilder = PhotosCompanion Function({
  Value<String> id,
  Value<String> taskId,
  Value<String?> localPath,
  Value<String> kind,
  Value<DateTime> takenAt,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String> uploadState,
  Value<double> progress,
  Value<String?> lastError,
  Value<int> rowid,
});

class $$PhotosTableFilterComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uploadState => $composableBuilder(
    column: $table.uploadState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uploadState => $composableBuilder(
    column: $table.uploadState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get uploadState => $composableBuilder(
    column: $table.uploadState,
    builder: (column) => column,
  );

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$PhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotosTable,
          PhotoRow,
          $$PhotosTableFilterComposer,
          $$PhotosTableOrderingComposer,
          $$PhotosTableAnnotationComposer,
          $$PhotosTableCreateCompanionBuilder,
          $$PhotosTableUpdateCompanionBuilder,
          (PhotoRow, BaseReferences<_$AppDatabase, $PhotosTable, PhotoRow>),
          PhotoRow,
          PrefetchHooks Function()
        > {
  $$PhotosTableTableManager(_$AppDatabase db, $PhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String> uploadState = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion(
                id: id,
                taskId: taskId,
                localPath: localPath,
                kind: kind,
                takenAt: takenAt,
                latitude: latitude,
                longitude: longitude,
                uploadState: uploadState,
                progress: progress,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                Value<String?> localPath = const Value.absent(),
                required String kind,
                required DateTime takenAt,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                required String uploadState,
                Value<double> progress = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion.insert(
                id: id,
                taskId: taskId,
                localPath: localPath,
                kind: kind,
                takenAt: takenAt,
                latitude: latitude,
                longitude: longitude,
                uploadState: uploadState,
                progress: progress,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhotosTable, PhotoRow>(table),
                  BaseReferences<_$AppDatabase, $PhotosTable, PhotoRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotosTable,
      PhotoRow,
      $$PhotosTableFilterComposer,
      $$PhotosTableOrderingComposer,
      $$PhotosTableAnnotationComposer,
      $$PhotosTableCreateCompanionBuilder,
      $$PhotosTableUpdateCompanionBuilder,
      (PhotoRow, BaseReferences<_$AppDatabase, $PhotosTable, PhotoRow>),
      PhotoRow,
      PrefetchHooks Function()
    >;
typedef $$MaterialsTableCreateCompanionBuilder = MaterialsCompanion Function({
  required String id,
  required String taskId,
  required String catalogItemId,
  required String itemName,
  required String unit,
  required double quantity,
  required String movement,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$MaterialsTableUpdateCompanionBuilder = MaterialsCompanion Function({
  Value<String> id,
  Value<String> taskId,
  Value<String> catalogItemId,
  Value<String> itemName,
  Value<String> unit,
  Value<double> quantity,
  Value<String> movement,
  Value<String?> note,
  Value<int> rowid,
});

class $$MaterialsTableFilterComposer
    extends Composer<_$AppDatabase, $MaterialsTable> {
  $$MaterialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogItemId => $composableBuilder(
    column: $table.catalogItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movement => $composableBuilder(
    column: $table.movement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MaterialsTableOrderingComposer
    extends Composer<_$AppDatabase, $MaterialsTable> {
  $$MaterialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogItemId => $composableBuilder(
    column: $table.catalogItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movement => $composableBuilder(
    column: $table.movement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MaterialsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaterialsTable> {
  $$MaterialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get catalogItemId => $composableBuilder(
    column: $table.catalogItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get movement =>
      $composableBuilder(column: $table.movement, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$MaterialsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaterialsTable,
          MaterialRow,
          $$MaterialsTableFilterComposer,
          $$MaterialsTableOrderingComposer,
          $$MaterialsTableAnnotationComposer,
          $$MaterialsTableCreateCompanionBuilder,
          $$MaterialsTableUpdateCompanionBuilder,
          (
            MaterialRow,
            BaseReferences<_$AppDatabase, $MaterialsTable, MaterialRow>,
          ),
          MaterialRow,
          PrefetchHooks Function()
        > {
  $$MaterialsTableTableManager(_$AppDatabase db, $MaterialsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaterialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaterialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaterialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> catalogItemId = const Value.absent(),
                Value<String> itemName = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> movement = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaterialsCompanion(
                id: id,
                taskId: taskId,
                catalogItemId: catalogItemId,
                itemName: itemName,
                unit: unit,
                quantity: quantity,
                movement: movement,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required String catalogItemId,
                required String itemName,
                required String unit,
                required double quantity,
                required String movement,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaterialsCompanion.insert(
                id: id,
                taskId: taskId,
                catalogItemId: catalogItemId,
                itemName: itemName,
                unit: unit,
                quantity: quantity,
                movement: movement,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MaterialsTable, MaterialRow>(table),
                  BaseReferences<_$AppDatabase, $MaterialsTable, MaterialRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MaterialsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaterialsTable,
      MaterialRow,
      $$MaterialsTableFilterComposer,
      $$MaterialsTableOrderingComposer,
      $$MaterialsTableAnnotationComposer,
      $$MaterialsTableCreateCompanionBuilder,
      $$MaterialsTableUpdateCompanionBuilder,
      (
        MaterialRow,
        BaseReferences<_$AppDatabase, $MaterialsTable, MaterialRow>,
      ),
      MaterialRow,
      PrefetchHooks Function()
    >;
typedef $$CompletionsTableCreateCompanionBuilder =
    CompletionsCompanion Function({
      required String id,
      required String taskId,
      required String workerId,
      required DateTime completedAt,
      Value<String?> completionLocationCheckId,
      Value<String?> comment,
      required int totalWorkMs,
      required int totalBreakMs,
      Value<bool> confirmed,
      Value<int> rowid,
    });
typedef $$CompletionsTableUpdateCompanionBuilder =
    CompletionsCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<String> workerId,
      Value<DateTime> completedAt,
      Value<String?> completionLocationCheckId,
      Value<String?> comment,
      Value<int> totalWorkMs,
      Value<int> totalBreakMs,
      Value<bool> confirmed,
      Value<int> rowid,
    });

class $$CompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $CompletionsTable> {
  $$CompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workerId => $composableBuilder(
    column: $table.workerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completionLocationCheckId => $composableBuilder(
    column: $table.completionLocationCheckId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalWorkMs => $composableBuilder(
    column: $table.totalWorkMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBreakMs => $composableBuilder(
    column: $table.totalBreakMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get confirmed => $composableBuilder(
    column: $table.confirmed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CompletionsTable> {
  $$CompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workerId => $composableBuilder(
    column: $table.workerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completionLocationCheckId => $composableBuilder(
    column: $table.completionLocationCheckId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalWorkMs => $composableBuilder(
    column: $table.totalWorkMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBreakMs => $composableBuilder(
    column: $table.totalBreakMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get confirmed => $composableBuilder(
    column: $table.confirmed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompletionsTable> {
  $$CompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get workerId =>
      $composableBuilder(column: $table.workerId, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get completionLocationCheckId => $composableBuilder(
    column: $table.completionLocationCheckId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<int> get totalWorkMs => $composableBuilder(
    column: $table.totalWorkMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalBreakMs => $composableBuilder(
    column: $table.totalBreakMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get confirmed =>
      $composableBuilder(column: $table.confirmed, builder: (column) => column);
}

class $$CompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompletionsTable,
          CompletionRow,
          $$CompletionsTableFilterComposer,
          $$CompletionsTableOrderingComposer,
          $$CompletionsTableAnnotationComposer,
          $$CompletionsTableCreateCompanionBuilder,
          $$CompletionsTableUpdateCompanionBuilder,
          (
            CompletionRow,
            BaseReferences<_$AppDatabase, $CompletionsTable, CompletionRow>,
          ),
          CompletionRow,
          PrefetchHooks Function()
        > {
  $$CompletionsTableTableManager(_$AppDatabase db, $CompletionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> workerId = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<String?> completionLocationCheckId = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<int> totalWorkMs = const Value.absent(),
                Value<int> totalBreakMs = const Value.absent(),
                Value<bool> confirmed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletionsCompanion(
                id: id,
                taskId: taskId,
                workerId: workerId,
                completedAt: completedAt,
                completionLocationCheckId: completionLocationCheckId,
                comment: comment,
                totalWorkMs: totalWorkMs,
                totalBreakMs: totalBreakMs,
                confirmed: confirmed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required String workerId,
                required DateTime completedAt,
                Value<String?> completionLocationCheckId = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                required int totalWorkMs,
                required int totalBreakMs,
                Value<bool> confirmed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletionsCompanion.insert(
                id: id,
                taskId: taskId,
                workerId: workerId,
                completedAt: completedAt,
                completionLocationCheckId: completionLocationCheckId,
                comment: comment,
                totalWorkMs: totalWorkMs,
                totalBreakMs: totalBreakMs,
                confirmed: confirmed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompletionsTable, CompletionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CompletionsTable,
                    CompletionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompletionsTable,
      CompletionRow,
      $$CompletionsTableFilterComposer,
      $$CompletionsTableOrderingComposer,
      $$CompletionsTableAnnotationComposer,
      $$CompletionsTableCreateCompanionBuilder,
      $$CompletionsTableUpdateCompanionBuilder,
      (
        CompletionRow,
        BaseReferences<_$AppDatabase, $CompletionsTable, CompletionRow>,
      ),
      CompletionRow,
      PrefetchHooks Function()
    >;
typedef $$SyncItemsTableCreateCompanionBuilder = SyncItemsCompanion Function({
  Value<int> id,
  required String taskId,
  required String entityType,
  required String entityId,
  required String payload,
  required String state,
  Value<int> attempts,
  Value<String?> lastErrorCode,
  Value<String?> lastErrorMessage,
  Value<DateTime?> nextAttemptAt,
  required DateTime createdAt,
});
typedef $$SyncItemsTableUpdateCompanionBuilder = SyncItemsCompanion Function({
  Value<int> id,
  Value<String> taskId,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> payload,
  Value<String> state,
  Value<int> attempts,
  Value<String?> lastErrorCode,
  Value<String?> lastErrorMessage,
  Value<DateTime?> nextAttemptAt,
  Value<DateTime> createdAt,
});

class $$SyncItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncItemsTable> {
  $$SyncItemsTableFilterComposer({
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

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorMessage => $composableBuilder(
    column: $table.lastErrorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncItemsTable> {
  $$SyncItemsTableOrderingComposer({
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

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorMessage => $composableBuilder(
    column: $table.lastErrorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncItemsTable> {
  $$SyncItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorMessage => $composableBuilder(
    column: $table.lastErrorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncItemsTable,
          SyncItemRow,
          $$SyncItemsTableFilterComposer,
          $$SyncItemsTableOrderingComposer,
          $$SyncItemsTableAnnotationComposer,
          $$SyncItemsTableCreateCompanionBuilder,
          $$SyncItemsTableUpdateCompanionBuilder,
          (
            SyncItemRow,
            BaseReferences<_$AppDatabase, $SyncItemsTable, SyncItemRow>,
          ),
          SyncItemRow,
          PrefetchHooks Function()
        > {
  $$SyncItemsTableTableManager(_$AppDatabase db, $SyncItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String?> lastErrorMessage = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncItemsCompanion(
                id: id,
                taskId: taskId,
                entityType: entityType,
                entityId: entityId,
                payload: payload,
                state: state,
                attempts: attempts,
                lastErrorCode: lastErrorCode,
                lastErrorMessage: lastErrorMessage,
                nextAttemptAt: nextAttemptAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String taskId,
                required String entityType,
                required String entityId,
                required String payload,
                required String state,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String?> lastErrorMessage = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                required DateTime createdAt,
              }) => SyncItemsCompanion.insert(
                id: id,
                taskId: taskId,
                entityType: entityType,
                entityId: entityId,
                payload: payload,
                state: state,
                attempts: attempts,
                lastErrorCode: lastErrorCode,
                lastErrorMessage: lastErrorMessage,
                nextAttemptAt: nextAttemptAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncItemsTable, SyncItemRow>(table),
                  BaseReferences<_$AppDatabase, $SyncItemsTable, SyncItemRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncItemsTable,
      SyncItemRow,
      $$SyncItemsTableFilterComposer,
      $$SyncItemsTableOrderingComposer,
      $$SyncItemsTableAnnotationComposer,
      $$SyncItemsTableCreateCompanionBuilder,
      $$SyncItemsTableUpdateCompanionBuilder,
      (
        SyncItemRow,
        BaseReferences<_$AppDatabase, $SyncItemsTable, SyncItemRow>,
      ),
      SyncItemRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedTasksTableTableManager get cachedTasks =>
      $$CachedTasksTableTableManager(_db, _db.cachedTasks);
  $$TimeEntriesTableTableManager get timeEntries =>
      $$TimeEntriesTableTableManager(_db, _db.timeEntries);
  $$LocationChecksTableTableManager get locationChecks =>
      $$LocationChecksTableTableManager(_db, _db.locationChecks);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
  $$MaterialsTableTableManager get materials =>
      $$MaterialsTableTableManager(_db, _db.materials);
  $$CompletionsTableTableManager get completions =>
      $$CompletionsTableTableManager(_db, _db.completions);
  $$SyncItemsTableTableManager get syncItems =>
      $$SyncItemsTableTableManager(_db, _db.syncItems);
}
