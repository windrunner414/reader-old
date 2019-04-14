import 'package:dio/dio.dart';

class HttpConfig {
  HttpConfig._();

  static BaseOptions options = BaseOptions(
    /// 连接超时时间，单位毫秒
    connectTimeout: 5000,

    /// 接收数据超时时间，单位毫秒
    receiveTimeout: 8000,

    /// api基础url，实际请求url为基础url + 路径
    baseUrl: 'https://www.zhuidu.cc',

    /// api返回数据类型，设置为plain不要改动
    responseType: ResponseType.plain,
  );

  /// 拦截器
  static List<Interceptor> interceptors = [];
}
