import 'dart:async';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:campuslearn/services/api_config.dart';
import 'package:campuslearn/services/auth_service.dart';

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

  final List<DownloadTask> _queue = [];
  bool _isProcessing = false;

  static const int maxRetries = 3;

  /// Get current download queue
  List<DownloadTask> get queue => List.unmodifiable(_queue);

  /// Add download task to queue (web uses browser download)
  Future<String> addDownload({
    required int materialId,
    required String fileName,
  }) async {
    final taskId = '${DateTime.now().millisecondsSinceEpoch}_$fileName';

    final task = DownloadTask(
      id: taskId,
      materialId: materialId,
      fileName: fileName,
    );

    _queue.add(task);
    print('[DOWNLOAD WEB] Added to queue: $fileName (Material ID: $materialId)');

    // Start processing if not already running
    if (!_isProcessing) {
      _processQueue();
    }

    return taskId;
  }

  /// Process download queue
  Future<void> _processQueue() async {
    if (_isProcessing) return;

    _isProcessing = true;
    print('[DOWNLOAD WEB] Processing queue (${_queue.length} items)');

    while (_queue.isNotEmpty) {
      final task = _queue.first;

      if (!task.isCompleted && !task.isFailed) {
        await _downloadFile(task);
      }

      // Remove completed or failed tasks (after max retries)
      if (task.isCompleted || (task.isFailed && task.retryCount >= maxRetries)) {
        _queue.removeAt(0);
      } else if (task.isFailed) {
        // Move failed task to end of queue for retry
        _queue.removeAt(0);
        _queue.add(task);
      }
    }

    _isProcessing = false;
    print('[DOWNLOAD WEB] Queue processing complete');
  }

  /// Download a single file using browser download
  Future<void> _downloadFile(DownloadTask task) async {
    try {
      print('[DOWNLOAD WEB] Starting download: ${task.fileName} (attempt ${task.retryCount + 1}/$maxRetries)');

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final url = '${ApiConfig.baseUrl}/api/materials/${task.materialId}/download';

      // Fetch file
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode != 200) {
        throw Exception('Download failed: ${response.statusCode}');
      }

      // Create blob and trigger browser download
      final blob = html.Blob([response.bodyBytes]);
      final blobUrl = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: blobUrl)
        ..setAttribute('download', task.fileName)
        ..style.display = 'none';

      html.document.body?.children.add(anchor);
      anchor.click();

      // Cleanup
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(blobUrl);

      task.isCompleted = true;
      task.progress = 100;

      print('[DOWNLOAD WEB] Download complete: ${task.fileName}');
    } catch (e) {
      print('[DOWNLOAD WEB] Download error: $e');

      task.retryCount++;
      task.errorMessage = e.toString();

      if (task.retryCount >= maxRetries) {
        task.isFailed = true;
        print('[DOWNLOAD WEB] Download failed permanently: ${task.fileName}');
      } else {
        print('[DOWNLOAD WEB] Will retry: ${task.fileName}');
        // Wait before retry
        await Future.delayed(Duration(seconds: 2 * task.retryCount));
      }
    }
  }

  /// Open downloaded file (not supported on web)
  Future<bool> openFile(String filePath) async {
    print('[DOWNLOAD WEB] Open file not supported on web');
    return false;
  }

  /// Cancel a download task
  void cancelDownload(String taskId) {
    final index = _queue.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _queue.removeAt(index);
      print('[DOWNLOAD WEB] Cancelled: $taskId');
    }
  }

  /// Clear all completed/failed downloads
  void clearCompleted() {
    _queue.removeWhere((task) => task.isCompleted || task.isFailed);
    print('[DOWNLOAD WEB] Cleared completed tasks');
  }
}
