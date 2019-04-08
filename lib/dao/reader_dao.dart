import 'package:reader/dao/base_dao.dart';
import 'package:reader/dao/data_result.dart';
import 'package:reader/model/reading_progress.dart';
import 'package:reader/model/reader_preferences.dart';
import 'package:reader/dao/database/reading_progress_db_provider.dart';
import 'package:reader/dao/database/preferences_db_provider.dart';
import 'package:reader/utils/task_cancel_token.dart';
import 'dart:convert';

class ReaderDao extends BaseDao {
  ReaderDao({TaskCancelToken cancelToken}) : super(cancelToken: cancelToken);

  Future<DataResult> getReadingProgress(String bookId) async {
    try {
      var db = ReadingProgressDBProvider();
      var result = await db.query('SELECT * FROM ${db.tableName} WHERE bookId = ?', [bookId]);
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
      var db = ReadingProgressDBProvider();
      await db.execute(
        'REPLACE INTO ${db.tableName}(bookId, chapterIndex, pageIndex) VALUES(?, ?, ?)',
        [progress.bookId, progress.chapterIndex, progress.pageIndex],
      );
      return OPERATION_SUCCESS;
    } catch (_) {
      return DATABASE_UPDATE_FAILED;
    }
  }

  Future<DataResult> getPreferences() async {
    try {
      var db = PreferencesDBProvider();
      var result = await db.query('SELECT value FROM ${db.tableName} WHERE key = ?', ['reader']);
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
      var db = PreferencesDBProvider();
      await db.execute(
        'REPLACE INTO ${db.tableName}(key, value) VALUES(?, ?)',
        ['reader', json.encode(preferences)],
      );
      return OPERATION_SUCCESS;
    } catch (_) {
      return DATABASE_UPDATE_FAILED;
    }
  }
}
