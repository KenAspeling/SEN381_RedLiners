class Topic {
  final int id;
  final String title;
  final String content;
  final String authorName;
  final String authorEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final bool isLiked; // Whether current user liked this topic
  final bool isAnnouncement; // Whether this is a tutor announcement

  Topic({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorEmail,
    required this.createdAt,
    required this.updatedAt,
    required this.likeCount,
    required this.commentCount,
    required this.viewCount,
    this.isLiked = false,
    this.isAnnouncement = false,
  });

  /// Create Topic from JSON response (from C# backend API)
  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      authorName: json['authorName'] as String,
      authorEmail: json['authorEmail'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isAnnouncement: json['isAnnouncement'] as bool? ?? false,
    );
  }

  /// Convert Topic to JSON for API requests (creating/updating topics)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      // Note: Don't include id, authorName, timestamps, counts
      // Those are handled by the backend
    };
  }

  /// Create Topic with updated data (for state management)
  Topic copyWith({
    int? id,
    String? title,
    String? content,
    String? authorName,
    String? authorEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    int? commentCount,
    int? viewCount,
    bool? isLiked,
    bool? isAnnouncement,
  }) {
    return Topic(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      authorEmail: authorEmail ?? this.authorEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      viewCount: viewCount ?? this.viewCount,
      isLiked: isLiked ?? this.isLiked,
      isAnnouncement: isAnnouncement ?? this.isAnnouncement,
    );
  }

  // Frontend-specific computed properties for UI

  /// Get formatted time ago string (e.g., "2h ago", "3d ago")
  String get timeAgo {
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
  }

  /// Check if this is a long topic (for UI truncation)
  bool get isLongTopic => content.length > 500;

  /// Get truncated content for preview (first 200 chars)
  String get contentPreview {
    if (content.length <= 200) return content;
    return '${content.substring(0, 200)}...';
  }

  /// Get author display name (falls back to email username if no name)
  String get authorDisplayName {
    if (authorName.isNotEmpty) return authorName;
    return authorEmail.split('@')[0]; // Use email username as fallback
  }

  /// Check if topic was recently updated (within last 24 hours)
  bool get wasRecentlyUpdated {
    final difference = updatedAt.difference(createdAt);
    return difference.inHours > 1; // If updated more than 1 hour after creation
  }

  /// Get formatted view count (e.g., "1.2K views", "2.5M views")
  String get formattedViewCount {
    if (viewCount < 1000) return '$viewCount views';
    if (viewCount < 1000000) {
      final k = (viewCount / 1000).toStringAsFixed(1);
      return '${k}K views';
    }
    final m = (viewCount / 1000000).toStringAsFixed(1);
    return '${m}M views';
  }

  /// Get formatted like count
  String get formattedLikeCount {
    if (likeCount < 1000) return likeCount.toString();
    if (likeCount < 1000000) {
      final k = (likeCount / 1000).toStringAsFixed(1);
      return '${k}K';
    }
    final m = (likeCount / 1000000).toStringAsFixed(1);
    return '${m}M';
  }

  /// Get formatted comment count
  String get formattedCommentCount {
    if (commentCount < 1000) return commentCount.toString();
    if (commentCount < 1000000) {
      final k = (commentCount / 1000).toStringAsFixed(1);
      return '${k}K';
    }
    final m = (commentCount / 1000000).toStringAsFixed(1);
    return '${m}M';
  }

  @override
  String toString() {
    return 'Topic{id: $id, title: $title, author: $authorName, likes: $likeCount}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Topic && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}