import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campuslearn/pages/home_page.dart';
import 'package:campuslearn/pages/create_page.dart';
import 'package:campuslearn/pages/message_page.dart';
import 'package:campuslearn/pages/notification_page.dart';
import 'package:campuslearn/pages/notifications_page.dart';
import 'package:campuslearn/services/notification_service.dart';
import 'package:campuslearn/services/firebase_service.dart';
import 'dart:async';
import 'package:campuslearn/pages/query_page.dart';
import 'package:campuslearn/pages/profile_page.dart';
import 'package:campuslearn/pages/settings_page.dart';
import 'package:campuslearn/pages/help_page.dart';
import 'package:campuslearn/pages/about_page.dart';
import 'package:campuslearn/pages/login_page.dart';
import 'package:campuslearn/pages/chatbot_page.dart';
import 'package:campuslearn/widgets/app_drawer.dart';
import 'package:campuslearn/widgets/left_sidebar.dart';
import 'package:campuslearn/widgets/search_delegate.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/providers/theme_provider.dart';
import 'package:campuslearn/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider()..initialize(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          if (themeProvider.isLoading) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          
          return MaterialApp(
      title: 'Campus Learn', 
            theme: AppTheme.generateTheme(themeProvider),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      setState(() {
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });
      
      // Show auto login popup if user is automatically logged in
      if (isLoggedIn && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Auto Login - Welcome back!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
      }
    } catch (e) {
      print('Error checking auth status: $e');
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.appColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  color: context.appColors.background,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Campus Learn',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.appColors.primary,
                ),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.appColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _isLoggedIn ? const MainScreen() : const LoginPage();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    CreatePage(),
    MessagePage(),
    QueryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(top: 8),
        child: InkResponse(
          onTap: () => _onItemTapped(index),
          splashColor: context.appColors.background.withOpacity(0.3),
          highlightColor: Colors.transparent,
          radius: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected 
                  ? Colors.white 
                  : context.appColors.overlay,
                size: 24,
              ),
              if (isSelected) ...[
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Check if screen is desktop size
  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width > 900;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDesktop = _isDesktop(context);

        if (isDesktop) {
          // Desktop layout with sidebars
          return Scaffold(
            floatingActionButton: _selectedIndex == 2 ? null : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatbotPage()),
                );
              },
              backgroundColor: context.appColors.primary,
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
              ),
            ),
            appBar: AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Icon(
                      Icons.school,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Campus Learn',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              backgroundColor: context.appColors.primary,
              foregroundColor: context.appColors.background,
              automaticallyImplyLeading: false, // Remove hamburger menu on desktop
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(),
                    );
                  },
                ),
                const NotificationBellButton(),
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    );
                  },
                ),
              ],
            ),
            body: Row(
              children: [
                // Left sidebar with navigation
                LeftSidebar(
                  selectedIndex: _selectedIndex,
                  onNavigationTap: _onItemTapped,
                ),
                // Main content area
                Expanded(
                  child: Container(
                    color: context.appColors.background,
                    child: _pages.elementAt(_selectedIndex),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Mobile/tablet layout with bottom navigation
          return Scaffold(
            floatingActionButton: _selectedIndex == 2 ? null : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatbotPage()),
                );
              },
              backgroundColor: context.appColors.primary,
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            drawer: const AppDrawer(),
            appBar: AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Icon(
                      Icons.school,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Campus Learn',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              backgroundColor: context.appColors.primary,
              foregroundColor: context.appColors.background,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(),
                    );
                  },
                ),
                const NotificationBellButton(),
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    );
                  },
                ),
              ],
            ),
            body: Center(
              child: _pages.elementAt(_selectedIndex),
            ),
            bottomNavigationBar: Material(
              color: context.appColors.primary,
              elevation: 8,
              child: SafeArea(
                top: false,
                child: Container(
                  height: kBottomNavigationBarHeight + 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(context, 0, Icons.home, 'Home'),
                      _buildNavItem(context, 3, Icons.live_help, 'Tickets'),
                      _buildNavItem(context, 1, Icons.add_box, 'Create'),
                      _buildNavItem(context, 2, Icons.message, 'Messages'),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

// Notification bell button with unread count badge
class NotificationBellButton extends StatefulWidget {
  const NotificationBellButton({super.key});

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton> {
  int _unreadCount = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();

    // Refresh unread count every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadUnreadCount();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await NotificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      // Silently fail - don't show error for background refresh
      print('Error loading unread count: $e');
    }
  }

  void _navigateToNotifications() async {
    // Navigate to notifications page
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsPage()),
    );

    // Refresh count after returning from notifications page
    _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: _navigateToNotifications,
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}