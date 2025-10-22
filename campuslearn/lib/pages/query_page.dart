import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/services/ticket_service.dart';
import 'package:campuslearn/services/module_service.dart';
import 'package:campuslearn/models/ticket.dart';
import 'package:campuslearn/widgets/create_ticket_dialog.dart';
import 'package:campuslearn/widgets/ticket_detail_dialog.dart';

class QueryPage extends StatefulWidget {
  const QueryPage({super.key});

  @override
  State<QueryPage> createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isCurrentUserTutor = false;
  List<Ticket> _tickets = [];
  int _selectedTutorTab = 0; // 0 = Available, 1 = My Assigned

  @override
  void initState() {
    super.initState();
    _checkTutorStatusAndLoadData();
  }

  Future<void> _checkTutorStatusAndLoadData() async {
    try {
      final isTutor = await AuthService.isTutor();
      if (mounted) {
        setState(() {
          _isCurrentUserTutor = isTutor;
        });
      }
      await _loadTickets();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadTickets() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      List<Ticket> tickets;
      if (_isCurrentUserTutor) {
        if (_selectedTutorTab == 0) {
          // Tab 0: Available tickets in tutor's assigned modules
          final tutorModules = await ModuleService.getUserModules();
          final moduleIds = tutorModules.map((module) => module.moduleId).toList();
          tickets = await TicketService.getOpenTicketsByModules(moduleIds);
        } else {
          // Tab 1: Tickets assigned to this tutor
          final tutorId = await AuthService.getUserId() ?? '';
          tickets = await TicketService.getTicketsByTutor(tutorId);
        }
      } else {
        // Students see their own tickets
        final userId = await AuthService.getUserId() ?? '';
        tickets = await TicketService.getTicketsByStudent(userId);
      }

      if (mounted) {
        setState(() {
          _tickets = tickets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _tickets = [];
          _isLoading = false;
        });
      }

      if (mounted) {
        // Check if it's an authentication error
        String errorMessage = 'Failed to load tickets';
        if (e.toString().contains('401')) {
          errorMessage = 'Please log in to view tickets';
        } else if (e.toString().contains('403')) {
          errorMessage = 'You do not have permission to view these tickets';
        } else {
          errorMessage = 'Failed to load tickets: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: context.appColors.error,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _refreshTickets() async {
    await _loadTickets();
  }

  Future<void> _showCreateTicketDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CreateTicketDialog(),
    );

    // Refresh tickets list if ticket was created successfully
    if (result == true) {
      await _refreshTickets();
    }
  }

  Future<void> _showTicketDetailDialog(Ticket ticket) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TicketDetailDialog(
        ticket: ticket,
        isTutor: _isCurrentUserTutor,
      ),
    );

    // Refresh tickets list if ticket was claimed
    if (result == true) {
      await _refreshTickets();
    }
  }

  Widget _buildStudentView() {
    return Column(
      children: [
        // Header with create ticket button
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            border: Border(
              bottom: BorderSide(color: context.appColors.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Help Requests',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Submit questions and track your help requests',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showCreateTicketDialog,
                icon: Icon(Icons.add),
                label: Text('Ask for Help'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Tickets list
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(context.appColors.primary),
                  ),
                )
              : _tickets.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.help_outline,
                      title: 'No help requests yet',
                      message: 'When you need academic help, create a ticket and our tutors will assist you!',
                      actionText: 'Ask Your First Question',
                      onAction: _showCreateTicketDialog,
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshTickets,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _tickets.length,
                        itemBuilder: (context, index) {
                          final ticket = _tickets[index];
                          return _buildStudentTicketCard(ticket);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildTutorView() {
    return Column(
      children: [
        // Header with statistics
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            border: Border(
              bottom: BorderSide(color: context.appColors.border, width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedTutorTab == 0 ? 'Help Queue' : 'My Assigned Tickets',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.appColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                _selectedTutorTab == 0
                    ? 'Students waiting for help: ${_tickets.length}'
                    : 'Tickets you are helping with: ${_tickets.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Tab buttons
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            border: Border(
              bottom: BorderSide(color: context.appColors.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  label: 'Available',
                  icon: Icons.queue,
                  isSelected: _selectedTutorTab == 0,
                  onTap: () {
                    setState(() {
                      _selectedTutorTab = 0;
                    });
                    _loadTickets();
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildTabButton(
                  label: 'My Assigned',
                  icon: Icons.assignment_ind,
                  isSelected: _selectedTutorTab == 1,
                  onTap: () {
                    setState(() {
                      _selectedTutorTab = 1;
                    });
                    _loadTickets();
                  },
                ),
              ),
            ],
          ),
        ),

        // Tickets queue
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(context.appColors.primary),
                  ),
                )
              : _tickets.isEmpty
                  ? _buildEmptyState(
                      icon: _selectedTutorTab == 0
                          ? Icons.check_circle_outline
                          : Icons.assignment_outlined,
                      title: _selectedTutorTab == 0
                          ? 'All caught up!'
                          : 'No assigned tickets',
                      message: _selectedTutorTab == 0
                          ? 'There are no students waiting for help at the moment.'
                          : 'You haven\'t claimed any tickets yet. Switch to Available tab to help students.',
                      actionText: null,
                      onAction: null,
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshTickets,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _tickets.length,
                        itemBuilder: (context, index) {
                          final ticket = _tickets[index];
                          return _buildTutorTicketCard(ticket);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? context.appColors.primary
              : context.appColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? context.appColors.primary
                : context.appColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : context.appColors.textSecondary,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : context.appColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentTicketCard(Ticket ticket) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                ),
                _buildStatusChip(ticket.status),
              ],
            ),
            SizedBox(height: 8),

            // Content
            Text(
              ticket.content,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12),

            // Metadata row
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(ticket.moduleText, Icons.book),
                ),
                SizedBox(width: 8),
                _buildInfoChip(ticket.timeAgo, Icons.access_time),
                if (ticket.hasResponse) ...[
                  SizedBox(width: 8),
                  Icon(
                    Icons.chat_bubble,
                    size: 16,
                    color: context.appColors.primary,
                  ),
                ],
              ],
            ),

            // Response preview if available
            if (ticket.hasResponse) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.appColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: context.appColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          ticket.tutorName ?? 'Tutor',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.appColors.primary,
                          ),
                        ),
                        Spacer(),
                        if (ticket.formattedResponseTime != null)
                          Text(
                            'Responded in ${ticket.formattedResponseTime}',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.appColors.textLight,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      ticket.response!,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.appColors.textSecondary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTutorTicketCard(Ticket ticket) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: ticket.priorityLevel == 3 // 3 = Urgent
            ? BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showTicketDetailDialog(ticket),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                ),
                _buildPriorityChip(ticket.calculatedPriority),
              ],
            ),
            SizedBox(height: 4),

            // Student info
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: context.appColors.textLight,
                ),
                SizedBox(width: 4),
                Text(
                  ticket.studentName,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appColors.textLight,
                  ),
                ),
                SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: context.appColors.textLight,
                ),
                SizedBox(width: 4),
                Text(
                  'Asked ${ticket.timeAgo}',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appColors.textLight,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Content
            Text(
              ticket.content,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(ticket.moduleText, Icons.book),
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showTicketDetailDialog(ticket),
                  icon: Icon(Icons.visibility, size: 16),
                  label: Text('View'),
                  style: TextButton.styleFrom(
                    foregroundColor: context.appColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                SizedBox(width: 4),
                ElevatedButton.icon(
                  onPressed: () => _showTicketDetailDialog(ticket),
                  icon: Icon(Icons.assignment_ind, size: 16),
                  label: Text('Help'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(TicketStatus status) {
    Color color;
    switch (status) {
      case TicketStatus.open:
        color = Colors.blue;
        break;
      case TicketStatus.inProgress:
        color = Colors.orange;
        break;
      case TicketStatus.answered:
        color = Colors.green;
        break;
      case TicketStatus.closed:
        color = Colors.grey;
        break;
      case TicketStatus.escalated:
        color = Colors.red;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status == TicketStatus.open ? 'Open' :
        status == TicketStatus.inProgress ? 'In Progress' :
        status == TicketStatus.answered ? 'Answered' :
        status == TicketStatus.closed ? 'Closed' : 'Escalated',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String calculatedPriority) {
    Color color;
    switch (calculatedPriority) {
      case 'Low':
        color = Colors.green;
        break;
      case 'Medium':
        color = Colors.orange;
        break;
      case 'High':
        color = Colors.red;
        break;
      case 'Urgent':
        color = Colors.purple;
        break;
      default:
        color = Colors.blue;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        calculatedPriority.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: context.appColors.textLight,
          ),
          SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: context.appColors.textLight,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: context.appColors.textLight,
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.appColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: context.appColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(Icons.add),
                label: Text(actionText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: _isCurrentUserTutor ? _buildTutorView() : _buildStudentView(),
    );
  }
}