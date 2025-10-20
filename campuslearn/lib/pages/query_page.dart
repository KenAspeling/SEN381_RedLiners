import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/services/ticket_service.dart';
import 'package:campuslearn/models/ticket.dart';

class QueryPage extends StatefulWidget {
  const QueryPage({super.key});

  @override
  State<QueryPage> createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  bool _isLoading = true;
  bool _isCurrentUserTutor = false;
  List<Ticket> _tickets = [];

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
        // Tutors see all open tickets they can help with
        tickets = await TicketService.getOpenTickets();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load tickets: ${e.toString()}'),
            backgroundColor: context.appColors.error,
          ),
        );
      }
    }
  }

  Future<void> _refreshTickets() async {
    await _loadTickets();
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
                onPressed: () {
                  // TODO: Navigate to create ticket form
                },
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
                      onAction: () {
                        // TODO: Navigate to create ticket form
                      },
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
                'Help Queue',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.appColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Students waiting for help: ${_tickets.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Filter tabs (TODO: Add filtering functionality)
        Container(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _buildFilterChip('All', true),
              SizedBox(width: 8),
              _buildFilterChip('Urgent', false),
              SizedBox(width: 8),
              _buildFilterChip('Mathematics', false),
              SizedBox(width: 8),
              _buildFilterChip('Computer Science', false),
              SizedBox(width: 8),
              _buildFilterChip('Physics', false),
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
                      icon: Icons.check_circle_outline,
                      title: 'All caught up!',
                      message: 'There are no students waiting for help at the moment.',
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

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // TODO: Implement filtering
      },
      selectedColor: context.appColors.primary.withOpacity(0.2),
      checkmarkColor: context.appColors.primary,
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

            // Description
            Text(
              ticket.description,
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
                _buildInfoChip(ticket.categoryText, Icons.category),
                SizedBox(width: 8),
                _buildInfoChip(ticket.priorityText, Icons.flag),
                SizedBox(width: 8),
                _buildInfoChip(ticket.timeAgo, Icons.access_time),
                Spacer(),
                if (ticket.hasResponse)
                  Icon(
                    Icons.chat_bubble,
                    size: 16,
                    color: context.appColors.primary,
                  ),
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
        side: ticket.priority == TicketPriority.urgent
            ? BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
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
                _buildPriorityChip(ticket.priority),
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

            // Description
            Text(
              ticket.description,
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
                _buildInfoChip(ticket.categoryText, Icons.category),
                Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Navigate to ticket detail
                  },
                  icon: Icon(Icons.visibility, size: 16),
                  label: Text('View'),
                  style: TextButton.styleFrom(
                    foregroundColor: context.appColors.primary,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Claim ticket
                  },
                  icon: Icon(Icons.assignment_ind, size: 16),
                  label: Text('Help'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
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

  Widget _buildPriorityChip(TicketPriority priority) {
    Color color;
    switch (priority) {
      case TicketPriority.low:
        color = Colors.green;
        break;
      case TicketPriority.medium:
        color = Colors.orange;
        break;
      case TicketPriority.high:
        color = Colors.red;
        break;
      case TicketPriority.urgent:
        color = Colors.purple;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority.name.toUpperCase(),
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
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: context.appColors.textLight,
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