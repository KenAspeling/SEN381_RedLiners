import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/services/auth_service.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final PageController _pageController = PageController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.requestPasswordReset(_emailController.text.trim());

      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentStep = 1;
        });
        _pageController.animateToPage(
          1,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset code sent to your email! Check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reset code: ${e.toString()}'),
            backgroundColor: context.appColors.error,
          ),
        );
      }
    }
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final isValid = await AuthService.verifyResetCode(
        _emailController.text.trim(),
        _codeController.text.trim(),
      );

      if (mounted) {
        if (isValid) {
          setState(() {
            _isLoading = false;
            _currentStep = 2;
          });
          _pageController.animateToPage(
            2,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid or expired code'),
              backgroundColor: context.appColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying code: ${e.toString()}'),
            backgroundColor: context.appColors.error,
          ),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.resetPassword(
        _emailController.text.trim(),
        _codeController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Password reset successfully! You can now log in.'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset password: ${e.toString()}'),
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
        constraints: BoxConstraints(maxWidth: 500, maxHeight: 550),
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
                    Icons.lock_reset,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Progress indicator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  _buildStepIndicator(0, 'Email'),
                  Expanded(child: Divider()),
                  _buildStepIndicator(1, 'Code'),
                  Expanded(child: Divider()),
                  _buildStepIndicator(2, 'Password'),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildEmailStep(),
                    _buildCodeStep(),
                    _buildPasswordStep(),
                  ],
                ),
              ),
            ),

            // Footer
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
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: _isLoading ? null : () {
                        setState(() {
                          _currentStep--;
                        });
                        _pageController.animateToPage(
                          _currentStep,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text('Back'),
                    ),
                  if (_currentStep > 0) SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      if (_currentStep == 0) {
                        _sendResetCode();
                      } else if (_currentStep == 1) {
                        _verifyCode();
                      } else {
                        _resetPassword();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.appColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _currentStep == 0 ? 'Send Code' :
                            _currentStep == 1 ? 'Verify Code' : 'Reset Password',
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

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? context.appColors.primary : context.appColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? context.appColors.primary : context.appColors.border,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : context.appColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? context.appColors.primary : context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your email address',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'We\'ll send you a verification code to reset your password.',
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
            ),
          ),
          SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCodeStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter verification code',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'A 6-digit code has been sent to your email. Please check your inbox and spam folder (expires in 15 minutes).',
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
            ),
          ),
          SizedBox(height: 24),
          TextFormField(
            controller: _codeController,
            decoration: InputDecoration(
              labelText: 'Verification Code',
              prefixIcon: Icon(Icons.key),
              border: OutlineInputBorder(),
              hintText: '000000',
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            enabled: !_isLoading,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Code is required';
              }
              if (value.trim().length != 6) {
                return 'Code must be 6 digits';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create new password',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Choose a strong password to secure your account.',
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
            ),
          ),
          SizedBox(height: 24),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'New Password',
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(),
            ),
            obscureText: _obscurePassword,
            enabled: !_isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(),
            ),
            obscureText: _obscureConfirmPassword,
            enabled: !_isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
