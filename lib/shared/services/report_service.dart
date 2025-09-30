import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:harari_prosperity_app/shared/services/auth_service.dart';
import '../models/report_model.dart';
import '../config/api_config.dart';

class ReportService {
  final AuthService _authService = AuthService();

  // Helper method to get auth token
  Future<String?> _getAuthToken() async {
    final session = await _authService.getCurrentSession();
    if (session == null) {
      throw Exception('No active session found. Please log in first.');
    }
    if (session.expiresAt.isBefore(DateTime.now())) {
      throw Exception('Session expired. Please log in again.');
    }
    return session.accessToken;
  }

  // Save or update a report
  Future<Report> saveReport(Report report) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      // Use simple, manual serialization instead of model.toJson()
      final reportData = _createSimpleReportData(report);
      print('📤 Sending simple data: $reportData');

      late http.Response response;
      if (report.id == null) {
        // Create new report
        response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.reports}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(reportData),
        );
      } else {
        // Update existing report
        response = await http.put(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.reports}/${report.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(reportData),
        );
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = json.decode(response.body);
        print('📥 Received response: ${response.body}');
        return _createReportFromSimpleData(body['report'], report.id);
      } else {
        print('❌ Server error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to save report: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in saveReport: $e');
      throw Exception('Error saving report: $e');
    }
  }

  // Create simple report data map manually
  Map<String, dynamic> _createSimpleReportData(Report report) {
    return {
      'name': report.name ?? '',
      'reportType': report.reportType ?? '',
      'type': report.type ?? '',
      'receiverName': report.receiverName ?? '',
      'objective': report.objective ?? '',
      'description': report.description ?? '',
      'importance': report.importance ?? '',
      'mainPoints': report.mainPoints ?? '',
      'sources': report.sources ?? '',
      'roles': report.roles ?? '',
      'trends': report.trends ?? '',
      'themes': report.themes ?? '',
      'implications': report.implications ?? '',
      'scenarios': report.scenarios ?? '',
      'futurePlans': report.futurePlans ?? '',
      'approvingBody': report.approvingBody ?? '',
      'senderName': report.senderName ?? '',
      'role': report.role ?? '',
      'date': report.date ?? '',
      'attachments': report.attachments ?? [],
      'linkAttachment': report.linkAttachment,
      'status': report.status ?? 'draft',
    };
  }

  // Create report from simple data map
  Report _createReportFromSimpleData(
    Map<String, dynamic> data,
    String? existingId,
  ) {
    // Helper function to safely convert to string
    String safeString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map && value.containsKey('\$oid')) {
        // Handle MongoDB ObjectId format: {"$oid": "actual_id"}
        return value['\$oid'] ?? value.toString();
      }
      if (value is Map) return value.toString();
      return value.toString();
    }

    return Report(
      id: data['id'] ?? existingId,
      name: safeString(data['name']),
      reportType: safeString(data['reportType'] ?? data['report_type']),
      type: safeString(data['type']),
      receiverName: safeString(data['receiverName'] ?? data['receiver_name']),
      objective: safeString(data['objective']),
      description: safeString(data['description']),
      importance: safeString(data['importance']),
      mainPoints: safeString(data['mainPoints'] ?? data['main_points']),
      sources: safeString(data['sources']),
      roles: safeString(data['roles']),
      trends: safeString(data['trends']),
      themes: safeString(data['themes']),
      implications: safeString(data['implications']),
      scenarios: safeString(data['scenarios']),
      futurePlans: safeString(data['futurePlans'] ?? data['future_plans']),
      approvingBody: safeString(
        data['approvingBody'] ?? data['approving_body'],
      ),
      senderName: safeString(data['senderName'] ?? data['sender_name']),
      role: safeString(data['role']),
      date: safeString(data['date']),
      userId: data['userId'] != null ? safeString(data['userId']) : null,
      attachments: data['attachments'] != null
          ? List<String>.from(data['attachments'])
          : [],
      linkAttachment: data['linkAttachment'] != null
          ? safeString(data['linkAttachment'] ?? data['link_attachment'])
          : null,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(safeString(data['createdAt']))
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(safeString(data['updatedAt']))
          : DateTime.now(),
      status: safeString(data['status']),
    );
  }

  // Helper method to ensure all data is properly serialized
  Map<String, dynamic> _serializeReportData(Map<String, dynamic> data) {
    final serialized = <String, dynamic>{};

    data.forEach((key, value) {
      if (value == null) {
        serialized[key] = null;
      } else if (value is String) {
        serialized[key] = value;
      } else if (value is DateTime) {
        serialized[key] = value.toIso8601String();
      } else if (value is List) {
        serialized[key] = value;
      } else if (value is Map) {
        serialized[key] = value;
      } else {
        // Convert any other type to string
        serialized[key] = value.toString();
      }
    });

    return serialized;
  }

  // Get all reports for current user
  Future<List<Report>> getUserReports() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.reports}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final reports = body['reports'] as List;
        return reports.map((json) => Report.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch reports: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reports: $e');
    }
  }

  // Get completed reports only
  Future<List<Report>> getCompletedReports() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.reports}?status=completed'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final reports = body['reports'] as List;
        return reports.map((json) => Report.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to fetch completed reports: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching completed reports: $e');
    }
  }

  // Get draft reports only
  Future<List<Report>> getDraftReports() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.reports}?status=draft'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final reports = body['reports'] as List;
        return reports.map((json) => Report.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to fetch draft reports: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching draft reports: $e');
    }
  }

  // Get a specific report by ID
  Future<Report?> getReportById(String reportId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.reports}/$reportId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return Report.fromJson(body['report']);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching report: $e');
    }
  }

  // Mark report as completed
  Future<Report> completeReport(String reportId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      print('🔄 Completing report $reportId');
      final requestBody = json.encode({'status': 'completed'});
      print('📤 Sending completion request: $requestBody');

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.reports}/$reportId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      print(
        '📥 Completion response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        print('📥 Parsed response body: $body');
        return Report.fromJson(body['report']);
      } else {
        print('❌ Server error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to complete report: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in completeReport: $e');
      throw Exception('Error completing report: $e');
    }
  }

  // Delete a report
  Future<void> deleteReport(String reportId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.reports}/$reportId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting report: $e');
    }
  }

  // Upload file attachment
  Future<String> uploadAttachment({
    required String reportId,
    required String fileName,
    required List<int> fileBytes,
    String? contentType,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.reports}/$reportId/attachments',
        ),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        http.MultipartFile.fromBytes(
          'attachments',
          fileBytes,
          filename: fileName,
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(responseData);
        return body['report']['attachments']
            .last; // Return the URL of the uploaded file
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading attachment: $e');
    }
  }

  // Add attachment URL to report
  Future<Report> addAttachmentToReport(
    String reportId,
    String attachmentUrl,
  ) async {
    try {
      final report = await getReportById(reportId);
      if (report == null) {
        throw Exception('Report not found');
      }

      final updatedAttachments = List<String>.from(report.attachments)
        ..add(attachmentUrl);

      return await saveReport(report.copyWith(attachments: updatedAttachments));
    } catch (e) {
      throw Exception('Error adding attachment to report: $e');
    }
  }

  // Add link attachment to report
  Future<Report> addLinkToReport(String reportId, String linkUrl) async {
    try {
      final report = await getReportById(reportId);
      if (report == null) {
        throw Exception('Report not found');
      }

      return await saveReport(report.copyWith(linkAttachment: linkUrl));
    } catch (e) {
      throw Exception('Error adding link to report: $e');
    }
  }
}
