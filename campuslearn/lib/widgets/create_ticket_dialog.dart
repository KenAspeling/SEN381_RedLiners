import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/services/ticket_service.dart';
import 'package:campuslearn/services/module_service.dart';
import 'package:campuslearn/services/notification_manager.dart';
import 'package:campuslearn/models/ticket.dart';
import 'package:campuslearn/models/module.dart';
import 'package:file_picker/file_picker.dart';

class CreateTicketDialog extends StatefulWidget {
  const CreateTicketDialog({super.key});

  @override
  State<CreateTicketDialog> createState() => _CreateTicketDialogState();
}

class _CreateTicketDialogState extends State<CreateTicketDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  List<Module> _modules = [];
  bool _isLoadingModules = true;
  Module? _selectedModule;
  bool _isSubmitting = false;

  // File upload
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadModules() async {
    try {
      // Load only the user's enrolled modules
      final modules = await ModuleService.getUserModules();
      if (mounted) {
        setState(() {
          _modules = modules;
          _isLoadingModules = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingModules = false;
        });
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick file: ${e.toString()}'),
            backgroundColor: context.appColors.error,
          ),
        );
      }
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate module selection
    if (_selectedModule == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a module for your help request'),
          backgroundColor: context.appColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = await AuthService.getUserId() ?? '';
      final userEmail = await AuthService.getUserEmail() ?? 'user@campus.edu';
      final userName = userEmail.split('@')[0];

      // If there's a file, submit in background
      if (_selectedFile != null) {
        // Close dialog immediately
        if (mounted) {
          Navigator.of(context).pop(true);

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
                    child: Text('Submitting ticket with file in background...'),
                  ),
                ],
              ),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );
        }

        // Submit in background
        _submitTicketInBackground(
          title: _titleController.text,
          content: _contentController.text,
          moduleId: _selectedModule!.moduleId,
          moduleName: _selectedModule!.name,
          studentId: userId,
          studentEmail: userEmail,
          studentName: userName,
          file: _selectedFile!,
        );
      } else {
        // No file, submit immediately (current behavior)
        await TicketService.createTicket(
          title: _titleController.text,
          content: _contentController.text,
          moduleId: _selectedModule!.moduleId,
          moduleName: _selectedModule!.name,
          studentId: userId,
          studentEmail: userEmail,
          studentName: userName,
        );

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Help request submitted successfully!'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit request: ${e.toString()}'),
            backgroundColor: context.appColors.error,
          ),
        );
      }
    }
  }

  Future<void> _submitTicketInBackground({
    required String title,
    required String content,
    required int moduleId,
    required String moduleName,
    required String studentId,
    required String studentEmail,
    required String studentName,
    required PlatformFile file,
  }) async {
    try {
      await NotificationManager().initialize();

      await TicketService.createTicket(
        title: title,
        content: content,
        moduleId: moduleId,
        moduleName: moduleName,
        studentId: studentId,
        studentEmail: studentEmail,
        studentName: studentName,
        file: file,
      );

      print('[TICKET] Background submission complete');
    } catch (e) {
      print('[TICKET] Background submission error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: 600, maxHeight: 700),
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
                      'Request Academic Help',
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

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              Icons.info_outline,
                              size: 20,
                              color: context.appColors.primary,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Select a module and describe your question clearly. Priority is automatically calculated based on how long you\'ve been waiting.',
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

                      // Title field
                      Text(
                        'Title',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'e.g., Help with integration by parts',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: context.appColors.surface,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          if (value.trim().length < 5) {
                            return 'Title must be at least 5 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Module dropdown
                      Row(
                        children: [
                          Text(
                            'Module',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                          Text(
                            ' *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      _isLoadingModules
                          ? Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: context.appColors.border),
                                borderRadius: BorderRadius.circular(8),
                                color: context.appColors.surface,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        context.appColors.primary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Loading modules...',
                                    style: TextStyle(
                                      color: context.appColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _modules.isEmpty
                              ? Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.red.withOpacity(0.1),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.warning, color: Colors.red, size: 20),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'You are not enrolled in any modules. Please contact your administrator.',
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : DropdownButtonFormField<Module>(
                                  value: _selectedModule,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: context.appColors.surface,
                                    hintText: 'Select your module',
                                  ),
                                  items: _modules.map((module) {
                                    return DropdownMenuItem(
                                      value: module,
                                      child: Text(module.displayName),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedModule = value;
                                    });
                                  },
                                ),
                      SizedBox(height: 16),

                      // Content field
                      Text(
                        'Content',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _contentController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText: 'Provide details about your question. Include any formulas, code, or specific concepts you need help with...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: context.appColors.surface,
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please describe your question';
                          }
                          if (value.trim().length < 20) {
                            return 'Please provide more details (at least 20 characters)';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // File attachment
                      Text(
                        'Attachment (Optional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (_selectedFile != null)
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
                                      _selectedFile!.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: context.appColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (_selectedFile!.size != null)
                                      Text(
                                        '${(_selectedFile!.size! / 1024).toStringAsFixed(1)} KB',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: context.appColors.textLight,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, size: 20),
                                onPressed: _removeFile,
                                color: context.appColors.error,
                              ),
                            ],
                          ),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: _pickFile,
                          icon: Icon(Icons.cloud_upload),
                          label: Text('Upload Document'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            side: BorderSide(color: context.appColors.border),
                          ),
                        ),
                    ],
                  ),
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
                    onPressed: (_isSubmitting || _modules.isEmpty) ? null : _submitTicket,
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
                    label: Text(_isSubmitting ? 'Submitting...' : 'Submit Request'),
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
