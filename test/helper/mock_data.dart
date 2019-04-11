part of 'helper.dart';

String getRandomString(int minLength, {int maxLength, bool chinese = true}) {
  int length = getRandomInt(minLength, maxLength);
  String str = '';
  for (int i = 0; i < length; ++i) {
    switch (getRandomInt(0, chinese ? 2 : 1)) {
      case 0:
        str += getRandomInt(0, 9).toString();
        break;
      case 1:
        int r = getRandomInt(65, 116);
        if (r > 90) r += 6;
        str += String.fromCharCode(r);
        break;
      case 2:
        str += String.fromCharCode(getRandomInt(0x4e00, 0x9fa5));
        break;
      default:
        assert(false);
    }
  }
  return str;
}
