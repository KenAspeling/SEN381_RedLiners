import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campuslearn/services/api_config.dart';
import 'package:campuslearn/services/auth_service.dart';

class SearchService {
  /// Search across users, posts, and modules
  static Future<SearchResults> search(String query, {String? type}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      if (query.trim().isEmpty || query.length < 2) {
        return SearchResults(users: [], posts: [], modules: []);
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/search').replace(
        queryParameters: {
          'query': query,
          if (type != null) 'type': type,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SearchResults.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        throw Exception('Failed to search: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching: $e');
      rethrow;
    }
  }
}

class SearchResults {
  final List<UserSearchResult> users;
  final List<PostSearchResult> posts;
  final List<ModuleSearchResult> modules;

  SearchResults({
    required this.users,
    required this.posts,
    required this.modules,
  });

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    return SearchResults(
      users: (json['users'] as List<dynamic>?)
              ?.map((u) => UserSearchResult.fromJson(u))
              .toList() ??
          [],
      posts: (json['posts'] as List<dynamic>?)
              ?.map((p) => PostSearchResult.fromJson(p))
              .toList() ??
          [],
      modules: (json['modules'] as List<dynamic>?)
              ?.map((m) => ModuleSearchResult.fromJson(m))
              .toList() ??
          [],
    );
  }

  List<Map<String, dynamic>> toMapList() {
    final List<Map<String, dynamic>> results = [];

    for (var user in users) {
      results.add({
        'type': 'user',
        'userId': user.userId,
        'name': user.name,
        'email': user.email,
        'accessLevelName': user.accessLevelName,
      });
    }

    for (var post in posts) {
      results.add({
        'type': 'post',
        'postId': post.postId,
        'title': post.title,
        'content': post.content,
        'author': post.author,
        'authorEmail': post.authorEmail,
        'timeCreated': post.timeCreated.toIso8601String(),
        'typeName': post.typeName,
      });
    }

    for (var module in modules) {
      results.add({
        'type': 'module',
        'moduleId': module.moduleId,
        'name': module.name,
        'tag': module.tag,
      });
    }

    return results;
  }
}

class UserSearchResult {
  final int userId;
  final String name;
  final String email;
  final String accessLevelName;

  UserSearchResult({
    required this.userId,
    required this.name,
    required this.email,
    required this.accessLevelName,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      userId: json['userId'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      accessLevelName: json['accessLevelName'] as String? ?? 'Student',
    );
  }
}

class PostSearchResult {
  final int postId;
  final String title;
  final String content;
  final String author;
  final String authorEmail;
  final DateTime timeCreated;
  final String typeName;

  PostSearchResult({
    required this.postId,
    required this.title,
    required this.content,
    required this.author,
    required this.authorEmail,
    required this.timeCreated,
    required this.typeName,
  });

  factory PostSearchResult.fromJson(Map<String, dynamic> json) {
    return PostSearchResult(
      postId: json['postId'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      author: json['author'] as String,
      authorEmail: json['authorEmail'] as String? ?? '',
      timeCreated: DateTime.parse(json['timeCreated'] as String),
      typeName: json['typeName'] as String? ?? 'Post',
    );
  }
}

class ModuleSearchResult {
  final int moduleId;
  final String name;
  final String? tag;

  ModuleSearchResult({
    required this.moduleId,
    required this.name,
    this.tag,
  });

  factory ModuleSearchResult.fromJson(Map<String, dynamic> json) {
    return ModuleSearchResult(
      moduleId: json['moduleId'] as int,
      name: json['name'] as String,
      tag: json['tag'] as String?,
    );
  }
}
