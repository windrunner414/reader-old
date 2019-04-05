class DataResult<T> {
  final T data;
  final bool success;
  final String errMsg;

  DataResult({this.data, this.success, this.errMsg}) : assert(success != null);
}