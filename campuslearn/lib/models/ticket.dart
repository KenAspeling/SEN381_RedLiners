enum TicketStatus {
  open,
  inProgress,
  answered,
  closed,
  escalated,
}

class Ticket {
  final int id;
  final String title;
  final String content; // Changed from description
  final int moduleId; // Required - Changed from category
  final String moduleName; // Required
  final TicketStatus status;
  final String studentId;
  final String studentEmail;
  final String studentName;
  final String? tutorId;
  final String? tutorEmail;
  final String? tutorName;
  final String? response;
  final String? attachmentUrl; // Document attachment
  final String? attachmentName; // Original file name
  final int? materialId; // Material ID for file attachment
  final String? fileName; // File name
  final String? fileType; // File MIME type
  final int? fileSize; // File size in bytes
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? respondedAt;
  final DateTime? closedAt;
  final int? rating; // 1-5 stars, null if not rated

  Ticket({
    required this.id,
    required this.title,
    required this.content,
    required this.moduleId,
    required this.moduleName,
    required this.status,
    required this.studentId,
    required this.studentEmail,
    required this.studentName,
    this.tutorId,
    this.tutorEmail,
    this.tutorName,
    this.response,
    this.attachmentUrl,
    this.attachmentName,
    this.materialId,
    this.fileName,
    this.fileType,
    this.fileSize,
    required this.createdAt,
    required this.updatedAt,
    this.respondedAt,
    this.closedAt,
    this.rating,
  });

  /// Create Ticket from JSON response (from C# backend API)
  factory Ticket.fromJson(Map<String, dynamic> json) {
    // Map backend status (1=sent, 2=received, 3=responded) to TicketStatus enum
    TicketStatus status;
    int statusInt = json['status'] as int? ?? 1;
    switch (statusInt) {
      case 1:
        status = TicketStatus.open; // Sent = Open
        break;
      case 2:
        status = TicketStatus.inProgress; // Received = In Progress
        break;
      case 3:
        status = TicketStatus.answered; // Responded = Answered
        break;
      case 4:
        status = TicketStatus.closed;
        break;
      case 5:
        status = TicketStatus.escalated;
        break;
      default:
        status = TicketStatus.open;
    }

    return Ticket(
      id: json['ticketId'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      moduleId: json['moduleId'] as int,
      moduleName: json['moduleName'] as String,
      status: status,
      studentId: json['userId'].toString(),
      studentEmail: json['userEmail'] as String,
      studentName: json['userName'] as String,
      tutorId: json['tutorId']?.toString(),
      tutorEmail: json['tutorEmail'] as String?,
      tutorName: json['tutorName'] as String?,
      response: json['responseContent'] as String?,
      attachmentUrl: json['attachmentUrl'] as String?,
      attachmentName: json['attachmentName'] as String?,
      materialId: json['materialId'] as int?,
      fileName: json['fileName'] as String?,
      fileType: json['fileType'] as String?,
      fileSize: json['fileSize'] as int?,
      createdAt: DateTime.parse(json['timeCreated'] as String),
      updatedAt: DateTime.parse(json['timeCreated'] as String), // Use timeCreated as updatedAt
      respondedAt: json['timeResponded'] != null
          ? DateTime.parse(json['timeResponded'] as String)
          : null,
      closedAt: null, // Not in backend yet
      rating: json['rating'] as int?,
    );
  }

  /// Convert Ticket to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'moduleId': moduleId,
      'attachmentUrl': attachmentUrl,
      'attachmentName': attachmentName,
    };
  }

  /// Create Ticket with updated data (for state management)
  Ticket copyWith({
    int? id,
    String? title,
    String? content,
    int? moduleId,
    String? moduleName,
    TicketStatus? status,
    String? studentId,
    String? studentEmail,
    String? studentName,
    String? tutorId,
    String? tutorEmail,
    String? tutorName,
    String? response,
    String? attachmentUrl,
    String? attachmentName,
    int? materialId,
    String? fileName,
    String? fileType,
    int? fileSize,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? respondedAt,
    DateTime? closedAt,
    int? rating,
  }) {
    return Ticket(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      moduleId: moduleId ?? this.moduleId,
      moduleName: moduleName ?? this.moduleName,
      status: status ?? this.status,
      studentId: studentId ?? this.studentId,
      studentEmail: studentEmail ?? this.studentEmail,
      studentName: studentName ?? this.studentName,
      tutorId: tutorId ?? this.tutorId,
      tutorEmail: tutorEmail ?? this.tutorEmail,
      tutorName: tutorName ?? this.tutorName,
      response: response ?? this.response,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentName: attachmentName ?? this.attachmentName,
      materialId: materialId ?? this.materialId,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
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

  /// Calculate priority based on ticket age
  /// Older tickets have higher priority
  String get calculatedPriority {
    final now = DateTime.now();
    final age = now.difference(createdAt);

    if (age.inDays > 3) {
      return 'Urgent';
    } else if (age.inDays >= 1) {
      return 'High';
    } else if (age.inHours >= 1) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }

  /// Get priority level (0-3) for sorting
  /// Higher number = higher priority
  int get priorityLevel {
    final now = DateTime.now();
    final age = now.difference(createdAt);

    if (age.inDays > 3) {
      return 3; // Urgent
    } else if (age.inDays >= 1) {
      return 2; // High
    } else if (age.inHours >= 1) {
      return 1; // Medium
    } else {
      return 0; // Low
    }
  }

  /// Get human-readable priority text (uses calculated priority)
  String get priorityText => calculatedPriority;

  /// Get module display text
  String get moduleText {
    return moduleName;
  }

  /// Check if ticket has an attachment
  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;

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

  /// Get priority color for UI (based on calculated priority)
  String get priorityColor {
    switch (calculatedPriority) {
      case 'Low':
        return '#4CAF50'; // Green
      case 'Medium':
        return '#FF9800'; // Orange
      case 'High':
        return '#F44336'; // Red
      case 'Urgent':
        return '#9C27B0'; // Purple
      default:
        return '#2196F3'; // Blue fallback
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