import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/services/auth_service.dart';

class EditProfileDialog extends StatefulWidget {
  final String currentName;
  final String currentSurname;
  final String? currentPhoneNumber;
  final String? currentDegree;
  final int? currentYearOfStudy;

  const EditProfileDialog({
    super.key,
    required this.currentName,
    required this.currentSurname,
    this.currentPhoneNumber,
    this.currentDegree,
    this.currentYearOfStudy,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _phoneController;
  late TextEditingController _degreeController;
  late TextEditingController _yearController;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _surnameController = TextEditingController(text: widget.currentSurname);
    _phoneController = TextEditingController(text: widget.currentPhoneNumber ?? '');
    _degreeController = TextEditingController(text: widget.currentDegree ?? '');
    _yearController = TextEditingController(text: widget.currentYearOfStudy?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _degreeController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedUser = await AuthService.updateProfile(
        name: _nameController.text.trim(),
        surname: _surnameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        degree: _degreeController.text.trim().isEmpty ? null : _degreeController.text.trim(),
        yearOfStudy: _yearController.text.trim().isEmpty ? null : int.tryParse(_yearController.text.trim()),
      );

      if (updatedUser != null && mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
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
        constraints: BoxConstraints(maxWidth: 500, maxHeight: 650),
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
                    Icons.edit,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'First Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        enabled: !_isSaving,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'First name is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _surnameController,
                        decoration: InputDecoration(
                          labelText: 'Last Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        enabled: !_isSaving,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Last name is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                          hintText: 'Optional',
                        ),
                        enabled: !_isSaving,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _degreeController,
                        decoration: InputDecoration(
                          labelText: 'Degree',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.school),
                          hintText: 'e.g., Computer Science',
                        ),
                        enabled: !_isSaving,
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _yearController,
                        decoration: InputDecoration(
                          labelText: 'Year of Study',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                          hintText: 'e.g., 1, 2, 3',
                        ),
                        enabled: !_isSaving,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final year = int.tryParse(value.trim());
                            if (year == null || year < 1 || year > 5) {
                              return 'Year must be between 1 and 5';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer with action buttons
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
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveProfile,
                    icon: _isSaving
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(Icons.save),
                    label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
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
