import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nest_worker/core/storage/app_database.dart';

void main() {
  test('local database opens and runs queries (in memory)', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final row = await db.customSelect('SELECT 1 AS one').getSingle();

    expect(row.read<int>('one'), 1);
    expect(db.schemaVersion, 2);
  });
}
