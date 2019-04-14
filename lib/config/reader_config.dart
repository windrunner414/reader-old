import 'package:flutter/material.dart';
import 'package:reader/model/reader_preferences.dart';

class ReaderConfig {
  ReaderConfig._();

  /// 缓存小说时的并发请求数
  static int maxDownloadConcurrency = 5;

  /// 默认的阅读器偏好设置
  static ReaderPreferences defaultPreferences = ReaderPreferences(
    pageTurning: PageTurningType.COVERAGE,
    background: Color.fromRGBO(213, 239, 210, 1),
    fontColor: Colors.black87,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    height: 1.3,
    paragraphHeight: 1,
    fullScreen: true,
    nightMode: false,
  );
}
