import 'di.dart';
import 'package:reader/repository/data_source/local/database/book_database.dart';
import 'package:reader/repository/data_source/local/dao/reading_progress_dao.dart';
import 'package:reader/repository/data_source/book_data_source.dart';
import 'package:reader/repository/data_source/local/local_book_data_source.dart';
import 'package:reader/repository/data_source/remote/remote_book_data_source.dart';
import 'package:reader/repository/book_repository.dart';
import 'package:reader/repository/book_repository_impl.dart';

Future<List<Module>> appModule() async {
  var bookDatabase = await BookDatabase.openDatabase();

  final daoModule = Module([
    single<ReadingProgressDao>(bookDatabase.readingProgressDao),
  ]);

  final dataSourceModule = Module([])
    ..withScope(local, [
      lazy<BookDataSource>(({params}) => LocalBookDataSource()),
    ])
    ..withScope(remote, [
      lazy<BookDataSource>(({params}) => RemoteBookDataSource()),
    ]);

  final repositoryModule = Module([
    lazy<BookRepository>(({params}) => BookRepositoryImpl()),
  ]);

  return [daoModule, dataSourceModule, repositoryModule];
}
