import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';

enum SearchFilter { all, users, topics, modules }

class CustomSearchDelegate extends SearchDelegate {
  SearchFilter selectedFilter = SearchFilter.all;
  final ValueNotifier<int> _rebuildNotifier = ValueNotifier<int>(0);
  // Mock data for search
  final List<Map<String, dynamic>> searchData = [
    // Topics
    {'type': 'topic', 'title': 'Introduction to Data Structures', 'author': 'John Doe', 'content': 'Binary trees and algorithms'},
    {'type': 'topic', 'title': 'Machine Learning Basics', 'author': 'Jane Smith', 'content': 'Neural networks explained'},
    {'type': 'topic', 'title': 'Database Design Project', 'author': 'Mike Johnson', 'content': 'SQL and NoSQL comparison'},
    {'type': 'topic', 'title': 'Study Group for Finals', 'author': 'Sarah Wilson', 'content': 'Computer Science finals preparation'},
    {'type': 'topic', 'title': 'Best Programming Resources', 'author': 'Alex Brown', 'content': 'Online courses and tutorials'},
    // Users
    {'type': 'user', 'name': 'John Doe', 'email': 'john@campus.edu'},
    {'type': 'user', 'name': 'Jane Smith', 'email': 'jane@campus.edu'},
    {'type': 'user', 'name': 'Mike Johnson', 'email': 'mike@campus.edu'},
    {'type': 'user', 'name': 'Sarah Wilson', 'email': 'sarah@campus.edu'},
    // Modules
    {'type': 'module', 'name': 'Computer Science 101', 'professor': 'Dr. Anderson'},
    {'type': 'module', 'name': 'Data Structures', 'professor': 'Dr. Lee'},
    {'type': 'module', 'name': 'Machine Learning', 'professor': 'Dr. Garcia'},
  ];

  @override
  String? get searchFieldLabel => 'Search posts, users, modules...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _rebuildNotifier,
      builder: (context, _, __) {
        final results = _getSearchResults();
        
        return Column(
          children: [
            _buildFilterChips(context),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: context.appColors.textLight,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No results found for "$query"',
                            style: TextStyle(
                              color: context.appColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        return _buildSearchItem(context, results[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _rebuildNotifier,
      builder: (context, _, __) {
        final suggestions = query.isEmpty ? [] : _getSearchResults();

        return Column(
          children: [
            _buildFilterChips(context),
            Expanded(
              child: query.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: context.appColors.textLight,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Start typing to search',
                            style: TextStyle(
                              color: context.appColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        return _buildSearchItem(context, suggestions[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _getSearchResults() {
    return searchData.where((item) {
      // Filter by type first
      if (selectedFilter != SearchFilter.all) {
        if (selectedFilter == SearchFilter.users && item['type'] != 'user') return false;
        if (selectedFilter == SearchFilter.topics && item['type'] != 'topic') return false;
        if (selectedFilter == SearchFilter.modules && item['type'] != 'module') return false;
      }
      
      // Then filter by search query
      final searchLower = query.toLowerCase();
      
      if (item['type'] == 'topic') {
        return item['title'].toLowerCase().contains(searchLower) ||
               item['content'].toLowerCase().contains(searchLower) ||
               item['author'].toLowerCase().contains(searchLower);
      } else if (item['type'] == 'user') {
        return item['name'].toLowerCase().contains(searchLower) ||
               item['email'].toLowerCase().contains(searchLower);
      } else if (item['type'] == 'module') {
        return item['name'].toLowerCase().contains(searchLower) ||
               item['professor'].toLowerCase().contains(searchLower);
      }
      return false;
    }).toList();
  }

  Widget _buildSearchItem(BuildContext context, Map<String, dynamic> item) {
    IconData icon;
    String title;
    String subtitle;

    switch (item['type']) {
      case 'post':
        icon = Icons.article;
        title = item['title'];
        subtitle = 'by ${item['author']}';
        break;
      case 'user':
        icon = Icons.person;
        title = item['name'];
        subtitle = item['email'];
        break;
      case 'module':
        icon = Icons.school;
        title = item['name'];
        subtitle = item['professor'];
        break;
      default:
        icon = Icons.help;
        title = 'Unknown';
        subtitle = '';
    }

    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.appColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: context.appColors.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      onTap: () {
        // Handle tap - navigate to post/user/course
        close(context, item);
        
        // Show a snackbar for now
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: $title'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return _FilterChips(
      selectedFilter: selectedFilter,
      onFilterChanged: (filter) {
        selectedFilter = filter;
        // Trigger rebuild by updating the notifier
        _rebuildNotifier.value++;
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: context.appColors.primary,
        foregroundColor: context.appColors.background,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: context.appColors.background.withOpacity(0.7)),
      ),
    );
  }
}

// Stateful widget for filter chips to handle state updates
class _FilterChips extends StatefulWidget {
  final SearchFilter selectedFilter;
  final Function(SearchFilter) onFilterChanged;

  const _FilterChips({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<_FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<_FilterChips> {
  late SearchFilter _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter;
  }

  @override
  void didUpdateWidget(_FilterChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedFilter != widget.selectedFilter) {
      _selectedFilter = widget.selectedFilter;
    }
  }

  Widget _buildChip(BuildContext context, String label, SearchFilter filter) {
    final isSelected = _selectedFilter == filter;
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected 
            ? context.appColors.background 
            : context.appColors.textPrimary,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filter;
        });
        widget.onFilterChanged(filter);
      },
      backgroundColor: context.appColors.surface,
      selectedColor: context.appColors.primary,
      checkmarkColor: context.appColors.background,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip(context, 'All', SearchFilter.all),
          SizedBox(width: 8),
          _buildChip(context, 'Users', SearchFilter.users),
          SizedBox(width: 8),
          _buildChip(context, 'Topics', SearchFilter.topics),
          SizedBox(width: 8),
          _buildChip(context, 'Modules', SearchFilter.modules),
        ],
      ),
    );
  }
}