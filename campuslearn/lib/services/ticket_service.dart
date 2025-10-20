import 'dart:math' as math;
import 'package:campuslearn/models/ticket.dart';

class TicketService {
  // Global mock data storage - simulates database
  static List<Ticket> _mockTickets = [
    Ticket(
      id: 1,
      title: 'Help with Calculus Integration',
      description: 'I\'m struggling with integration by parts. Can someone explain the step-by-step process for solving ∫x*e^x dx?',
      category: TicketCategory.mathematics,
      priority: TicketPriority.medium,
      status: TicketStatus.answered,
      studentId: '12345',
      studentEmail: 'user@campus.edu',
      studentName: 'Student User',
      tutorId: 'tutor123',
      tutorEmail: 'tutor@campus.edu',
      tutorName: 'Tutor',
      response: 'For integration by parts, use the formula ∫u dv = uv - ∫v du. \n\nFor ∫x*e^x dx:\n1. Let u = x, then du = dx\n2. Let dv = e^x dx, then v = e^x\n3. Apply formula: x*e^x - ∫e^x dx\n4. Final answer: x*e^x - e^x + C = e^x(x-1) + C',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      updatedAt: DateTime.now().subtract(Duration(hours: 6)),
      respondedAt: DateTime.now().subtract(Duration(hours: 6)),
      rating: 5,
    ),
    Ticket(
      id: 2,
      title: 'Python List Comprehension Help',
      description: 'How do I create a list of squares for even numbers from 1 to 20 using list comprehension?',
      category: TicketCategory.computerScience,
      priority: TicketPriority.low,
      status: TicketStatus.inProgress,
      studentId: '12345',
      studentEmail: 'user@campus.edu',
      studentName: 'Student User',
      tutorId: 'tutor123',
      tutorEmail: 'tutor@campus.edu',
      tutorName: 'Tutor',
      createdAt: DateTime.now().subtract(Duration(hours: 8)),
      updatedAt: DateTime.now().subtract(Duration(hours: 2)),
    ),
    Ticket(
      id: 3,
      title: 'Physics - Projectile Motion',
      description: 'Can someone help me understand how to calculate the maximum height and range of a projectile launched at 45 degrees?',
      category: TicketCategory.physics,
      priority: TicketPriority.high,
      status: TicketStatus.open,
      studentId: '67890',
      studentEmail: 'alex@campus.edu',
      studentName: 'Alex Chen',
      createdAt: DateTime.now().subtract(Duration(hours: 3)),
      updatedAt: DateTime.now().subtract(Duration(hours: 3)),
    ),
    Ticket(
      id: 4,
      title: 'Essay Writing Structure',
      description: 'I need help structuring my argumentative essay. What\'s the best way to organize my thesis and supporting arguments?',
      category: TicketCategory.writing,
      priority: TicketPriority.medium,
      status: TicketStatus.open,
      studentId: '54321',
      studentEmail: 'sarah@campus.edu',
      studentName: 'Sarah Johnson',
      createdAt: DateTime.now().subtract(Duration(minutes: 45)),
      updatedAt: DateTime.now().subtract(Duration(minutes: 45)),
    ),
  ];

  static int _nextId = 5;

  /// Get all tickets for admin/tutor view
  static Future<List<Ticket>> getAllTickets() async {
    await Future.delayed(Duration(milliseconds: 500));
    // Sort by priority (urgent first) then by creation date (newest first)
    final sortedTickets = List<Ticket>.from(_mockTickets);
    sortedTickets.sort((a, b) {
      // First sort by priority (urgent = 3, high = 2, medium = 1, low = 0)
      final aPriorityValue = a.priority == TicketPriority.urgent ? 3 :
                            a.priority == TicketPriority.high ? 2 :
                            a.priority == TicketPriority.medium ? 1 : 0;
      final bPriorityValue = b.priority == TicketPriority.urgent ? 3 :
                            b.priority == TicketPriority.high ? 2 :
                            b.priority == TicketPriority.medium ? 1 : 0;
      
      final priorityComparison = bPriorityValue.compareTo(aPriorityValue);
      if (priorityComparison != 0) return priorityComparison;
      
      // Then sort by creation date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return sortedTickets;
  }

  /// Get tickets by student
  static Future<List<Ticket>> getTicketsByStudent(String studentId) async {
    await Future.delayed(Duration(milliseconds: 300));
    final studentTickets = _mockTickets.where((ticket) => ticket.studentId == studentId).toList();
    studentTickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return studentTickets;
  }

  /// Get open tickets available for tutors to claim
  static Future<List<Ticket>> getOpenTickets() async {
    await Future.delayed(Duration(milliseconds: 400));
    final openTickets = _mockTickets.where((ticket) => 
      ticket.status == TicketStatus.open || ticket.status == TicketStatus.escalated
    ).toList();
    
    // Sort by priority and creation date
    openTickets.sort((a, b) {
      final aPriorityValue = a.priority == TicketPriority.urgent ? 3 :
                            a.priority == TicketPriority.high ? 2 :
                            a.priority == TicketPriority.medium ? 1 : 0;
      final bPriorityValue = b.priority == TicketPriority.urgent ? 3 :
                            b.priority == TicketPriority.high ? 2 :
                            b.priority == TicketPriority.medium ? 1 : 0;
      
      final priorityComparison = bPriorityValue.compareTo(aPriorityValue);
      if (priorityComparison != 0) return priorityComparison;
      
      return a.createdAt.compareTo(b.createdAt); // Oldest first for fairness
    });
    
    return openTickets;
  }

  /// Get tickets assigned to a specific tutor
  static Future<List<Ticket>> getTicketsByTutor(String tutorId) async {
    await Future.delayed(Duration(milliseconds: 300));
    final tutorTickets = _mockTickets.where((ticket) => ticket.tutorId == tutorId).toList();
    tutorTickets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return tutorTickets;
  }

  /// Get tickets by category
  static Future<List<Ticket>> getTicketsByCategory(TicketCategory category) async {
    await Future.delayed(Duration(milliseconds: 300));
    final categoryTickets = _mockTickets.where((ticket) => ticket.category == category).toList();
    categoryTickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return categoryTickets;
  }

  /// Get tickets by status
  static Future<List<Ticket>> getTicketsByStatus(TicketStatus status) async {
    await Future.delayed(Duration(milliseconds: 300));
    final statusTickets = _mockTickets.where((ticket) => ticket.status == status).toList();
    statusTickets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return statusTickets;
  }

  /// Create a new ticket (student submits help request)
  static Future<Ticket> createTicket({
    required String title,
    required String description,
    required TicketCategory category,
    required TicketPriority priority,
    required String studentId,
    required String studentEmail,
    required String studentName,
  }) async {
    await Future.delayed(Duration(milliseconds: 800));

    if (title.trim().isEmpty) {
      throw Exception('Ticket title cannot be empty');
    }

    if (description.trim().isEmpty) {
      throw Exception('Ticket description cannot be empty');
    }

    final newTicket = Ticket(
      id: _nextId++,
      title: title.trim(),
      description: description.trim(),
      category: category,
      priority: priority,
      status: TicketStatus.open,
      studentId: studentId,
      studentEmail: studentEmail,
      studentName: studentName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _mockTickets.add(newTicket);
    return newTicket;
  }

  /// Claim a ticket (tutor takes ownership)
  static Future<Ticket> claimTicket(int ticketId, String tutorId, String tutorEmail, String tutorName) async {
    await Future.delayed(Duration(milliseconds: 400));

    final ticketIndex = _mockTickets.indexWhere((ticket) => ticket.id == ticketId);
    if (ticketIndex == -1) {
      throw Exception('Ticket not found');
    }

    final ticket = _mockTickets[ticketIndex];
    if (ticket.status != TicketStatus.open && ticket.status != TicketStatus.escalated) {
      throw Exception('Ticket is not available to claim');
    }

    final updatedTicket = ticket.copyWith(
      status: TicketStatus.inProgress,
      tutorId: tutorId,
      tutorEmail: tutorEmail,
      tutorName: tutorName,
      updatedAt: DateTime.now(),
    );

    _mockTickets[ticketIndex] = updatedTicket;
    return updatedTicket;
  }

  /// Respond to a ticket (tutor provides solution)
  static Future<Ticket> respondToTicket({
    required int ticketId,
    required String tutorId,
    required String response,
  }) async {
    await Future.delayed(Duration(milliseconds: 600));

    final ticketIndex = _mockTickets.indexWhere((ticket) => ticket.id == ticketId);
    if (ticketIndex == -1) {
      throw Exception('Ticket not found');
    }

    final ticket = _mockTickets[ticketIndex];
    if (ticket.tutorId != tutorId) {
      throw Exception('You can only respond to tickets assigned to you');
    }

    if (response.trim().isEmpty) {
      throw Exception('Response cannot be empty');
    }

    final now = DateTime.now();
    final updatedTicket = ticket.copyWith(
      status: TicketStatus.answered,
      response: response.trim(),
      updatedAt: now,
      respondedAt: now,
    );

    _mockTickets[ticketIndex] = updatedTicket;
    return updatedTicket;
  }

  /// Close a ticket (student marks as resolved)
  static Future<Ticket> closeTicket(int ticketId, String studentId, {int? rating}) async {
    await Future.delayed(Duration(milliseconds: 400));

    final ticketIndex = _mockTickets.indexWhere((ticket) => ticket.id == ticketId);
    if (ticketIndex == -1) {
      throw Exception('Ticket not found');
    }

    final ticket = _mockTickets[ticketIndex];
    if (ticket.studentId != studentId) {
      throw Exception('You can only close your own tickets');
    }

    if (ticket.status == TicketStatus.closed) {
      throw Exception('Ticket is already closed');
    }

    final now = DateTime.now();
    final updatedTicket = ticket.copyWith(
      status: TicketStatus.closed,
      rating: rating,
      updatedAt: now,
      closedAt: now,
    );

    _mockTickets[ticketIndex] = updatedTicket;
    return updatedTicket;
  }

  /// Escalate a ticket (tutor marks as needing senior help)
  static Future<Ticket> escalateTicket(int ticketId, String tutorId) async {
    await Future.delayed(Duration(milliseconds: 400));

    final ticketIndex = _mockTickets.indexWhere((ticket) => ticket.id == ticketId);
    if (ticketIndex == -1) {
      throw Exception('Ticket not found');
    }

    final ticket = _mockTickets[ticketIndex];
    if (ticket.tutorId != tutorId) {
      throw Exception('You can only escalate tickets assigned to you');
    }

    final updatedTicket = ticket.copyWith(
      status: TicketStatus.escalated,
      updatedAt: DateTime.now(),
    );

    _mockTickets[ticketIndex] = updatedTicket;
    return updatedTicket;
  }

  /// Reopen a ticket (if student needs more help)
  static Future<Ticket> reopenTicket(int ticketId, String studentId) async {
    await Future.delayed(Duration(milliseconds: 400));

    final ticketIndex = _mockTickets.indexWhere((ticket) => ticket.id == ticketId);
    if (ticketIndex == -1) {
      throw Exception('Ticket not found');
    }

    final ticket = _mockTickets[ticketIndex];
    if (ticket.studentId != studentId) {
      throw Exception('You can only reopen your own tickets');
    }

    if (ticket.status != TicketStatus.closed && ticket.status != TicketStatus.answered) {
      throw Exception('Only closed or answered tickets can be reopened');
    }

    final updatedTicket = ticket.copyWith(
      status: TicketStatus.open,
      tutorId: null,
      tutorEmail: null,
      tutorName: null,
      updatedAt: DateTime.now(),
    );

    _mockTickets[ticketIndex] = updatedTicket;
    return updatedTicket;
  }

  /// Delete a ticket (admin/tutor privilege)
  static Future<void> deleteTicket(int ticketId, String tutorId) async {
    await Future.delayed(Duration(milliseconds: 300));

    final ticketIndex = _mockTickets.indexWhere((ticket) => ticket.id == ticketId);
    if (ticketIndex == -1) {
      throw Exception('Ticket not found');
    }

    _mockTickets.removeAt(ticketIndex);
  }

  /// Get ticket statistics for dashboard
  static Future<Map<String, int>> getTicketStatistics() async {
    await Future.delayed(Duration(milliseconds: 200));

    final stats = <String, int>{
      'total': _mockTickets.length,
      'open': _mockTickets.where((t) => t.status == TicketStatus.open).length,
      'inProgress': _mockTickets.where((t) => t.status == TicketStatus.inProgress).length,
      'answered': _mockTickets.where((t) => t.status == TicketStatus.answered).length,
      'closed': _mockTickets.where((t) => t.status == TicketStatus.closed).length,
      'escalated': _mockTickets.where((t) => t.status == TicketStatus.escalated).length,
      'urgent': _mockTickets.where((t) => t.priority == TicketPriority.urgent).length,
      'high': _mockTickets.where((t) => t.priority == TicketPriority.high).length,
      'avgRating': _calculateAverageRating(),
    };

    return stats;
  }

  static int _calculateAverageRating() {
    final ratedTickets = _mockTickets.where((t) => t.rating != null).toList();
    if (ratedTickets.isEmpty) return 0;
    
    final sum = ratedTickets.fold(0, (total, ticket) => total + ticket.rating!);
    return (sum / ratedTickets.length).round();
  }

  /// Search tickets by title or description
  static Future<List<Ticket>> searchTickets(String query, {String? studentId}) async {
    await Future.delayed(Duration(milliseconds: 300));

    if (query.trim().isEmpty) return [];

    final searchQuery = query.toLowerCase().trim();
    var results = _mockTickets.where((ticket) {
      final titleMatch = ticket.title.toLowerCase().contains(searchQuery);
      final descriptionMatch = ticket.description.toLowerCase().contains(searchQuery);
      final categoryMatch = ticket.categoryText.toLowerCase().contains(searchQuery);
      
      return titleMatch || descriptionMatch || categoryMatch;
    }).toList();

    // Filter by student if specified
    if (studentId != null) {
      results = results.where((ticket) => ticket.studentId == studentId).toList();
    }

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }
}