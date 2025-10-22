import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/models/notification.dart';
import 'package:campuslearn/services/notification_service.dart';
import 'package:campuslearn/widgets/topic_detail_overlay.dart';
import 'package:campuslearn/models/topic.dart';
import 'package:campuslearn/services/topic_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _isLoading = true;
      });

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
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.isRead) return;

    try {
      await NotificationService.markAsRead(notification.notificationId);

      if (mounted) {
        setState(() {
          final index = _notifications.indexWhere((n) => n.notificationId == notification.notificationId);
          if (index != -1) {
            _notifications[index] = AppNotification(
              notificationId: notification.notificationId,
              userId: notification.userId,
              type: notification.type,
              title: notification.title,
              message: notification.message,
              relatedId: notification.relatedId,
              timeCreated: notification.timeCreated,
              isRead: true,
            );
          }
        });
      }
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final count = await NotificationService.markAllAsRead();

      if (mounted) {
        setState(() {
          _notifications = _notifications.map((n) => AppNotification(
            notificationId: n.notificationId,
            userId: n.userId,
            type: n.type,
            title: n.title,
            message: n.message,
            relatedId: n.relatedId,
            timeCreated: n.timeCreated,
            isRead: true,
          )).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marked $count notifications as read'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark all as read: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(AppNotification notification) async {
    try {
      await NotificationService.deleteNotification(notification.notificationId);

      if (mounted) {
        setState(() {
          _notifications.removeWhere((n) => n.notificationId == notification.notificationId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleNotificationTap(AppNotification notification) async {
    // Mark as read
    await _markAsRead(notification);

    // Navigate based on type
    if (notification.relatedId != null) {
      if (notification.type == 'comment' || notification.type == 'new_topic' || notification.type == 'new_post') {
        try {
          // Fetch the topic and show detail overlay
          final topic = await TopicService.getTopicById(notification.relatedId!);

          if (mounted && topic != null) {
            showDialog(
              context: context,
              builder: (context) => TopicDetailOverlay(
                topic: topic,
                onTopicUpdated: () {
                  // Optionally refresh notifications
                },
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not open topic: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  List<AppNotification> get _filteredNotifications {
    if (_showUnreadOnly) {
      return _notifications.where((n) => !n.isRead).toList();
    }
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: context.appColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white),
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'refresh') {
                _loadNotifications();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Text('Refresh'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: context.appColors.surface,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: !_showUnreadOnly,
                  onSelected: (selected) {
                    setState(() {
                      _showUnreadOnly = false;
                    });
                  },
                  selectedColor: context.appColors.primary.withOpacity(0.2),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Unread'),
                  selected: _showUnreadOnly,
                  onSelected: (selected) {
                    setState(() {
                      _showUnreadOnly = true;
                    });
                  },
                  selectedColor: context.appColors.primary.withOpacity(0.2),
                ),
              ],
            ),
          ),

          // Notifications list
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: context.appColors.primary,
                    ),
                  )
                : _filteredNotifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: context.appColors.textLight,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _showUnreadOnly
                                  ? 'No unread notifications'
                                  : 'No notifications yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: context.appColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadNotifications,
                        child: ListView.builder(
                          itemCount: _filteredNotifications.length,
                          itemBuilder: (context, index) {
                            final notification = _filteredNotifications[index];
                            return _buildNotificationItem(notification);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    final iconData = _getIconData(notification.iconName);
    final color = Color(int.parse(notification.colorHex.substring(1), radix: 16) + 0xFF000000);

    return Dismissible(
      key: Key(notification.notificationId.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification);
      },
      child: Material(
        color: notification.isRead
            ? Colors.transparent
            : context.appColors.primary.withOpacity(0.05),
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: context.appColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
                                color: context.appColors.textPrimary,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: context.appColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.appColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'chat_bubble':
        return Icons.chat_bubble;
      case 'article':
        return Icons.article;
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
