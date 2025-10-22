class User {
  final int userId;
  final String email;
  final String name;
  final String surname;
  final String? phoneNumber;
  final DateTime timeCreated;
  final int? accessLevel; // 1=student, 2=tutor, 3=admin
  final String? accessLevelName; // "student", "tutor", "admin"
  final String? degree;
  final int? yearOfStudy;
  final List<int> moduleIds;

  // Frontend-only fields (not from backend)
  final String? profilePicture;
  final DateTime? lastActive;
  final bool isActive;
  final int postCount;
  final int commentCount;
  final int followerCount;
  final int followingCount;

  User({
    required this.userId,
    required this.email,
    required this.name,
    required this.surname,
    this.phoneNumber,
    required this.timeCreated,
    this.accessLevel = 1,
    this.accessLevelName,
    this.degree,
    this.yearOfStudy,
    this.moduleIds = const [],
    this.profilePicture,
    DateTime? lastActive,
    this.isActive = true,
    this.postCount = 0,
    this.commentCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
  }) : lastActive = lastActive ?? DateTime.now();

  /// Create User from JSON response (from C# backend API)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as int,
      email: json['email'] as String,
      name: json['name'] as String? ?? '',
      surname: json['surname'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      timeCreated: DateTime.parse(json['timeCreated'] as String),
      accessLevel: json['accessLevel'] as int?,
      accessLevelName: json['accessLevelName'] as String?,
      degree: json['degree'] as String?,
      yearOfStudy: json['yearOfStudy'] as int?,
      moduleIds: (json['moduleIds'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      profilePicture: json['profilePicture'] as String?,
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      postCount: json['postCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      followerCount: json['followerCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
    );
  }

  /// Convert User to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'surname': surname,
      'phoneNumber': phoneNumber,
      'accessLevel': accessLevel,
      'accessLevelName': accessLevelName,
      'degree': degree,
      'yearOfStudy': yearOfStudy,
      'moduleIds': moduleIds,
    };
  }

  /// Create User with updated data (for state management)
  User copyWith({
    int? userId,
    String? email,
    String? name,
    String? surname,
    String? phoneNumber,
    DateTime? timeCreated,
    int? accessLevel,
    String? accessLevelName,
    String? degree,
    int? yearOfStudy,
    List<int>? moduleIds,
    String? profilePicture,
    DateTime? lastActive,
    bool? isActive,
    int? postCount,
    int? commentCount,
    int? followerCount,
    int? followingCount,
  }) {
    return User(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      timeCreated: timeCreated ?? this.timeCreated,
      accessLevel: accessLevel ?? this.accessLevel,
      accessLevelName: accessLevelName ?? this.accessLevelName,
      degree: degree ?? this.degree,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      moduleIds: moduleIds ?? this.moduleIds,
      profilePicture: profilePicture ?? this.profilePicture,
      lastActive: lastActive ?? this.lastActive,
      isActive: isActive ?? this.isActive,
      postCount: postCount ?? this.postCount,
      commentCount: commentCount ?? this.commentCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }

  // Frontend-specific computed properties for UI

  /// Get display name (uses full name or email username as fallback)
  String get displayName {
    if (name.isNotEmpty && surname.isNotEmpty) {
      return '$name $surname';
    } else if (name.isNotEmpty) {
      return name;
    }
    return email.split('@')[0]; // Fallback to email username
  }

  /// Get user initials for avatar
  String get initials {
    if (name.isNotEmpty && surname.isNotEmpty) {
      return '${name[0]}${surname[0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    final username = email.split('@')[0];
    if (username.isEmpty) return 'U';
    return username[0].toUpperCase();
  }

  /// Check if user is a student (access level 1)
  bool get isStudent => (accessLevel ?? 1) == 1;

  /// Check if user is a tutor (access level 2 or higher)
  bool get isTutor => (accessLevel ?? 1) >= 2;

  /// Check if user is an admin (access level 3)
  bool get isAdmin => (accessLevel ?? 1) >= 3;

  /// Check if user is online (last active within 5 minutes)
  bool get isOnline {
    if (lastActive == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastActive!);
    return difference.inMinutes <= 5;
  }

  /// Get formatted last active time
  String get lastActiveFormatted {
    if (lastActive == null) return 'Never active';
    final now = DateTime.now();
    final difference = now.difference(lastActive!);

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

    return 'Member since ${months[timeCreated.month - 1]} ${timeCreated.year}';
  }

  /// Check if user is new (joined within last 30 days)
  bool get isNewUser {
    final now = DateTime.now();
    final difference = now.difference(timeCreated);
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
    if (isAdmin) return 'Admin';
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
    if (isAdmin) return 'Admin';
    if (isTutor) return 'Tutor';
    if (isNewUser) return 'New';
    return '';
  }

  /// Check if user can moderate content
  bool get canModerateContent => isTutor; // Tutor or Admin

  /// Check if user can pin posts
  bool get canPinTopics => isTutor; // Tutor or Admin

  /// Check if user can create announcements
  bool get canCreateAnnouncements => isTutor; // Tutor or Admin

  /// Check if user can manage users (Admin only)
  bool get canManageUsers => isAdmin;

  @override
  String toString() {
    return 'User{userId: $userId, email: $email, accessLevel: $accessLevel}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}