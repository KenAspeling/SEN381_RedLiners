import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:campuslearn/services/api_config.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/services/notification_manager.dart';

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
  final NotificationManager _notificationManager = NotificationManager();

  static const int maxRetries = 3;
  static const int notificationIdBase = 2000; // Download notifications start at 2000

  /// Get current download queue
  List<DownloadTask> get queue => List.unmodifiable(_queue);

  /// Add download task to queue
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
    print('[DOWNLOAD] Added to queue: $fileName (Material ID: $materialId)');

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
    print('[DOWNLOAD] Processing queue (${_queue.length} items)');

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
    print('[DOWNLOAD] Queue processing complete');
  }

  /// Download a single file
  Future<void> _downloadFile(DownloadTask task) async {
    try {
      final notificationId = notificationIdBase + task.hashCode % 1000;

      print('[DOWNLOAD] Starting download: ${task.fileName} (attempt ${task.retryCount + 1}/$maxRetries)');

      // Show initial progress notification
      await _notificationManager.showDownloadProgress(
        id: notificationId,
        fileName: task.fileName,
        progress: 0,
      );

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final url = '${ApiConfig.baseUrl}/api/materials/${task.materialId}/download';

      // Create request with progress tracking
      final request = http.Request('GET', Uri.parse(url));
      request.headers.addAll(ApiConfig.getAuthHeaders(token));

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        throw Exception('Download failed: ${streamedResponse.statusCode}');
      }

      // Get downloads directory
      final directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${task.fileName}';
      final file = File(filePath);

      // Track download progress
      final contentLength = streamedResponse.contentLength ?? 0;
      int bytesReceived = 0;

      // Create file and write with progress tracking
      final fileStream = file.openWrite();

      await for (var chunk in streamedResponse.stream) {
        fileStream.add(chunk);
        bytesReceived += chunk.length;

        if (contentLength > 0) {
          final progress = (bytesReceived / contentLength * 100).round();
          if (progress != task.progress && progress % 10 == 0) {
            task.progress = progress;
            await _notificationManager.showDownloadProgress(
              id: notificationId,
              fileName: task.fileName,
              progress: progress,
            );
          }
        }
      }

      await fileStream.close();

      task.isCompleted = true;
      task.filePath = filePath;
      task.progress = 100;

      print('[DOWNLOAD] Download complete: ${task.fileName} -> $filePath');

      // Show completion notification with "Open" action
      await _notificationManager.showDownloadComplete(
        id: notificationId,
        fileName: task.fileName,
        filePath: filePath,
        success: true,
      );
    } catch (e) {
      print('[DOWNLOAD] Download error: $e');

      task.retryCount++;
      task.errorMessage = e.toString();

      if (task.retryCount >= maxRetries) {
        task.isFailed = true;
        final notificationId = notificationIdBase + task.hashCode % 1000;

        await _notificationManager.showDownloadComplete(
          id: notificationId,
          fileName: task.fileName,
          filePath: '',
          success: false,
        );

        print('[DOWNLOAD] Download failed permanently: ${task.fileName}');
      } else {
        print('[DOWNLOAD] Will retry: ${task.fileName}');
        // Wait before retry
        await Future.delayed(Duration(seconds: 2 * task.retryCount));
      }
    }
  }

  /// Open downloaded file
  Future<bool> openFile(String filePath) async {
    try {
      final uri = Uri.file(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
      return false;
    } catch (e) {
      print('[DOWNLOAD] Error opening file: $e');
      return false;
    }
  }

  /// Cancel a download task
  void cancelDownload(String taskId) {
    final index = _queue.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _queue.removeAt(index);
      print('[DOWNLOAD] Cancelled: $taskId');
    }
  }

  /// Clear all completed/failed downloads
  void clearCompleted() {
    _queue.removeWhere((task) => task.isCompleted || task.isFailed);
    print('[DOWNLOAD] Cleared completed tasks');
  }
}
