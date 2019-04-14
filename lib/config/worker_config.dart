class WorkerConfig {
  WorkerConfig._();

  /// 用于解析API返回内容、加解密小说章节内容等的worker数量（isolate数，类似线程）
  static int taskWorkerNum = 5;

  /// 是否懒惰创建taskWorker的isolate
  static bool taskWorkerSpawnLazily = true;
}
