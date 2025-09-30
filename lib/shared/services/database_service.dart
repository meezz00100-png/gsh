import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class DatabaseService {
  Future<Map<String, dynamic>?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('session');
    if (sessionJson != null) {
      final session = json.decode(sessionJson);
      return session;
    }
    return null;
  }

  // Generic method to insert data to table endpoint
  Future<List<Map<String, dynamic>>> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/${table}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['access_token']}',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final body = json.decode(response.body);
        return [body['data'] ?? body]; // return list for compatibility
      } else {
        throw Exception('Insert failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Generic method to select data
  Future<List<Map<String, dynamic>>> select({
    required String table,
    String columns = '*',
    String? where,
    dynamic whereValue,
    int? limit,
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final params = <String, String>{};
      if (where != null && whereValue != null) {
        params[where] = whereValue.toString();
      }
      if (limit != null) params['_limit'] = limit.toString();
      if (orderBy != null) {
        params['_sort'] = orderBy;
        params['_order'] = ascending ? 'asc' : 'desc';
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/${table}?${Uri(queryParameters: params).query}',
      );

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer ${token['access_token']}'},
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final results = body['data'] ?? body;
        return List<Map<String, dynamic>>.from(results);
      } else {
        throw Exception('Select failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Generic method to update data
  Future<List<Map<String, dynamic>>> update({
    required String table,
    required Map<String, dynamic> data,
    required String where,
    required dynamic whereValue,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final uri = Uri.parse('${ApiConfig.baseUrl}/${table}?$where=$whereValue');

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['access_token']}',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return [body['data'] ?? body]; // list for compatibility
      } else {
        throw Exception('Update failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Generic method to delete data
  Future<void> delete({
    required String table,
    required String where,
    required dynamic whereValue,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final uri = Uri.parse('${ApiConfig.baseUrl}/${table}?$where=$whereValue');

      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer ${token['access_token']}'},
      );

      if (response.statusCode != 204) {
        throw Exception('Delete failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Method to execute custom queries (simplified, assume GET with params)
  Future<List<Map<String, dynamic>>> customQuery({
    required String table,
    required dynamic queryParams,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final uri = Uri.parse('${ApiConfig.baseUrl}/${table}?$queryParams');

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer ${token['access_token']}'},
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return List<Map<String, dynamic>>.from(body['data'] ?? body);
      } else {
        throw Exception('Custom query failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Note: Real-time subscription not implemented in REST - use polling or webhooks
  // For now, removed as not used in app

  // File upload via POST to upload endpoint
  Future<String> uploadFile({
    required String fileName,
    required List<int> fileBytes,
    String? contentType,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final request =
          http.MultipartRequest(
              'POST',
              Uri.parse('${ApiConfig.baseUrl}/upload'),
            )
            ..headers['Authorization'] = 'Bearer ${token['access_token']}'
            ..files.add(
              http.MultipartFile.fromBytes(
                'file',
                fileBytes,
                filename: fileName,
              ),
            );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = json.decode(responseData);
        return body['url'] ?? body['fileUrl'];
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // File download (GET from URL directly, assuming public or auth)
  Future<List<int>> downloadFile(String fileUrl) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse(fileUrl),
        headers: {'Authorization': 'Bearer ${token['access_token']}'},
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Download failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete file via DELETE endpoint
  Future<void> deleteFile(String fileUrl) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/delete-file'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['access_token']}',
        },
        body: json.encode({'url': fileUrl}),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Delete file failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
