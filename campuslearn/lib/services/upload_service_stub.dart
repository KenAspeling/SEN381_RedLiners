// Stub for upload service - will be replaced by platform-specific implementation
import 'package:file_picker/file_picker.dart';

class UploadTask {
  final String id;
  final PlatformFile file;
  final int ticketId;
  int progress;
  int retryCount;
  bool isCompleted;
  bool isFailed;
  String? errorMessage;
  int? materialId;

  UploadTask({
    required this.id,
    required this.file,
    required this.ticketId,
    this.progress = 0,
    this.retryCount = 0,
    this.isCompleted = false,
    this.isFailed = false,
    this.errorMessage,
    this.materialId,
  });
}

class UploadService {
  static final UploadService _instance = UploadService._internal();
  factory UploadService() => _instance;
  UploadService._internal();

  List<UploadTask> get queue => [];

  Future<String> addUpload({
    required PlatformFile file,
    required int ticketId,
  }) async {
    throw UnsupportedError('Upload service not available on this platform');
  }

  void cancelUpload(String taskId) {}

  void clearCompleted() {}
}
