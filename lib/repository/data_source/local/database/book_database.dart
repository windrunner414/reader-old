import 'package:floor/floor.dart';
import 'package:reader/model/reading_progress.dart';
import '../dao/reading_progress_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import 'dart:async';

part 'book_database.g.dart';

@Database(version: 1, entities: [ReadingProgress])
abstract class BookDatabase extends FloorDatabase {
  static Future<BookDatabase> openDatabase() async => _$open();

  ReadingProgressDao get readingProgressDao;
}
