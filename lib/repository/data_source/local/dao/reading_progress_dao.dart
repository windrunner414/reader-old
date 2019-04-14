import 'package:reader/model/reading_progress.dart';
import 'package:floor/floor.dart';

@dao
abstract class ReadingProgressDao {
  @Query('select * from ReadingProgress where bookId = :bookId')
  Future<ReadingProgress> findByBookId(String bookId);

  @Insert(onConflict: OnConflictStrategy.REPLACE)
  Future<void> save(ReadingProgress readingProgress);
}
