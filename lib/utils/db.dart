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
        onOpen: config.onOpen,
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
