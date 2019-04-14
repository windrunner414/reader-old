import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FileUtil {
  FileUtil._();

  static String _appDocDir;
  static String get appDocDir {
    assert((){
      if (_appDocDir == null) {
        return false;
      }
      return true;
    }(), 'FileUtil还未初始化');
    return _appDocDir;
  }

  static Future<void> init() async {
    if (_appDocDir != null) return;
    _appDocDir = (await getApplicationDocumentsDirectory()).path;
  }

  static String joinPath(String part1, String part2)
    => join(part1, part2);
}
