class AppNotification {
  final int notificationId;
  final int userId;
  final String type; // "comment", "new_post", "new_topic", "like", "message", "ticket_response", "new_ticket"
  final String title;
  final String message;
  final int? relatedId;
  final DateTime timeCreated;
  final bool isRead;

  AppNotification({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedId,
    required this.timeCreated,
    this.isRead = false,
  });

  /// Create AppNotification from JSON response (from C# backend API)
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      notificationId: json['notificationId'] as int,
      userId: json['userId'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      relatedId: json['relatedId'] as int?,
      timeCreated: DateTime.parse(json['timeCreated'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  /// Get formatted time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timeCreated);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Get icon based on notification type
  String get iconName {
    switch (type) {
      case 'comment':
        return 'chat_bubble';
      case 'new_post':
      case 'new_topic':
        return 'article';
      case 'like':
        return 'favorite';
      case 'message':
        return 'mail';
      case 'ticket_response':
        return 'question_answer';
      case 'new_ticket':
        return 'help';
      default:
        return 'notifications';
    }
  }

  /// Get color based on notification type
  String get colorHex {
    switch (type) {
      case 'comment':
        return '#2196F3'; // Blue
      case 'new_post':
      case 'new_topic':
        return '#00BCD4'; // Cyan
      case 'like':
        return '#E91E63'; // Pink
      case 'message':
        return '#FF9800'; // Orange
      case 'ticket_response':
        return '#4CAF50'; // Green
      case 'new_ticket':
        return '#9C27B0'; // Purple
      default:
        return '#757575'; // Grey
    }
  }
}

// Notification type constants
class NotificationTypes {
  static const String comment = 'comment';
  static const String newPost = 'new_post';
  static const String newTopic = 'new_topic';
  static const String like = 'like';
  static const String message = 'message';
  static const String ticketResponse = 'ticket_response';
  static const String newTicket = 'new_ticket';
}
