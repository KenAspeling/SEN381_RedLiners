import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/services/notification_service.dart';
import 'package:campuslearn/services/topic_service.dart';
import 'package:campuslearn/services/ticket_service.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/models/notification.dart';
import 'package:campuslearn/widgets/topic_detail_overlay.dart';
import 'package:campuslearn/widgets/ticket_detail_dialog.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _isLoading = true;
  List<AppNotification> _notifications = [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final notifications = await NotificationService.getNotifications();

      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _notifications = [];
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notifications: ${e.toString()}'),
            backgroundColor: context.appColors.error,
          ),
        );
      }
    }
  }

  Future<void> _refreshNotifications() async {
    await _loadNotifications();
  }

  List<AppNotification> _getFilteredNotifications() {
    if (_selectedFilter == 'All') {
      return _notifications;
    }

    String type;
    switch (_selectedFilter) {
      case 'Comments':
        type = NotificationTypes.comment;
        break;
      case 'Likes':
        type = NotificationTypes.like;
        break;
      case 'Messages':
        type = NotificationTypes.message;
        break;
      case 'Tickets':
        type = NotificationTypes.ticketResponse;
        break;
      default:
        return _notifications;
    }

    return NotificationService.filterByType(_notifications, type);
  }

  void _onNotificationTap(AppNotification notification) async {
    // Navigate to related content based on type
    if (notification.type == NotificationTypes.comment ||
        notification.type == NotificationTypes.newPost ||
        notification.type == NotificationTypes.newTopic) {
      // Fetch and display topic detail
      if (notification.relatedId != null) {
        try {
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: CircularProgressIndicator(),
            ),
          );

          final topic = await TopicService.getTopicById(notification.relatedId!);

          if (mounted) {
            // Close loading dialog
            Navigator.of(context).pop();

            if (topic != null) {
              // Show topic detail
              showDialog(
                context: context,
                builder: (context) => TopicDetailOverlay(
                  topic: topic,
                  onTopicUpdated: _loadNotifications,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Topic not found'),
                  backgroundColor: context.appColors.error,
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            Navigator.of(context).pop(); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load topic: ${e.toString()}'),
                backgroundColor: context.appColors.error,
              ),
            );
          }
        }
      }
    } else if (notification.type == NotificationTypes.message) {
      // Navigate to messages page
      Navigator.pushNamed(context, '/messages');
    } else if (notification.type == NotificationTypes.ticketResponse ||
               notification.type == NotificationTypes.newTicket) {
      // Fetch and display ticket detail
      if (notification.relatedId != null) {
        try {
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: CircularProgressIndicator(),
            ),
          );

          final ticket = await TicketService.getTicketById(notification.relatedId!);
          final isTutor = await AuthService.isTutor();

          if (mounted) {
            // Close loading dialog
            Navigator.of(context).pop();

            if (ticket != null) {
              // Show ticket detail
              final result = await showDialog(
                context: context,
                builder: (context) => TicketDetailDialog(
                  ticket: ticket,
                  isTutor: isTutor,
                ),
              );

              // Refresh notifications if ticket was updated
              if (result == true) {
                _loadNotifications();
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ticket not found'),
                  backgroundColor: context.appColors.error,
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            Navigator.of(context).pop(); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load ticket: ${e.toString()}'),
                backgroundColor: context.appColors.error,
              ),
            );
          }
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Content not available'),
          backgroundColor: context.appColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: context.appColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _refreshNotifications,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: context.appColors.surface,
              border: Border(
                bottom: BorderSide(color: context.appColors.border, width: 1),
              ),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildFilterChip('All', _notifications.length),
                SizedBox(width: 8),
                _buildFilterChip('Comments',
                    NotificationService.filterByType(_notifications, NotificationTypes.comment).length),
                SizedBox(width: 8),
                _buildFilterChip('Likes',
                    NotificationService.filterByType(_notifications, NotificationTypes.like).length),
                SizedBox(width: 8),
                _buildFilterChip('Messages',
                    NotificationService.filterByType(_notifications, NotificationTypes.message).length),
                SizedBox(width: 8),
                _buildFilterChip('Tickets',
                    NotificationService.filterByType(_notifications, NotificationTypes.ticketResponse).length +
                    NotificationService.filterByType(_notifications, NotificationTypes.newTicket).length),
              ],
            ),
          ),

          // Notifications list
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(context.appColors.primary),
                    ),
                  )
                : _notifications.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _refreshNotifications,
                        child: _buildNotificationsList(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            SizedBox(width: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : context.appColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? context.appColors.primary : Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      selectedColor: context.appColors.primary.withOpacity(0.2),
      checkmarkColor: context.appColors.primary,
    );
  }

  Widget _buildNotificationsList() {
    final filteredNotifications = _getFilteredNotifications();

    if (filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 64,
              color: context.appColors.textLight,
            ),
            SizedBox(height: 16),
            Text(
              'No $_selectedFilter notifications',
              style: TextStyle(
                fontSize: 16,
                color: context.appColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Group notifications by date
    final grouped = NotificationService.groupByDate(filteredNotifications);
    final keys = ['Today', 'Yesterday', 'This Week', 'This Month', 'Older'];

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: keys.where((key) => grouped.containsKey(key)).length,
      itemBuilder: (context, index) {
        final key = keys.where((k) => grouped.containsKey(k)).elementAt(index);
        final groupNotifications = grouped[key]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                key,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: context.appColors.textLight,
                ),
              ),
            ),
            ...groupNotifications.map((notification) =>
                _buildNotificationCard(notification)),
          ],
        );
      },
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final color = Color(int.parse(notification.colorHex.substring(1), radix: 16) + 0xFF000000);

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: notification.isRead ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead
              ? context.appColors.border
              : color.withOpacity(0.3),
          width: notification.isRead ? 1 : 2,
        ),
      ),
      child: InkWell(
        onTap: () => _onNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getIconData(notification.iconName),
                  color: color,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        color: context.appColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.appColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      notification.timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.appColors.textLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Unread indicator
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.only(left: 8, top: 6),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: context.appColors.textLight,
          ),
          SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'When you get new activity, it will appear here',
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'chat_bubble':
        return Icons.chat_bubble;
      case 'favorite':
        return Icons.favorite;
      case 'mail':
        return Icons.mail;
      case 'question_answer':
        return Icons.question_answer;
      case 'help':
        return Icons.help;
      default:
        return Icons.notifications;
    }
  }
}
