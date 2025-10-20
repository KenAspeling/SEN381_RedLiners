enum TicketStatus {
  open,
  inProgress,
  answered,
  closed,
  escalated,
}

enum TicketPriority {
  low,
  medium,
  high,
  urgent,
}

enum TicketCategory {
  mathematics,
  computerScience,
  physics,
  chemistry,
  biology,
  writing,
  languages,
  engineering,
  business,
  generalStudy,
  other,
}

class Ticket {
  final int id;
  final String title;
  final String description;
  final TicketCategory category;
  final TicketPriority priority;
  final TicketStatus status;
  final String studentId;
  final String studentEmail;
  final String studentName;
  final String? tutorId;
  final String? tutorEmail;
  final String? tutorName;
  final String? response;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? respondedAt;
  final DateTime? closedAt;
  final int? rating; // 1-5 stars, null if not rated

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.studentId,
    required this.studentEmail,
    required this.studentName,
    this.tutorId,
    this.tutorEmail,
    this.tutorName,
    this.response,
    required this.createdAt,
    required this.updatedAt,
    this.respondedAt,
    this.closedAt,
    this.rating,
  });

  /// Create Ticket from JSON response (from C# backend API)
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: TicketCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TicketCategory.other,
      ),
      priority: TicketPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TicketPriority.medium,
      ),
      status: TicketStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TicketStatus.open,
      ),
      studentId: json['studentId'] as String,
      studentEmail: json['studentEmail'] as String,
      studentName: json['studentName'] as String,
      tutorId: json['tutorId'] as String?,
      tutorEmail: json['tutorEmail'] as String?,
      tutorName: json['tutorName'] as String?,
      response: json['response'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      respondedAt: json['respondedAt'] != null 
          ? DateTime.parse(json['respondedAt'] as String) 
          : null,
      closedAt: json['closedAt'] != null 
          ? DateTime.parse(json['closedAt'] as String) 
          : null,
      rating: json['rating'] as int?,
    );
  }

  /// Convert Ticket to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
    };
  }

  /// Create Ticket with updated data (for state management)
  Ticket copyWith({
    int? id,
    String? title,
    String? description,
    TicketCategory? category,
    TicketPriority? priority,
    TicketStatus? status,
    String? studentId,
    String? studentEmail,
    String? studentName,
    String? tutorId,
    String? tutorEmail,
    String? tutorName,
    String? response,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? respondedAt,
    DateTime? closedAt,
    int? rating,
  }) {
    return Ticket(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      studentId: studentId ?? this.studentId,
      studentEmail: studentEmail ?? this.studentEmail,
      studentName: studentName ?? this.studentName,
      tutorId: tutorId ?? this.tutorId,
      tutorEmail: tutorEmail ?? this.tutorEmail,
      tutorName: tutorName ?? this.tutorName,
      response: response ?? this.response,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      closedAt: closedAt ?? this.closedAt,
      rating: rating ?? this.rating,
    );
  }

  // Frontend-specific computed properties for UI

  /// Get formatted time ago string for creation
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

  /// Get human-readable status text
  String get statusText {
    switch (status) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.answered:
        return 'Answered';
      case TicketStatus.closed:
        return 'Closed';
      case TicketStatus.escalated:
        return 'Escalated';
    }
  }

  /// Get human-readable priority text
  String get priorityText {
    switch (priority) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.urgent:
        return 'Urgent';
    }
  }

  /// Get human-readable category text
  String get categoryText {
    switch (category) {
      case TicketCategory.mathematics:
        return 'Mathematics';
      case TicketCategory.computerScience:
        return 'Computer Science';
      case TicketCategory.physics:
        return 'Physics';
      case TicketCategory.chemistry:
        return 'Chemistry';
      case TicketCategory.biology:
        return 'Biology';
      case TicketCategory.writing:
        return 'Writing';
      case TicketCategory.languages:
        return 'Languages';
      case TicketCategory.engineering:
        return 'Engineering';
      case TicketCategory.business:
        return 'Business';
      case TicketCategory.generalStudy:
        return 'General Study';
      case TicketCategory.other:
        return 'Other';
    }
  }

  /// Check if ticket is waiting for tutor response
  bool get isAwaitingResponse => status == TicketStatus.open || status == TicketStatus.inProgress;

  /// Check if ticket has been answered
  bool get hasResponse => response != null && response!.isNotEmpty;

  /// Check if ticket is closed or completed
  bool get isClosed => status == TicketStatus.closed;

  /// Get response time (if responded)
  Duration? get responseTime {
    if (respondedAt != null) {
      return respondedAt!.difference(createdAt);
    }
    return null;
  }

  /// Get formatted response time
  String? get formattedResponseTime {
    final time = responseTime;
    if (time == null) return null;

    if (time.inDays > 0) {
      return '${time.inDays}d ${time.inHours % 24}h';
    } else if (time.inHours > 0) {
      return '${time.inHours}h ${time.inMinutes % 60}m';
    } else {
      return '${time.inMinutes}m';
    }
  }

  /// Get status color for UI
  String get statusColor {
    switch (status) {
      case TicketStatus.open:
        return '#2196F3'; // Blue
      case TicketStatus.inProgress:
        return '#FF9800'; // Orange
      case TicketStatus.answered:
        return '#4CAF50'; // Green
      case TicketStatus.closed:
        return '#9E9E9E'; // Grey
      case TicketStatus.escalated:
        return '#F44336'; // Red
    }
  }

  /// Get priority color for UI
  String get priorityColor {
    switch (priority) {
      case TicketPriority.low:
        return '#4CAF50'; // Green
      case TicketPriority.medium:
        return '#FF9800'; // Orange
      case TicketPriority.high:
        return '#F44336'; // Red
      case TicketPriority.urgent:
        return '#9C27B0'; // Purple
    }
  }

  @override
  String toString() {
    return 'Ticket{id: $id, title: $title, status: $statusText, priority: $priorityText}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ticket && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}