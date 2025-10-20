class User {
  final int id;
  final String email;
  final String name;
  final String? profilePicture; // URL to profile image
  final DateTime createdAt;
  final DateTime lastActive;
  final bool isActive;
  final bool isTutor;
  final int postCount;
  final int commentCount;
  final int followerCount;
  final int followingCount;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.profilePicture,
    required this.createdAt,
    required this.lastActive,
    this.isActive = true,
    this.isTutor = false,
    this.postCount = 0,
    this.commentCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
  });

  /// Create User from JSON response (from C# backend API)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      profilePicture: json['profilePicture'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActive: DateTime.parse(json['lastActive'] as String),
      isActive: json['isActive'] as bool? ?? true,
      isTutor: json['isTutor'] as bool? ?? false,
      postCount: json['postCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      followerCount: json['followerCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
    );
  }

  /// Convert User to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profilePicture': profilePicture,
      'isTutor': isTutor,
    };
  }

  /// Create User with updated data (for state management)
  User copyWith({
    int? id,
    String? email,
    String? name,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isActive,
    bool? isTutor,
    int? postCount,
    int? commentCount,
    int? followerCount,
    int? followingCount,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      isActive: isActive ?? this.isActive,
      isTutor: isTutor ?? this.isTutor,
      postCount: postCount ?? this.postCount,
      commentCount: commentCount ?? this.commentCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }

  // Frontend-specific computed properties for UI

  /// Get display name (falls back to email username if name is empty)
  String get displayName {
    if (name.isNotEmpty) return name;
    return email.split('@')[0]; // Use email username as fallback
  }

  /// Get user initials for avatar (first letter of each name part)
  String get initials {
    if (name.isEmpty) return email[0].toUpperCase();
    
    final nameParts = name.trim().split(' ');
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }
    
    return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
  }

  /// Check if user is online (last active within 5 minutes)
  bool get isOnline {
    final now = DateTime.now();
    final difference = now.difference(lastActive);
    return difference.inMinutes <= 5;
  }

  /// Get formatted last active time
  String get lastActiveFormatted {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'Active ${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'Active ${months}mo ago';
    } else if (difference.inDays > 0) {
      return 'Active ${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return 'Active ${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return 'Active ${difference.inMinutes}m ago';
    } else {
      return 'Online now';
    }
  }

  /// Get formatted member since date
  String get memberSince {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return 'Member since ${months[createdAt.month - 1]} ${createdAt.year}';
  }

  /// Check if user is new (joined within last 30 days)
  bool get isNewUser {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays <= 30;
  }

  /// Get formatted post count
  String get formattedTopicCount {
    if (postCount < 1000) return postCount.toString();
    if (postCount < 1000000) {
      final k = (postCount / 1000).toStringAsFixed(1);
      return '${k}K';
    }
    final m = (postCount / 1000000).toStringAsFixed(1);
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

  /// Get formatted follower count
  String get formattedFollowerCount {
    if (followerCount < 1000) return followerCount.toString();
    if (followerCount < 1000000) {
      final k = (followerCount / 1000).toStringAsFixed(1);
      return '${k}K';
    }
    final m = (followerCount / 1000000).toStringAsFixed(1);
    return '${m}M';
  }

  /// Get user reputation level based on posts and comments
  String get reputationLevel {
    if (isTutor) return 'Tutor';
    final totalActivity = postCount + commentCount;
    if (totalActivity < 10) return 'Newcomer';
    if (totalActivity < 50) return 'Active Member';
    if (totalActivity < 100) return 'Regular Contributor';
    if (totalActivity < 500) return 'Veteran Member';
    return 'Campus Leader';
  }

  /// Get badge text for UI display
  String get badgeText {
    if (isTutor) return 'Tutor';
    if (isNewUser) return 'New';
    return '';
  }

  /// Check if user can moderate content
  bool get canModerateContent => isTutor;

  /// Check if user can pin posts
  bool get canPinTopics => isTutor;

  /// Check if user can create announcements
  bool get canCreateAnnouncements => isTutor;

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}