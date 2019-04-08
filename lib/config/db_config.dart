import 'package:sqflite/sqflite.dart';

enum Databases {
  READING_PROGRESS,
  PREFERENCES,
}

class DBConfig {
  static Map<Databases, DBConfig> _databases = {
    Databases.READING_PROGRESS: DBConfig(
      fileName: 'reading_progress.db',
      tableName: 'reading_progress',
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE ${databases[Databases.READING_PROGRESS].tableName} (
            bookId TEXT PRIMARY KEY,
            chapterIndex INTEGER,
            pageIndex INTEGER
          )
        ''');
      },
    ),
    Databases.PREFERENCES: DBConfig(
      fileName: 'preferences.db',
      tableName: 'preferences',
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE ${databases[Databases.PREFERENCES].tableName} (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      },
    ),
  };
  static Map<Databases, DBConfig> get databases => _databases;

  final String fileName;
  final String tableName;
  final int version;
  final OnDatabaseConfigureFn onConfigure;
  final OnDatabaseCreateFn onCreate;
  final OnDatabaseOpenFn onOpen;
  final OnDatabaseVersionChangeFn onUpgrade;
  final OnDatabaseVersionChangeFn onDowngrade;
  final bool readOnly;
  final bool singleInstance;

  const DBConfig({
    this.fileName,
    this.tableName,
    this.version,
    this.onConfigure,
    this.onCreate,
    this.onOpen,
    this.onUpgrade,
    this.onDowngrade,
    this.readOnly,
    this.singleInstance,
  });
}
