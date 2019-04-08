import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';

class EncryptConfig {
  /// HMAC，用于校验章节完整性
  static Hmac bookChapterHMAC = Hmac(sha256, utf8.encode('afeiofuj3892ufjdoafnkmn'));

  /// 加密章节使用的Encrypter
  static Encrypter bookChapterEncrypter = Encrypter(AES(Key.fromUtf8('fa9d8fuio43nfkmndaof'), IV.fromUtf8('ef98ulf3n2fjkdnafojo')));
}
