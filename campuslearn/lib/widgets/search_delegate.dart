import 'package:flutter/material.dart';
import 'package:campuslearn/theme/theme_extensions.dart';
import 'package:campuslearn/services/search_service.dart';
import 'package:campuslearn/services/topic_service.dart';
import 'package:campuslearn/widgets/topic_detail_overlay.dart';
import 'package:campuslearn/pages/user_profile_page.dart';

enum SearchFilter { all, users, topics }

class CustomSearchDelegate extends SearchDelegate {
  SearchFilter selectedFilter = SearchFilter.all;
  final ValueNotifier<int> _rebuildNotifier = ValueNotifier<int>(0);
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String _lastQuery = '';

  @override
  String? get searchFieldLabel => 'Search posts and users...';

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

  Future<void> _performSearch(String searchQuery) async {
    if (searchQuery.isEmpty || searchQuery.length < 2) {
      _searchResults = [];
      _isLoading = false;
      _rebuildNotifier.value++;
      return;
    }

    if (_lastQuery == searchQuery) {
      return; // Don't search again if query hasn't changed
    }

    _lastQuery = searchQuery;
    _isLoading = true;
    _rebuildNotifier.value++;

    try {
      String? typeFilter;
      if (selectedFilter == SearchFilter.users) {
        typeFilter = 'users';
      } else if (selectedFilter == SearchFilter.topics) {
        typeFilter = 'posts';
      }

      final results = await SearchService.search(searchQuery, type: typeFilter);
      final allResults = results.toMapList();

      // Filter out module results since we don't support them anymore
      _searchResults = allResults.where((item) => item['type'] != 'module').toList();
    } catch (e) {
      print('Search error: $e');
      _searchResults = [];
    } finally {
      _isLoading = false;
      _rebuildNotifier.value++;
    }
  }

  @override
  Widget buildResults(BuildContext context) {
    _performSearch(query);

    return ValueListenableBuilder<int>(
      valueListenable: _rebuildNotifier,
      builder: (context, _, __) {
        return Column(
          children: [
            _buildFilterChips(context),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
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
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            return _buildSearchItem(context, _searchResults[index]);
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
    if (query.isNotEmpty && query.length >= 2) {
      _performSearch(query);
    }

    return ValueListenableBuilder<int>(
      valueListenable: _rebuildNotifier,
      builder: (context, _, __) {
        return Column(
          children: [
            _buildFilterChips(context),
            Expanded(
              child: query.isEmpty || query.length < 2
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
                            'Type at least 2 characters to search',
                            style: TextStyle(
                              color: context.appColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _searchResults.isEmpty
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
                                    'No results found',
                                    style: TextStyle(
                                      color: context.appColors.textSecondary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                return _buildSearchItem(context, _searchResults[index]);
                              },
                            ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildSearchItem(BuildContext context, Map<String, dynamic> item) {
    IconData icon;
    String title;
    String subtitle;

    switch (item['type']) {
      case 'post':
        icon = Icons.article;
        title = item['title'] ?? 'Untitled';
        subtitle = 'by ${item['author'] ?? 'Unknown'}';
        break;
      case 'user':
        icon = Icons.person;
        title = item['name'] ?? 'Unknown User';
        subtitle = '${item['email'] ?? ''} • ${item['accessLevelName'] ?? 'Student'}';
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
      onTap: () async {
        close(context, null);

        // Navigate based on item type
        if (item['type'] == 'post') {
          // Fetch full topic details and show detail overlay
          try {
            // Show loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Center(
                child: CircularProgressIndicator(),
              ),
            );

            final topic = await TopicService.getTopicById(item['postId']);

            if (context.mounted) {
              // Close loading dialog
              Navigator.of(context).pop();

              if (topic != null) {
                // Show topic detail
                showDialog(
                  context: context,
                  builder: (context) => TopicDetailOverlay(
                    topic: topic,
                    onTopicUpdated: () {
                      // Optionally refresh something
                    },
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Topic not found'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.of(context).pop(); // Close loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load topic: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else if (item['type'] == 'user') {
          // Navigate to user profile
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserProfilePage(
                userId: item['userId'],
                userName: item['name'],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return _FilterChips(
      selectedFilter: selectedFilter,
      onFilterChanged: (filter) {
        selectedFilter = filter;
        // Reset last query to trigger new search with updated filter
        _lastQuery = '';
        // Perform search again with new filter
        if (query.isNotEmpty && query.length >= 2) {
          _performSearch(query);
        }
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
        ],
      ),
    );
  }
}