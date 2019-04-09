import 'package:reader/dao/database/base_db_provider.dart';

class ReadingProgressDBProvider extends BaseDBProvider {
  @override
  String get dbName => 'reading_progress';

  @override
  String get tableName => 'reading_progress';

  @override
  int get version => 1;

  @override
  Future<void> onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        bookId TEXT PRIMARY KEY,
        chapterIndex INTEGER,
        pageIndex INTEGER
      )
    ''');
  }
}
