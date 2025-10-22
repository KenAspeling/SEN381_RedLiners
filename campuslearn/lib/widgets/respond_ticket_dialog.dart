import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/services/ticket_service.dart';
import 'package:campuslearn/models/ticket.dart';

class RespondTicketDialog extends StatefulWidget {
  final Ticket ticket;

  const RespondTicketDialog({
    super.key,
    required this.ticket,
  });

  @override
  State<RespondTicketDialog> createState() => _RespondTicketDialogState();
}

class _RespondTicketDialogState extends State<RespondTicketDialog> {
  final _formKey = GlobalKey<FormState>();
  final _responseController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _submitResponse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final tutorId = await AuthService.getUserId() ?? '';

      await TicketService.respondToTicket(
        ticketId: widget.ticket.id,
        tutorId: tutorId,
        response: _responseController.text,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Response submitted successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit response: ${e.toString()}'),
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
        constraints: BoxConstraints(maxWidth: 700, maxHeight: 700),
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
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Provide Solution',
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
                    // Ticket info summary
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.appColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: context.appColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.book,
                                size: 16,
                                color: context.appColors.primary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                widget.ticket.moduleText,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.appColors.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.ticket.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.ticket.content,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.appColors.textSecondary,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Help text
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.appColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 20,
                            color: context.appColors.primary,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Provide a clear, detailed solution to help the student understand. Include step-by-step explanations when possible.',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.appColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Response form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Solution',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _responseController,
                            maxLines: 10,
                            decoration: InputDecoration(
                              hintText: 'Type your detailed solution here...\n\nFor example:\n"To solve this problem, follow these steps:\n1. Start by...\n2. Then...\n3. Finally..."',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: context.appColors.surface,
                              alignLabelWithHint: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please provide a solution';
                              }
                              if (value.trim().length < 20) {
                                return 'Please provide a more detailed solution (at least 20 characters)';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer with actions
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
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitResponse,
                    icon: _isSubmitting
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(Icons.send),
                    label: Text(_isSubmitting ? 'Submitting...' : 'Submit Solution'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.appColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      disabledBackgroundColor: Colors.grey,
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
}
