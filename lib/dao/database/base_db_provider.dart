import 'package:sqflite/sqflite.dart';
import 'dart:async' show FutureOr;

export 'package:sqflite/sqflite.dart';

abstract class BaseDBProvider {
  String get dbName;
  String get tableName;
  int get version;

  FutureOr<void> onConfigure(Database db) async {

  }

  FutureOr<void> onCreate(Database db, int version);

  FutureOr<void> onUpgrade(Database db, int oldVersion, int newVersion) async {

  }

  FutureOr<void> onDowngrade(Database db, int oldVersion, int newVersion) async {

  }

  FutureOr<void> onOpen(Database db) async {

  }

  bool get readOnly => false;
  bool get _singleInstance => true;

  Future<Database> get database async {
    return await openDatabase(
      '${await getDatabasesPath()}/$dbName.db',
      version: version,
      onConfigure: onConfigure,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
      onDowngrade: onDowngrade,
      onOpen: (Database db) async {
        var result = await db.rawQuery('select * from sqlite_master where type = ? and name = ?', ['table', tableName]);
        if (result.length == 0) {
          await onCreate(db, version);
        }
        await onOpen(db);
      },
      readOnly: readOnly,
      singleInstance: _singleInstance,
    );
  }

  Future<void> execute(String sql, [List<dynamic> arguments]) async
    => (await database).execute(sql, arguments);

  Future<List<Map<String, dynamic>>> query(String sql, [List<dynamic> arguments]) async
    => (await database).rawQuery(sql, arguments);
}
