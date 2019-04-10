import 'package:flutter_opencc/flutter_opencc.dart';

class ZHUtil {
  static Future<String> convertToTraditional(String content) => FlutterOpencc.convert(content, config: OpenccConfig.s2t);

  static Future<String> convertToSimplified(String content) => FlutterOpencc.convert(content, config: OpenccConfig.t2s);
}
