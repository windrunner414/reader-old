import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';

class EncryptConfig {
  EncryptConfig._();

  /// HMAC，用于校验章节完整性
  static Hmac bookChapterHMAC = Hmac(sha256, utf8.encode('afeiofuj3892ufjdoafnkmn'));

  /// 加密章节使用的Encrypter，32字节Key以及16字节IV。长度错误会导致无法加解密
  static Encrypter bookChapterEncrypter = Encrypter(AES(Key.fromUtf8('fa9d8fuio43nfkmndaofr9dk3pc9vmrk'), IV.fromUtf8('ef98ulf3n2fjkdna')));
}
