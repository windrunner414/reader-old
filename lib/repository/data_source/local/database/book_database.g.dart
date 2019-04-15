// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorBookDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$BookDatabaseBuilder databaseBuilder(String name) =>
      _$BookDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$BookDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$BookDatabaseBuilder(null);
}

class _$BookDatabaseBuilder {
  _$BookDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  /// Adds migrations to the builder.
  _$BookDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Creates the database and initializes it.
  Future<BookDatabase> build() async {
    final database = _$BookDatabase();
    database.database = await database.open(name ?? ':memory:', _migrations);
    return database;
  }
}

class _$BookDatabase extends BookDatabase {
  ReadingProgressDao _readingProgressDaoInstance;

  Future<sqflite.Database> open(String name, List<Migration> migrations) async {
    final path = join(await sqflite.getDatabasesPath(), name);

    return sqflite.openDatabase(
      path,
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onUpgrade: (database, startVersion, endVersion) async {
        MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);
      },
      onCreate: (database, _) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ReadingProgress` (`bookId` TEXT PRIMARY KEY NOT NULL, `chapterIndex` INTEGER, `pageIndex` INTEGER)');
      },
    );
  }

  @override
  ReadingProgressDao get readingProgressDao {
    return _readingProgressDaoInstance ??=
        _$ReadingProgressDao(database, changeListener);
  }
}

class _$ReadingProgressDao extends ReadingProgressDao {
  _$ReadingProgressDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _readingProgressInsertionAdapter = InsertionAdapter(
            database,
            'ReadingProgress',
            (ReadingProgress item) => <String, dynamic>{
                  'bookId': item.bookId,
                  'chapterIndex': item.chapterIndex,
                  'pageIndex': item.pageIndex
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final _readingProgressMapper = (Map<String, dynamic> row) => ReadingProgress(
      row['bookId'] as String,
      row['chapterIndex'] as int,
      row['pageIndex'] as int);

  final InsertionAdapter<ReadingProgress> _readingProgressInsertionAdapter;

  @override
  Future<ReadingProgress> findByBookId(String bookId) async {
    return _queryAdapter.query('select * from ReadingProgress where bookId = ?',
        arguments: <dynamic>[bookId], mapper: _readingProgressMapper);
  }

  @override
  Future<void> save(ReadingProgress readingProgress) async {
    await _readingProgressInsertionAdapter.insert(
        readingProgress, sqflite.ConflictAlgorithm.replace);
  }
}
