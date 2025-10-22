import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campuslearn/main.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/services/api_config.dart';
import 'package:campuslearn/providers/theme_provider.dart';
import 'package:campuslearn/pages/register_page.dart';
import 'package:campuslearn/widgets/forgot_password_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Validate form
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call backend login API
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Extract auth data from response
        final token = responseData['token'] as String;
        final user = responseData['user'];
        final userId = user['userId'].toString();
        final email = user['email'] as String;
        final accessLevel = user['accessLevel'] as int? ?? 0;

        // Save auth data securely
        await AuthService.saveAuthData(
          token: token,
          userId: userId,
          email: email,
          accessLevel: accessLevel,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Navigate to main app
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Calculate responsive form width
  double _getFormWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return screenWidth - 48; // Full width minus padding
    } else if (screenWidth < 900) {
      return 450; // Tablet size
    } else {
      return 500; // Desktop max
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: _getFormWidth(context),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                // Logo/App Name
                Container(
                  height: 166,
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: context.appColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.school,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          return Text(
                            'Campus Learn',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDarkMode 
                                ? context.appColors.primaryLight 
                                : context.appColors.primaryDark,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),

                SizedBox(height: 10),

                // Welcome Text
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Sign in to your account',
                  style: TextStyle(
                    fontSize: 16,
                    color: context.appColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 32),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: context.appColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    return null; // No validation for now
                  },
                ),

                SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: context.appColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    return null; // No validation for now
                  },
                ),

                SizedBox(height: 24),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appColors.primary,
                    foregroundColor: context.appColors.background,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(context.appColors.background),
                          ),
                        )
                      : Text('Login'),
                ),

                SizedBox(height: 16),

                // Forgot Password
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ForgotPasswordDialog(),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    foregroundColor: context.appColors.primary,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: Text('Forgot Password?'),
                ),

                SizedBox(height: 24),

                // Test Accounts Info
                // Container(
                //   padding: EdgeInsets.all(16),
                //   decoration: BoxDecoration(
                //     color: context.appColors.primaryLight.withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(12),
                //     border: Border.all(
                //       color: context.appColors.primaryLight.withOpacity(0.3),
                //     ),
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Row(
                //         children: [
                //           Icon(
                //             Icons.info_outline,
                //             color: context.appColors.primary,
                //             size: 18,
                //           ),
                //           SizedBox(width: 8),
                //           Text(
                //             'Test Accounts',
                //             style: TextStyle(
                //               fontSize: 14,
                //               fontWeight: FontWeight.w600,
                //               color: context.appColors.primary,
                //             ),
                //           ),
                //         ],
                //       ),
                //       SizedBox(height: 8),
                //       Text(
                //         'Available accounts in database:\n'
                //         '• user@campus.edu - John Student\n'
                //         '• tutor@campus.edu - Jane Tutor\n'
                //         '• alice@campus.edu - Alice Student\n'
                //         '• bob.tutor@campus.edu - Bob Tutor\n\n'
                //         'Enter the email and password to login',
                //         style: TextStyle(
                //           fontSize: 12,
                //           color: context.appColors.textSecondary,
                //           height: 1.4,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                SizedBox(height: 24),

                // Sign Up Option
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: context.appColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterPage()),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: context.appColors.primary,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text('Sign Up'),
                      ),
                    ],
                  ),
                ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}