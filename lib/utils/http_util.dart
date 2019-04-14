import 'package:dio/dio.dart';
import 'package:reader/config/http_config.dart';
import 'task_cancel_token.dart';
import 'package:meta/meta.dart';

export 'package:dio/dio.dart';

class HttpMethod {
  static const get = 'GET';
  static const post = 'POST';
  static const put = 'PUT';
  static const head = 'HEAD';
  static const delete = 'DELETE';
  static const patch = 'PATCH';

  HttpMethod._();
}

class HttpRequest {
  final String method;
  final String path;
  final dynamic data;
  final Map<String, dynamic> queryParameters;
  final Options options;

  const HttpRequest({this.method = HttpMethod.get, @required this.path, this.data, this.queryParameters, this.options});
}

class HttpUtil {
  static final Dio http = Dio(HttpConfig.options)
    ..interceptors.addAll(HttpConfig.interceptors);

  HttpUtil._();

  static Future<Response<T>> request<T>(
    HttpRequest request, {
    TaskCancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  }) {
    Options options = request.options ?? Options();
    if (request.method != null) options.method = request.method;

    return http.request(
      request.path,
      data: request.data,
      queryParameters: request.queryParameters,
      options: options,
      cancelToken: cancelToken?.http,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
