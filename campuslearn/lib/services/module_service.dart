import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campuslearn/services/api_config.dart';
import 'package:campuslearn/services/auth_service.dart';
import 'package:campuslearn/models/module.dart';

class ModuleService {
  /// Fetch all available modules
  static Future<List<Module>> getAllModules() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/modules'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Module.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load modules: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching modules: $e');
      return [];
    }
  }

  /// Fetch specific modules by IDs
  static Future<List<Module>> getModulesByIds(List<int> moduleIds) async {
    if (moduleIds.isEmpty) return [];

    try {
      final token = await AuthService.getToken();
      final idsParam = moduleIds.join(',');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/modules?ids=$idsParam'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Module.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load modules: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching modules by IDs: $e');
      return [];
    }
  }

  /// Fetch a single module by ID
  static Future<Module?> getModuleById(int moduleId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/modules/$moduleId'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return Module.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load module: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching module: $e');
      return null;
    }
  }

  /// Get user's enrolled modules (from their profile)
  static Future<List<Module>> getUserModules() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/me'),
        headers: ApiConfig.getAuthHeaders(token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        final List<int> moduleIds = (userData['moduleIds'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [];

        if (moduleIds.isEmpty) return [];

        // Fetch the full module details
        return await getModulesByIds(moduleIds);
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user modules: $e');
      return [];
    }
  }
}
