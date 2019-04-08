import 'package:sqflite/sqflite.dart';
import 'package:reader/config/db_config.dart';

export 'package:sqflite/sqflite.dart';
export 'package:reader/config/db_config.dart';

class DB {
  final DBConfig config;
  final Database database;

  DB._({this.config, this.database});

  static Map<Databases, DB> _instances = {};

  static Future<DB> getInstance(Databases db) async {
    try {
      var config = DBConfig.databases[db];
      if (config.singleInstance != false && _instances[db] != null) {
        return _instances[db];
      }

      String path = '${await getDatabasesPath()}/${config.fileName}';
      var database = await openDatabase(
        path,
        version: config.version,
        onConfigure: config.onConfigure,
        onCreate: config.onCreate,
        onUpgrade: config.onUpgrade,
        onDowngrade: config.onDowngrade,
        onOpen: (Database _db) async {
          var result = await _db.rawQuery('select * from sqlite_master where type = ? and name = ?', ['table', config.tableName]);
          if (result.length == 0) {
            await config.onCreate(_db, config.version);
          }
          await config.onOpen(_db);
        },
        readOnly: config.readOnly,
        singleInstance: config.singleInstance,
      );

      DB _db = DB._(
        config: config,
        database: database,
      );
      if (config.singleInstance != false) _instances[db] = _db;
      return _db;
    } catch (_) {
      return null;
    }
  }
}
