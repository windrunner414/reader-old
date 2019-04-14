import 'package:reader/utils/http_util.dart';
import 'package:reader/utils/file_util.dart';
import 'package:cookie_jar/cookie_jar.dart';

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

  /// 拦截器，CookieJar需要提供路径，这里FileUtil需要等待初始化完后才可使用
  /// 因为Dart中静态变量只有使用的时候才会被初始化，所以只需要在使用HttpUtil之前将FileUtil初始化好即可
  static List<Interceptor> interceptors = [
    CookieManager(PersistCookieJar(dir: FileUtil.joinPath(FileUtil.appDocDir, 'cookies'))),
  ];
}
