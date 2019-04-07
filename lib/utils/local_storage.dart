import 'package:sqflite/sqflite.dart';

export 'package:sqflite/sqflite.dart';

Map<String, Map<String, dynamic>> dbInfo = {
  'reading_progress': {
    'fileName': 'reading_progress.db',
    'tableName': 'reading_progress',
    'version': 1,
    'initSQL': '''
      CREATE TABLE reading_progress (
        bookId TEXT PRIMARY KEY,
        chapterIndex INTEGER,
        pageIndex INTEGER
      )
    ''',
  },
  'preferences': {
    'fileName': 'preferences.db',
    'tableName': 'preferences',
    'version': 1,
    'initSQL': '''
      CREATE TABLE preferences (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''',
  },
};

class DB {
  final String fileName;
  final String tableName;

  Database _database;
  Database get database => _database;
  set database(Database db) {
    if (_database == null) {
      _database = db;
    } else {
      throw Exception("database has been initialized");
    }
  }

  DB({this.fileName, this.tableName});

  static Map<String, DB> _instances = {};

  static Future<DB> getInstance(String name) async {
    try {
      if (_instances[name] != null) {
        return _instances[name];
      }

      var _dbInfo = dbInfo[name];
      DB db = DB(fileName: _dbInfo['fileName'], tableName: _dbInfo['tableName']);
      String path = '${await getDatabasesPath()}/${db.fileName}';
      db.database = await openDatabase(
        path,
        version: _dbInfo['version'],
        onCreate: (Database db, int version) async {
          await db.execute(_dbInfo['initSQL']);
        }
      );

      _instances[name] = db;
      return db;
    } catch (_) {
      return null;
    }
  }
}
