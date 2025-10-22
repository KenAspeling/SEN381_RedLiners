// Stub for download service - will be replaced by platform-specific implementation

class DownloadTask {
  final String id;
  final int materialId;
  final String fileName;
  int progress;
  int retryCount;
  bool isCompleted;
  bool isFailed;
  String? errorMessage;
  String? filePath;

  DownloadTask({
    required this.id,
    required this.materialId,
    required this.fileName,
    this.progress = 0,
    this.retryCount = 0,
    this.isCompleted = false,
    this.isFailed = false,
    this.errorMessage,
    this.filePath,
  });
}

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  List<DownloadTask> get queue => [];

  Future<String> addDownload({
    required int materialId,
    required String fileName,
  }) async {
    throw UnsupportedError('Download service not available on this platform');
  }

  Future<bool> openFile(String filePath) async {
    return false;
  }

  void cancelDownload(String taskId) {}

  void clearCompleted() {}
}
