import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:campuslearn/services/api_config.dart';
import 'package:campuslearn/services/auth_service.dart';

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

  final List<UploadTask> _queue = [];
  bool _isProcessing = false;

  static const int maxRetries = 3;
  static const int notificationIdBase = 1000;

  /// Get current upload queue
  List<UploadTask> get queue => List.unmodifiable(_queue);

  /// Add upload task to queue
  Future<String> addUpload({
    required PlatformFile file,
    required int ticketId,
  }) async {
    final taskId = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';

    final task = UploadTask(
      id: taskId,
      file: file,
      ticketId: ticketId,
    );

    _queue.add(task);
    print('[UPLOAD WEB] Added to queue: ${file.name} for ticket $ticketId');

    // Start processing if not already running
    if (!_isProcessing) {
      _processQueue();
    }

    return taskId;
  }

  /// Process upload queue
  Future<void> _processQueue() async {
    if (_isProcessing) return;

    _isProcessing = true;
    print('[UPLOAD WEB] Processing queue (${_queue.length} items)');

    while (_queue.isNotEmpty) {
      final task = _queue.first;

      if (!task.isCompleted && !task.isFailed) {
        await _uploadFile(task);
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
    print('[UPLOAD WEB] Queue processing complete');
  }

  /// Upload a single file using web bytes
  Future<void> _uploadFile(UploadTask task) async {
    if (task.file.bytes == null) {
      task.isFailed = true;
      task.errorMessage = 'File bytes are null';
      return;
    }

    try {
      print('[UPLOAD WEB] Starting upload: ${task.file.name} (attempt ${task.retryCount + 1}/$maxRetries)');

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/api/materials/upload'),
      );

      // Add auth header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add title field
      request.fields['title'] = task.file.name;

      // Add file using bytes (available on web)
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        task.file.bytes!,
        filename: task.file.name,
      ));

      print('[UPLOAD WEB] File size: ${task.file.bytes!.length} bytes');

      // Send request
      task.progress = 50;
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      task.progress = 100;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse material ID from response
        final jsonResponse = _parseJson(response.body);
        final materialId = jsonResponse?['materialId'] as int?;

        task.isCompleted = true;
        task.materialId = materialId;
        task.progress = 100;

        print('[UPLOAD WEB] Upload complete: ${task.file.name}, Material ID: $materialId');
      } else {
        throw Exception('Upload failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('[UPLOAD WEB] Upload error: $e');

      task.retryCount++;
      task.errorMessage = e.toString();

      if (task.retryCount >= maxRetries) {
        task.isFailed = true;
        print('[UPLOAD WEB] Upload failed permanently: ${task.file.name}');
      } else {
        print('[UPLOAD WEB] Will retry: ${task.file.name}');
        // Wait before retry
        await Future.delayed(Duration(seconds: 2 * task.retryCount));
      }
    }
  }

  Map<String, dynamic>? _parseJson(String body) {
    try {
      return _jsonDecode(body);
    } catch (e) {
      print('[UPLOAD WEB] JSON parse error: $e');
      return null;
    }
  }

  dynamic _jsonDecode(String str) {
    // Simple JSON decoder - in production, use dart:convert
    try {
      final trimmed = str.trim();
      if (!trimmed.startsWith('{')) return null;

      // Extract materialId using regex (simplified)
      final match = RegExp(r'"materialId"\s*:\s*(\d+)').firstMatch(trimmed);
      if (match != null) {
        return {'materialId': int.parse(match.group(1)!)};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cancel an upload task
  void cancelUpload(String taskId) {
    final index = _queue.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _queue.removeAt(index);
      print('[UPLOAD WEB] Cancelled: $taskId');
    }
  }

  /// Clear all completed/failed uploads
  void clearCompleted() {
    _queue.removeWhere((task) => task.isCompleted || task.isFailed);
    print('[UPLOAD WEB] Cleared completed tasks');
  }
}
