import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';

class EncryptUtil {
  static String encryptWithIntegrityCheck({String content, Hmac hmac, Encrypter encrypter}) {
    var hash = hmac.convert(content.codeUnits);
    var encrypted = encrypter.encrypt('${String.fromCharCodes(hash.bytes)}\n$content');
    return String.fromCharCodes(encrypted.bytes);
  }

  static String decryptWithIntegrityCheck({String content, Hmac hmac, Encrypter encrypter}) {
    var encrypted = Encrypted(content.codeUnits);
    var decrypted = encrypter.decrypt(encrypted);
    var index = decrypted.indexOf('\n');
    if (index == -1) {
      throw Exception();
    }

    var hash = decrypted.substring(0, index);
    var rawContent = decrypted.substring(index + 1);
    var hash2 = hmac.convert(rawContent.codeUnits);
    if (hash.codeUnits != hash2.bytes) {
      throw Exception();
    }

    return rawContent;
  }
}
