import 'package:reader/dao/database/base_db_provider.dart';

class PreferencesDBProvider extends BaseDBProvider {
  @override
  String get dbName => 'preferences';

  @override
  String get tableName => 'preferences';

  @override
  int get version => 1;

  @override
  Future<void> onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }
}
