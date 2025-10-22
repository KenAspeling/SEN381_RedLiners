import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/services/ticket_service.dart';
import 'package:campuslearn/services/download_service.dart';
import 'package:campuslearn/services/notification_manager.dart';
import 'package:campuslearn/models/ticket.dart';
import 'package:campuslearn/widgets/respond_ticket_dialog.dart';

class TicketDetailDialog extends StatefulWidget {
  final Ticket ticket;
  final bool isTutor;

  const TicketDetailDialog({
    super.key,
    required this.ticket,
    required this.isTutor,
  });

  @override
  State<TicketDetailDialog> createState() => _TicketDetailDialogState();
}

class _TicketDetailDialogState extends State<TicketDetailDialog> {
  bool _isClaiming = false;

  Future<void> _downloadFile() async {
    if (widget.ticket.materialId == null || widget.ticket.fileName == null) return;

    try {
      // Initialize notification manager
      await NotificationManager().initialize();

      // Queue download in background
      await DownloadService().addDownload(
        materialId: widget.ticket.materialId!,
        fileName: widget.ticket.fileName!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Download started in background'),
                ),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start download: ${e.toString()}'),
            backgroundColor: context.appColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showRespondDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => RespondTicketDialog(ticket: widget.ticket),
    );

    // Close this dialog and refresh if response was submitted
    if (result == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _claimTicket() async {
    setState(() {
      _isClaiming = true;
    });

    try {
      final tutorId = await AuthService.getUserId() ?? '';
      final tutorEmail = await AuthService.getUserEmail() ?? '';
      final tutorName = tutorEmail.split('@')[0]; // Basic fallback

      await TicketService.claimTicket(
        widget.ticket.id,
        tutorId,
        tutorEmail,
        tutorName,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Ticket claimed successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isClaiming = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to claim ticket: ${e.toString()}'),
            backgroundColor: context.appColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: 700, maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.appColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Help Request Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Priority and Module badges
                    Row(
                      children: [
                        _buildPriorityBadge(widget.ticket.calculatedPriority),
                        SizedBox(width: 8),
                        Expanded(child: _buildModuleBadge(widget.ticket.moduleText)),
                        SizedBox(width: 8),
                        _buildStatusBadge(widget.ticket.statusText),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Title
                    Text(
                      widget.ticket.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12),

                    // Student info
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.appColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: context.appColors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: context.appColors.primary,
                            child: Text(
                              widget.ticket.studentName[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.ticket.studentName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: context.appColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  widget.ticket.studentEmail,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.appColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Submitted',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.appColors.textLight,
                                ),
                              ),
                              Text(
                                widget.ticket.timeAgo,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: context.appColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Content section
                    Text(
                      'Question Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.appColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: context.appColors.border),
                      ),
                      child: Text(
                        widget.ticket.content,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                    ),

                    // Attachment if available
                    if (widget.ticket.materialId != null && widget.ticket.fileName != null) ...[
                      SizedBox(height: 16),
                      Text(
                        'Attachment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.appColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: context.appColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.attach_file,
                              color: context.appColors.primary,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.ticket.fileName!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: context.appColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (widget.ticket.fileSize != null)
                                    Text(
                                      '${(widget.ticket.fileSize! / 1024).toStringAsFixed(1)} KB',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.appColors.textLight,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _downloadFile,
                              icon: Icon(Icons.download, size: 18),
                              label: Text('Download'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.appColors.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer with action buttons
            if (widget.isTutor)
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  border: Border(
                    top: BorderSide(color: context.appColors.border),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isClaiming ? null : () => Navigator.of(context).pop(),
                      child: Text('Close'),
                    ),
                    SizedBox(width: 12),
                    // Show "Claim Ticket" button for open/escalated tickets
                    if (widget.ticket.status == TicketStatus.open ||
                        widget.ticket.status == TicketStatus.escalated)
                      ElevatedButton.icon(
                        onPressed: _isClaiming ? null : _claimTicket,
                        icon: _isClaiming
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(Icons.check),
                        label: Text(_isClaiming ? 'Claiming...' : 'Claim Ticket'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.appColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          disabledBackgroundColor: Colors.grey,
                        ),
                      ),
                    // Show "Provide Solution" button for in-progress tickets
                    if (widget.ticket.status == TicketStatus.inProgress)
                      ElevatedButton.icon(
                        onPressed: _showRespondDialog,
                        icon: Icon(Icons.send),
                        label: Text('Provide Solution'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    switch (priority) {
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            priority.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleBadge(String module) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.appColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.book, size: 14, color: context.appColors.primary),
          SizedBox(width: 4),
          Flexible(
            child: Text(
              module,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.appColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Open':
        color = Colors.blue;
        break;
      case 'In Progress':
        color = Colors.orange;
        break;
      case 'Answered':
        color = Colors.green;
        break;
      case 'Closed':
        color = Colors.grey;
        break;
      case 'Escalated':
        color = Colors.red;
        break;
      default:
        color = Colors.blue;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
