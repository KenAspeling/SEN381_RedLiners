class Message {
  final int messageId;
  final int senderId;
  final String senderName;
  final String senderEmail;
  final int recipientId;
  final String recipientName;
  final String recipientEmail;
  final String content;
  final DateTime timeCreated;
  final bool read;
  final int? materialId;

  Message({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.senderEmail,
    required this.recipientId,
    required this.recipientName,
    required this.recipientEmail,
    required this.content,
    required this.timeCreated,
    required this.read,
    this.materialId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'] as int,
      senderId: json['senderId'] as int,
      senderName: json['senderName'] as String,
      senderEmail: json['senderEmail'] as String,
      recipientId: json['recipientId'] as int,
      recipientName: json['recipientName'] as String,
      recipientEmail: json['recipientEmail'] as String,
      content: json['content'] as String,
      timeCreated: DateTime.parse(json['timeCreated'] as String),
      read: json['read'] as bool,
      materialId: json['materialId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderName': senderName,
      'senderEmail': senderEmail,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'recipientEmail': recipientEmail,
      'content': content,
      'timeCreated': timeCreated.toIso8601String(),
      'read': read,
      'materialId': materialId,
    };
  }

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
}

class Conversation {
  final int userId;
  final String userName;
  final String userEmail;
  final Message? lastMessage;
  final int unreadCount;

  Conversation({
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.lastMessage,
    required this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unreadCount'] as int,
    );
  }
}
