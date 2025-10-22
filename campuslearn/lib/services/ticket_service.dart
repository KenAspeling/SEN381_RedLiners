import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:campuslearn/services/api_config.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/models/ticket.dart';
import 'package:file_picker/file_picker.dart';

class TicketService {
  /// Get a single ticket by ID
  static Future<Ticket?> getTicketById(int ticketId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/querytickets/$ticketId'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Ticket.fromJson(json);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load ticket: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ticket by ID: $e');
      return null;
    }
  }

  /// Get all tickets (filtered by backend based on user role)
  static Future<List<Ticket>> getAllTickets() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/querytickets'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final tickets = jsonList.map((json) => Ticket.fromJson(json)).toList();

        // Sort by calculated priority (based on age) then by creation date (oldest first)
        tickets.sort((a, b) {
          final priorityComparison = b.priorityLevel.compareTo(a.priorityLevel);
          if (priorityComparison != 0) return priorityComparison;
          return a.createdAt.compareTo(b.createdAt);
        });

        return tickets;
      } else {
        throw Exception('Failed to load tickets: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tickets: $e');
      throw Exception('Failed to load tickets: $e');
    }
  }

  /// Get tickets by student
  static Future<List<Ticket>> getTicketsByStudent(String studentId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/querytickets/student/$studentId'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final tickets = jsonList.map((json) => Ticket.fromJson(json)).toList();
        tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return tickets;
      } else {
        throw Exception('Failed to load student tickets: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching student tickets: $e');
      throw Exception('Failed to load student tickets: $e');
    }
  }

  /// Get open tickets available for tutors to claim
  static Future<List<Ticket>> getOpenTickets() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/querytickets/open'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final tickets = jsonList.map((json) => Ticket.fromJson(json)).toList();

        // Sort by calculated priority (based on age) and creation date
        tickets.sort((a, b) {
          final priorityComparison = b.priorityLevel.compareTo(a.priorityLevel);
          if (priorityComparison != 0) return priorityComparison;
          return a.createdAt.compareTo(b.createdAt);
        });

        return tickets;
      } else {
        throw Exception('Failed to load open tickets: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching open tickets: $e');
      throw Exception('Failed to load open tickets: $e');
    }
  }

  /// Get open tickets filtered by tutor's assigned modules
  static Future<List<Ticket>> getOpenTicketsByModules(List<int> moduleIds) async {
    if (moduleIds.isEmpty) return [];

    try {
      final token = await AuthService.getToken();
      final moduleIdsParam = moduleIds.join(',');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/querytickets/open?moduleIds=$moduleIdsParam'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final tickets = jsonList.map((json) => Ticket.fromJson(json)).toList();

        // Sort by calculated priority (based on age) and creation date
        tickets.sort((a, b) {
          final priorityComparison = b.priorityLevel.compareTo(a.priorityLevel);
          if (priorityComparison != 0) return priorityComparison;
          return a.createdAt.compareTo(b.createdAt);
        });

        return tickets;
      } else {
        throw Exception('Failed to load module tickets: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching module tickets: $e');
      throw Exception('Failed to load module tickets: $e');
    }
  }

  /// Get tickets assigned to a specific tutor
  static Future<List<Ticket>> getTicketsByTutor(String tutorId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/querytickets/tutor/$tutorId'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final tickets = jsonList.map((json) => Ticket.fromJson(json)).toList();
        tickets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return tickets;
      } else {
        throw Exception('Failed to load tutor tickets: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tutor tickets: $e');
      throw Exception('Failed to load tutor tickets: $e');
    }
  }

  /// Get tickets by module
  static Future<List<Ticket>> getTicketsByModule(int moduleId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/querytickets/open?moduleIds=$moduleId'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final tickets = jsonList.map((json) => Ticket.fromJson(json)).toList();
        tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return tickets;
      } else {
        throw Exception('Failed to load module tickets: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching module tickets: $e');
      throw Exception('Failed to load module tickets: $e');
    }
  }

  /// Get tickets by status
  static Future<List<Ticket>> getTicketsByStatus(TicketStatus status) async {
    try {
      // For now, just get all tickets and filter client-side
      final tickets = await getAllTickets();
      final filtered = tickets.where((ticket) => ticket.status == status).toList();
      filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return filtered;
    } catch (e) {
      print('Error fetching tickets by status: $e');
      throw Exception('Failed to load tickets by status: $e');
    }
  }

  /// Create a new ticket (student submits help request)
  /// Priority is automatically calculated based on ticket age
  static Future<Ticket> createTicket({
    required String title,
    required String content,
    required int moduleId,
    required String moduleName,
    required String studentId,
    required String studentEmail,
    required String studentName,
    String? attachmentUrl,
    String? attachmentName,
    PlatformFile? file,
  }) async {
    try {
      if (title.trim().isEmpty) {
        throw Exception('Ticket title cannot be empty');
      }

      if (content.trim().isEmpty) {
        throw Exception('Ticket content cannot be empty');
      }

      final token = await AuthService.getToken();

      // If there's a file, use the withfile endpoint with multipart/form-data
      if (file != null && file.path != null) {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiConfig.baseUrl}/api/querytickets/withfile'),
        );

        // Add auth header
        request.headers.addAll({
          'Authorization': 'Bearer $token',
        });

        // Add form fields
        request.fields['title'] = title.trim();
        request.fields['content'] = content.trim();
        request.fields['moduleId'] = moduleId.toString();

        // Add file
        final fileBytes = await File(file.path!).readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: file.name,
        ));

        print('[TICKET] Uploading file: ${file.name} (${file.size} bytes)');

        final streamedResponse = await request.send().timeout(ApiConfig.requestTimeout);
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 201 || response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          print('[TICKET] Ticket created successfully with file');
          return Ticket.fromJson(jsonResponse);
        } else {
          throw Exception('Failed to create ticket with file: ${response.statusCode} ${response.body}');
        }
      } else {
        // No file, use the regular JSON endpoint
        final requestBody = {
          'title': title.trim(),
          'content': content.trim(),
          'moduleId': moduleId,
          'materialId': null,
        };

        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/querytickets'),
          headers: ApiConfig.getAuthHeaders(token),
          body: json.encode(requestBody),
        ).timeout(ApiConfig.requestTimeout);

        if (response.statusCode == 201 || response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          return Ticket.fromJson(jsonResponse);
        } else {
          throw Exception('Failed to create ticket: ${response.statusCode} ${response.body}');
        }
      }
    } catch (e) {
      print('Error creating ticket: $e');
      throw Exception('Failed to create ticket: $e');
    }
  }

  /// Claim a ticket (tutor takes ownership)
  static Future<Ticket> claimTicket(int ticketId, String tutorId, String tutorEmail, String tutorName) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/querytickets/$ticketId/claim'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Ticket.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to claim ticket: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error claiming ticket: $e');
      throw Exception('Failed to claim ticket: $e');
    }
  }

  /// Respond to a ticket (tutor provides solution)
  static Future<Ticket> respondToTicket({
    required int ticketId,
    required String tutorId,
    required String response,
  }) async {
    try {
      if (response.trim().isEmpty) {
        throw Exception('Response cannot be empty');
      }

      final token = await AuthService.getToken();
      final requestBody = {
        'ticketId': ticketId,
        'content': response.trim(),
        'materialId': null,
      };

      final httpResponse = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/querytickets/$ticketId/respond'),
        headers: ApiConfig.getAuthHeaders(token),
        body: json.encode(requestBody),
      ).timeout(ApiConfig.requestTimeout);

      if (httpResponse.statusCode == 200) {
        final jsonResponse = json.decode(httpResponse.body);
        return Ticket.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to respond to ticket: ${httpResponse.statusCode} ${httpResponse.body}');
      }
    } catch (e) {
      print('Error responding to ticket: $e');
      throw Exception('Failed to respond to ticket: $e');
    }
  }

  /// Close a ticket (student marks as resolved)
  /// Note: Not implemented in backend yet, keeping for future
  static Future<Ticket> closeTicket(int ticketId, String studentId, {int? rating}) async {
    throw UnimplementedError('Close ticket not implemented in backend yet');
  }

  /// Escalate a ticket (tutor marks as needing senior help)
  /// Note: Not implemented in backend yet, keeping for future
  static Future<Ticket> escalateTicket(int ticketId, String tutorId) async {
    throw UnimplementedError('Escalate ticket not implemented in backend yet');
  }

  /// Reopen a ticket (if student needs more help)
  /// Note: Not implemented in backend yet, keeping for future
  static Future<Ticket> reopenTicket(int ticketId, String studentId) async {
    throw UnimplementedError('Reopen ticket not implemented in backend yet');
  }

  /// Delete a ticket (admin/tutor privilege)
  /// Note: Not implemented in backend yet, keeping for future
  static Future<void> deleteTicket(int ticketId, String tutorId) async {
    throw UnimplementedError('Delete ticket not implemented in backend yet');
  }

  /// Get ticket statistics for dashboard
  static Future<Map<String, int>> getTicketStatistics() async {
    try {
      final tickets = await getAllTickets();

      final stats = <String, int>{
        'total': tickets.length,
        'open': tickets.where((t) => t.status == TicketStatus.open).length,
        'inProgress': tickets.where((t) => t.status == TicketStatus.inProgress).length,
        'answered': tickets.where((t) => t.status == TicketStatus.answered).length,
        'closed': tickets.where((t) => t.status == TicketStatus.closed).length,
        'escalated': tickets.where((t) => t.status == TicketStatus.escalated).length,
        'urgent': tickets.where((t) => t.priorityLevel == 3).length,
        'high': tickets.where((t) => t.priorityLevel == 2).length,
        'avgRating': _calculateAverageRating(tickets),
      };

      return stats;
    } catch (e) {
      print('Error fetching ticket statistics: $e');
      return {
        'total': 0,
        'open': 0,
        'inProgress': 0,
        'answered': 0,
        'closed': 0,
        'escalated': 0,
        'urgent': 0,
        'high': 0,
        'avgRating': 0,
      };
    }
  }

  static int _calculateAverageRating(List<Ticket> tickets) {
    final ratedTickets = tickets.where((t) => t.rating != null).toList();
    if (ratedTickets.isEmpty) return 0;

    final sum = ratedTickets.fold(0, (total, ticket) => total + ticket.rating!);
    return (sum / ratedTickets.length).round();
  }

  /// Search tickets by title or content
  static Future<List<Ticket>> searchTickets(String query, {String? studentId}) async {
    try {
      if (query.trim().isEmpty) return [];

      final tickets = studentId != null
          ? await getTicketsByStudent(studentId)
          : await getAllTickets();

      final searchQuery = query.toLowerCase().trim();
      var results = tickets.where((ticket) {
        final titleMatch = ticket.title.toLowerCase().contains(searchQuery);
        final contentMatch = ticket.content.toLowerCase().contains(searchQuery);
        final moduleMatch = ticket.moduleText.toLowerCase().contains(searchQuery);
        return titleMatch || contentMatch || moduleMatch;
      }).toList();

      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return results;
    } catch (e) {
      print('Error searching tickets: $e');
      throw Exception('Failed to search tickets: $e');
    }
  }
}
