import 'package:floor/floor.dart';
import 'package:reader/model/reading_progress.dart';
import '../dao/reading_progress_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';
import 'package:path/path.dart';

part 'book_database.g.dart';

@Database(version: 1, entities: [ReadingProgress])
abstract class BookDatabase extends FloorDatabase {
  ReadingProgressDao get readingProgressDao;
}
