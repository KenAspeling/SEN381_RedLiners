class Comment {
  final int id;
  final int topicId;
  final String content;
  final String authorName;
  final String authorEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likeCount;
  final bool isLiked; // Whether current user liked this comment

  Comment({
    required this.id,
    required this.topicId,
    required this.content,
    required this.authorName,
    required this.authorEmail,
    required this.createdAt,
    required this.updatedAt,
    required this.likeCount,
    this.isLiked = false,
  });

  /// Create Comment from JSON response (from C# backend API)
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      topicId: json['topicId'] as int,
      content: json['content'] as String,
      authorName: json['authorName'] as String,
      authorEmail: json['authorEmail'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      likeCount: json['likeCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }

  /// Convert Comment to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'topicId': topicId,
      'content': content,
      // Note: Don't include id, authorName, timestamps, counts
      // Those are handled by the backend
    };
  }

  /// Create Comment with updated data (for state management)
  Comment copyWith({
    int? id,
    int? topicId,
    String? content,
    String? authorName,
    String? authorEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    bool? isLiked,
  }) {
    return Comment(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      authorEmail: authorEmail ?? this.authorEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  // Frontend-specific computed properties for UI

  /// Get formatted time ago string (e.g., "2h ago", "3d ago")
  String get timeAgo {
    try {
      final now = DateTime.now();
      final difference = now.difference(createdAt);

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
    } catch (e) {
      return 'Unknown'; // Fallback if date operations fail
    }
  }

  /// Check if this is a long comment (for UI truncation)
  bool get isLongComment => content.length > 200;

  /// Get truncated content for preview (first 150 chars)
  String get contentPreview {
    if (content.length <= 150) return content;
    return '${content.substring(0, 150)}...';
  }

  /// Get author display name (falls back to email username if no name)
  String get authorDisplayName {
    if (authorName.isNotEmpty) return authorName;
    return authorEmail.split('@')[0]; // Use email username as fallback
  }

  /// Check if comment was recently updated (within last 24 hours)
  bool get wasRecentlyUpdated {
    final difference = updatedAt.difference(createdAt);
    return difference.inHours > 1; // If updated more than 1 hour after creation
  }

  /// Get formatted like count
  String get formattedLikeCount {
    try {
      if (likeCount < 1000) return likeCount.toString();
      if (likeCount < 1000000) {
        final k = (likeCount / 1000).toStringAsFixed(1);
        return '${k}K';
      }
      final m = (likeCount / 1000000).toStringAsFixed(1);
      return '${m}M';
    } catch (e) {
      return '0'; // Fallback if likeCount is somehow null
    }
  }

  @override
  String toString() {
    return 'Comment{id: $id, topicId: $topicId, author: $authorName, likes: $likeCount}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}