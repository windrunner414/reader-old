import 'package:lpinyin/lpinyin.dart';

class ZHUtil {
  static String convertToTraditional(String content) => ChineseHelper.convertToTraditionalChinese(content);

  static String convertToSimplified(String content) => ChineseHelper.convertToSimplifiedChinese(content);
}
