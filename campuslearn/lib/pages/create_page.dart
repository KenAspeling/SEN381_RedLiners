import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/services/topic_service.dart';
import 'package:campuslearn/services/auth_service.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Calculate responsive form width
  double _getFormWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return screenWidth - 32; // Full width minus padding on mobile
    } else if (screenWidth < 900) {
      return 500; // Tablet size
    } else {
      return 600; // Desktop max
    }
  }

  Future<void> _createTopic() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user info
      final userEmail = await AuthService.getUserEmail() ?? 'user@campus.edu';
      final userData = await AuthService.getUserDataFromToken();
      final userName = userData?['email']?.split('@')[0] ?? 'Student';

      // Create the post
      await TopicService.createTopic(
        title: _titleController.text,
        content: _contentController.text,
        authorName: userName,
        authorEmail: userEmail,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Topic created successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Clear form
        _titleController.clear();
        _contentController.clear();
        
        // Remove focus from text fields
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: _getFormWidth(context),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Header
                SizedBox(height: 20),
                Text(
                  'Create New Topic',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: context.appColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Share your thoughts with the campus community',
                  style: TextStyle(
                    fontSize: 16,
                    color: context.appColors.textSecondary,
                  ),
                ),
                
                SizedBox(height: 32),

                // Title Field
                Text(
                  'Topic Title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  maxLength: 100,
                  decoration: InputDecoration(
                    hintText: 'Enter a catchy title for your topic...',
                    prefixIcon: Icon(Icons.title),
                    counterText: '${_titleController.text.length}/100',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title for your topic';
                    }
                    if (value.trim().length < 3) {
                      return 'Title must be at least 3 characters long';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {}); // Update character counter
                  },
                ),
                
                SizedBox(height: 24),

                // Content Field
                Text(
                  'Topic Content',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  maxLines: 8,
                  maxLength: 2000,
                  decoration: InputDecoration(
                    hintText: 'What\'s on your mind? Share your thoughts, questions, or experiences...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 100),
                      child: Icon(Icons.edit_note),
                    ),
                    counterText: '${_contentController.text.length}/2000',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter some content for your topic';
                    }
                    if (value.trim().length < 10) {
                      return 'Content must be at least 10 characters long';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {}); // Update character counter
                  },
                ),
                
                SizedBox(height: 32),

                // Topic Guidelines
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.appColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.appColors.primaryLight.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: context.appColors.primary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Topic Guidelines',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.appColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Be respectful and constructive\n'
                        '• Stay on topic and relevant to campus life\n'
                        '• No spam, harassment, or inappropriate content\n'
                        '• Use clear, descriptive titles',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () {
                          _titleController.clear();
                          _contentController.clear();
                          FocusScope.of(context).unfocus();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: context.appColors.textSecondary),
                        ),
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 16),
                    
                    // Create Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createTopic,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.appColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Create',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}