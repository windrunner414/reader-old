import 'package:encrypt/encrypt.dart';
import 'package:reader/config/encrypt_config.dart';

class BookChapterEncrypt {
  static String encrypt(String content) {
    var hash = EncryptConfig.bookChapterHMAC.convert(content.codeUnits);
    var encrypted = EncryptConfig.bookChapterEncrypter.encrypt('${String.fromCharCodes(hash.bytes)}\n$content');
    return String.fromCharCodes(encrypted.bytes);
  }

  static String decrypt(String content) {
    var encrypted = Encrypted(content.codeUnits);
    var decrypted = EncryptConfig.bookChapterEncrypter.decrypt(encrypted);
    var index = decrypted.indexOf('\n');
    if (index == -1) {
      throw Exception();
    }

    var hash = decrypted.substring(0, index);
    var rawContent = decrypted.substring(index + 1);
    var hash2 = EncryptConfig.bookChapterHMAC.convert(rawContent.codeUnits);
    if (hash.codeUnits != hash2.bytes) {
      throw Exception();
    }

    return rawContent;
  }
}
