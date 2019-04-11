import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'dart:typed_data';

class EncryptException implements Exception {
  final String message;

  EncryptException(this.message);

  String toString() => 'EncryptException: $message';
}

class EncryptUtil {
  EncryptUtil._();

  static List<int> encryptWithIntegrityCheck({String data, Hmac hmac, Encrypter encrypter}) {
    var hash = hmac.convert(data.codeUnits);
    var encrypted = encrypter.encrypt('${hash.toString()}\n$data');
    return encrypted.bytes.toList();
  }

  static String decryptWithIntegrityCheck({List<int> data, Hmac hmac, Encrypter encrypter}) {
    var encrypted = Encrypted(Uint8List.fromList(data));
    var decrypted = encrypter.decrypt(encrypted);
    var index = decrypted.indexOf('\n');
    if (index == -1) {
      assert(() {
        print('解密未找到换行符\n解密前: $data\n解密后: ${decrypted.codeUnits}');
        return true;
      }());
      throw EncryptException('解密完整性校验失败[1]');
    }

    var hash1 = decrypted.substring(0, index);
    var rawContent = decrypted.substring(index + 1);
    var hash2 = hmac.convert(rawContent.codeUnits).toString();

    if (hash1 != hash2) {
      assert(() {
        print('解密hash校验失败\n密文中hash：$hash1\n明文hash：$hash2\n明文：$rawContent');
        return true;
      }());
      throw EncryptException('解密完整性校验失败[2]');
    }

    return rawContent;
  }
}
