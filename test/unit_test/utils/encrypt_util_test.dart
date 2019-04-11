import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';
import '../../helper/helper.dart';
import 'package:reader/utils/encrypt_util.dart';

void main() {
  test('加密解密带完整性校验', () {
    for (int i = 0; i < TEST_TIMES; ++i) {
      var hmac = Hmac(sha256, utf8.encode(getRandomString(8, maxLength: 32)));
      var encrypter = Encrypter(AES(Key.fromUtf8(getRandomString(32, chinese: false)), IV.fromUtf8(getRandomString(16, chinese: false))));
      var data = getRandomString(100, maxLength: 1000);
      var e = EncryptUtil.encryptWithIntegrityCheck(data: data, hmac: hmac, encrypter: encrypter);
      var d = EncryptUtil.decryptWithIntegrityCheck(data: e, hmac: hmac, encrypter: encrypter);
      expect(data, equals(d));
    }
  });

  test('解密完整性校验失败[1]', () {
    for (int i = 0; i < TEST_TIMES; ++i) {
      try {
        var hmac = Hmac(sha256, utf8.encode(getRandomString(8, maxLength: 32)));
        var encrypter = Encrypter(AES(Key.fromUtf8(getRandomString(32, chinese: false)), IV.fromUtf8(getRandomString(16, chinese: false))));
        var data = getRandomString(100, maxLength: 1000);
        EncryptUtil.decryptWithIntegrityCheck(data: encrypter.encrypt(data).bytes.toList(), hmac: hmac, encrypter: encrypter);
        expect(true, equals(false), reason: '解密未能失败');
      } on EncryptException catch (e) {
        expect(e.message, contains('解密完整性校验失败[1]'));
      }
    }
  });

  test('解密完整性校验失败[2]', () {
    for (int i = 0; i < TEST_TIMES; ++i) {
      try {
        var hmac = Hmac(sha256, utf8.encode(getRandomString(8, maxLength: 32)));
        var encrypter = Encrypter(AES(Key.fromUtf8(getRandomString(32, chinese: false)), IV.fromUtf8(getRandomString(16, chinese: false))));
        var data = getRandomString(10, maxLength: 50) + '\n' + getRandomString(100, maxLength: 1000);
        EncryptUtil.decryptWithIntegrityCheck(data: encrypter.encrypt(data).bytes.toList(), hmac: hmac, encrypter: encrypter);
        expect(true, equals(false), reason: '解密未能失败');
      } on EncryptException catch (e) {
        expect(e.message, contains('解密完整性校验失败[2]'));
      }
    }
  });
}
