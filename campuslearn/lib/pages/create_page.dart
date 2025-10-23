import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/services/topic_service.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/services/module_service.dart';
import 'package:campuslearn/models/module.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:campuslearn/services/api_config.dart';

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
  bool _isTutor = false;
  bool _checkingAccess = true;
  bool _isCreatingTopic = false; // Toggle between Post and Topic creation
  bool _isAnonymous = false; // Post anonymously checkbox
  List<Module> _modules = [];
  Module? _selectedModule;

  @override
  void initState() {
    super.initState();
    _checkTutorAccess();
    _loadModules();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _checkTutorAccess() async {
    final isTutor = await AuthService.isTutor();
    if (mounted) {
      setState(() {
        _isTutor = isTutor;
        _checkingAccess = false;
      });
    }
  }

  Future<void> _loadModules() async {
    try {
      // Load only the user's modules (tutors can only create topics on their modules)
      final modules = await ModuleService.getUserModules();
      if (mounted) {
        setState(() {
          _modules = modules;
        });
      }
    } catch (e) {
      print('Error loading modules: $e');
    }
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

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate module selection only for topics
    if (_isCreatingTopic && _selectedModule == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a module for your topic'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      // Prepare request body based on post type
      final Map<String, dynamic> requestBody = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'type': _isCreatingTopic ? 3 : 2, // 3 = Topic, 2 = Post
        'isAnonymous': _isAnonymous,
      };

      // Only include module for topics
      if (_isCreatingTopic && _selectedModule != null) {
        requestBody['module'] = _selectedModule!.moduleId;
      }

      // Create post/topic using posts API
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/posts'),
        headers: ApiConfig.getAuthHeaders(token),
        body: json.encode(requestBody),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text(_isCreatingTopic
                      ? 'Topic created successfully!'
                      : 'Post created successfully!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Clear form
          _titleController.clear();
          _contentController.clear();
          setState(() {
            _selectedModule = null;
            _isAnonymous = false;
          });

          // Remove focus from text fields
          FocusScope.of(context).unfocus();
        }
      } else {
        throw Exception('Failed to create ${_isCreatingTopic ? "topic" : "post"}: ${response.statusCode}');
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
    // Show loading while checking access
    if (_checkingAccess) {
      return Scaffold(
        backgroundColor: context.appColors.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                  _isCreatingTopic ? 'Create New Topic' : 'Create New Post',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: context.appColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _isCreatingTopic
                      ? 'Share important information with your module'
                      : 'Share your thoughts with the campus community',
                  style: TextStyle(
                    fontSize: 16,
                    color: context.appColors.textSecondary,
                  ),
                ),

                // Toggle for tutors to switch between Post and Topic
                if (_isTutor) ...[
                  SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.appColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.appColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isCreatingTopic = false;
                                _selectedModule = null;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isCreatingTopic
                                    ? context.appColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.article,
                                    size: 18,
                                    color: !_isCreatingTopic
                                        ? Colors.white
                                        : context.appColors.textSecondary,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Post',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: !_isCreatingTopic
                                          ? Colors.white
                                          : context.appColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isCreatingTopic = true;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isCreatingTopic
                                    ? context.appColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.campaign,
                                    size: 18,
                                    color: _isCreatingTopic
                                        ? Colors.white
                                        : context.appColors.textSecondary,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Topic',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: _isCreatingTopic
                                          ? Colors.white
                                          : context.appColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 32),

                // Title Field
                Text(
                  _isCreatingTopic ? 'Topic Title' : 'Post Title',
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
                    hintText: _isCreatingTopic
                        ? 'Enter a descriptive title for your topic...'
                        : 'Enter a catchy title for your post...',
                    prefixIcon: Icon(Icons.title),
                    counterText: '${_titleController.text.length}/100',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
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
                
                // Module Selection (only for topics)
                if (_isCreatingTopic) ...[
                  SizedBox(height: 24),
                  Text(
                    'Select Module',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<Module>(
                    value: _selectedModule,
                    isExpanded: true,
                    decoration: InputDecoration(
                      hintText: 'Choose a module for this topic...',
                    ),
                    items: _modules.map((module) {
                      return DropdownMenuItem<Module>(
                        value: module,
                        child: Text(
                          module.tag ?? module.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (Module? newValue) {
                      setState(() {
                        _selectedModule = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a module for your topic';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                ],

                if (!_isCreatingTopic)
                  SizedBox(height: 24),

                // Content Field
                Text(
                  _isCreatingTopic ? 'Topic Content' : 'Post Content',
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
                      return 'Please enter some content';
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

                SizedBox(height: 16),

                // Post Anonymously Checkbox
                CheckboxListTile(
                  value: _isAnonymous,
                  onChanged: (bool? value) {
                    setState(() {
                      _isAnonymous = value ?? false;
                    });
                  },
                  title: Text(
                    'Post Anonymously',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Your role will be shown, but your name will be hidden',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),

                SizedBox(height: 16),

                // Guidelines
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
                            _isCreatingTopic ? 'Topic Guidelines' : 'Post Guidelines',
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
                        _isCreatingTopic
                            ? '• Be respectful and constructive\n'
                              '• Provide clear, accurate information\n'
                              '• Stay relevant to the module\n'
                              '• Use descriptive titles'
                            : '• Be respectful and constructive\n'
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
                        onPressed: _isLoading ? null : _submitPost,
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
                                    _isCreatingTopic ? 'Create Topic' : 'Create Post',
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