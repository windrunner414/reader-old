// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

Future<BookDatabase> _$open([List<Migration> migrations = const []]) async {
  final database = _$BookDatabase();
  database.database = await database.open(migrations);
  return database;
}

class _$BookDatabase extends BookDatabase {
  ReadingProgressDao _readingProgressDaoInstance;

  @override
  Future<sqflite.Database> open(List<Migration> migrations) async {
    final path = join(await sqflite.getDatabasesPath(), 'bookdatabase.db');

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
    return _queryAdapter.query(
        'select * from ReadingProgress where bookId = $bookId',
        _readingProgressMapper);
  }

  @override
  Future<void> save(ReadingProgress readingProgress) async {
    await _readingProgressInsertionAdapter.insert(
        readingProgress, sqflite.ConflictAlgorithm.replace);
  }
}
