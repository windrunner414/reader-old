import 'package:reader/dao/base_dao.dart';
import 'package:reader/dao/data_result.dart';
import 'package:reader/model/reading_progress.dart';
import 'package:reader/model/reader_preferences.dart';
import 'package:reader/utils/db.dart';
import 'package:reader/utils/task_cancel_token.dart';
import 'dart:convert';

class ReaderDao extends BaseDao {
  ReaderDao({TaskCancelToken cancelToken}) : super(cancelToken: cancelToken);

  Future<DataResult> getReadingProgress(String bookId) async {
    try {
      var db = await DB.getInstance(Databases.READING_PROGRESS);
      if (db == null) return DATABASE_OPEN_FAILED;

      var result = await db.database.rawQuery('SELECT * FROM ${db.config.tableName} WHERE bookId = ?', [bookId]);
      return DataResult(
        data: result.isEmpty
          ? ReadingProgress.fromJson({'bookId': bookId})
          : ReadingProgress.fromJson(result[0]),
        status: DataResultStatus.SUCCESS,
      );
    } catch (_) {
      return DATABASE_QUERY_FAILED;
    }
  }

  Future<DataResult> saveReadingProgress(ReadingProgress progress) async {
    try {
      var db = await DB.getInstance(Databases.READING_PROGRESS);
      if (db == null) return DATABASE_OPEN_FAILED;

      await db.database.execute(
        'REPLACE INTO ${db.config.tableName}(bookId, chapterIndex, pageIndex) VALUES(?, ?, ?)',
        [progress.bookId, progress.chapterIndex, progress.pageIndex],
      );
      return OPERATION_SUCCESS;
    } catch (_) {
      return DATABASE_UPDATE_FAILED;
    }
  }

  Future<DataResult> getPreferences() async {
    try {
      var db = await DB.getInstance(Databases.PREFERENCES);
      if (db == null) return DATABASE_OPEN_FAILED;

      var result = await db.database.rawQuery('SELECT value FROM ${db.config.tableName} WHERE key = ?', ['reader']);
      return DataResult(
        data: result.isEmpty
          ? ReaderPreferences.fromJson({})
          : ReaderPreferences.fromJson(json.decode(result[0]['value'])),
        status: DataResultStatus.SUCCESS,
      );
    } catch (_) {
      return DATABASE_QUERY_FAILED;
    }
  }

  Future<DataResult> savePreferences(ReaderPreferences preferences) async {
    try {
      var db = await DB.getInstance(Databases.PREFERENCES);
      if (db == null) return DATABASE_OPEN_FAILED;

      await db.database.execute(
        'REPLACE INTO ${db.config.tableName}(key, value) VALUES(?, ?)',
        ['reader', json.encode(preferences)],
      );
      return OPERATION_SUCCESS;
    } catch (_) {
      return DATABASE_UPDATE_FAILED;
    }
  }
}
