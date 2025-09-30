import 'package:harari_prosperity_app/shared/services/auth_service.dart';
import '../models/report_model.dart';
import 'database_service.dart';

class ReportService {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  static const String _tableName = 'reports';

  // Save or update a report
  Future<Report> saveReport(Report report) async {
    try {
      final user = await _authService.getCurrentUser();
      final userId = user?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final reportData = report.copyWith(
        userId: userId,
        updatedAt: DateTime.now(),
      );

      if (report.id == null) {
        // Create new report
        final newReportData = reportData.copyWith(createdAt: DateTime.now());

        final result = await _databaseService.insert(
          table: _tableName,
          data: newReportData.toJson()..remove('id'),
        );

        if (result.isNotEmpty) {
          return Report.fromJson(result.first);
        } else {
          throw Exception('Failed to create report');
        }
      } else {
        // Update existing report
        final result = await _databaseService.update(
          table: _tableName,
          data: reportData.toJson()..remove('id'),
          where: 'id',
          whereValue: report.id,
        );

        if (result.isNotEmpty) {
          return Report.fromJson(result.first);
        } else {
          throw Exception('Failed to update report');
        }
      }
    } catch (e) {
      throw Exception('Error saving report: $e');
    }
  }

  // Get all reports for current user
  Future<List<Report>> getUserReports() async {
    try {
      final user = await _authService.getCurrentUser();
      final userId = user?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final result = await _databaseService.select(
        table: _tableName,
        where: 'user_id',
        whereValue: userId,
        orderBy: 'created_at',
        ascending: false,
      );

      return result.map((json) => Report.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching reports: $e');
    }
  }

  // Get completed reports only
  Future<List<Report>> getCompletedReports() async {
    try {
      final user = await _authService.getCurrentUser();
      final userId = user?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final queryParams =
          'user_id=$userId&status=completed&_sort=created_at&_order=desc';
      final result = await _databaseService.customQuery(
        table: _tableName,
        queryParams: queryParams,
      );

      return result.map((json) => Report.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching completed reports: $e');
    }
  }

  // Get draft reports only
  Future<List<Report>> getDraftReports() async {
    try {
      final user = await _authService.getCurrentUser();
      final userId = user?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final queryParams =
          'user_id=$userId&status=draft&_sort=updated_at&_order=desc';
      final result = await _databaseService.customQuery(
        table: _tableName,
        queryParams: queryParams,
      );

      return result.map((json) => Report.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching draft reports: $e');
    }
  }

  // Get a specific report by ID
  Future<Report?> getReportById(String reportId) async {
    try {
      final user = await _authService.getCurrentUser();
      final userId = user?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final queryParams = 'id=$reportId&user_id=$userId&_limit=1';
      final result = await _databaseService.customQuery(
        table: _tableName,
        queryParams: queryParams,
      );

      if (result.isNotEmpty) {
        return Report.fromJson(result.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching report: $e');
    }
  }

  // Mark report as completed
  Future<Report> completeReport(String reportId) async {
    try {
      final user = await _authService.getCurrentUser();
      final userId = user?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final result = await _databaseService.update(
        table: _tableName,
        data: {
          'status': 'completed',
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id',
        whereValue: reportId,
      );

      if (result.isNotEmpty) {
        return Report.fromJson(result.first);
      } else {
        throw Exception('Failed to complete report');
      }
    } catch (e) {
      throw Exception('Error completing report: $e');
    }
  }

  // Delete a report
  Future<void> deleteReport(String reportId) async {
    try {
      final user = await _authService.getCurrentUser();
      final userId = user?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // First verify the report belongs to the current user
      final report = await getReportById(reportId);
      if (report == null) {
        throw Exception('Report not found or access denied');
      }

      await _databaseService.delete(
        table: _tableName,
        where: 'id',
        whereValue: reportId,
      );
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
      final user = await _authService.getCurrentUser();
      final userId = user?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final filePath = 'reports/$userId/$reportId/$fileName';

      final fileUrl = await _databaseService.uploadFile(
        fileName: filePath,
        fileBytes: fileBytes,
      );

      return fileUrl;
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
