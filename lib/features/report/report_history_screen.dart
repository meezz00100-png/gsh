import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/shared/services/report_service.dart';
import 'package:harari_prosperity_app/shared/models/report_model.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  final ReportService _reportService = ReportService();
  List<Report> _completedReports = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCompletedReports();
  }

  Future<void> _loadCompletedReports() async {
    setState(() => _isLoading = true);
    try {
      final reports = await _reportService.getCompletedReports();
      setState(() {
        _completedReports = reports;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load reports: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshReports() async {
    await _loadCompletedReports();
  }

  void _showReportDetails(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report.name.isNotEmpty ? report.name : 'Untitled Report'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Date', report.date.isNotEmpty ? report.date : 'Not specified'),
              _buildDetailRow('Report Type', report.reportType),
              _buildDetailRow('Receiver', report.receiverName),
              _buildDetailRow('Sender', report.senderName),
              if (report.objective.isNotEmpty)
                _buildDetailRow('Objective', report.objective),
              if (report.description.isNotEmpty)
                _buildDetailRow('Description', report.description),
              if (report.attachments.isNotEmpty)
                _buildDetailRow('Attachments', '${report.attachments.length} file(s)'),
              if (report.linkAttachment != null)
                _buildDetailRow('Link', report.linkAttachment!),
              _buildDetailRow('Created', _formatDate(report.createdAt)),
              _buildDetailRow('Completed', _formatDate(report.updatedAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(
                context,
                AppRoutes.reportView,
                arguments: report,
              );
            },
            child: const Text('View'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(
                context,
                AppRoutes.reportDetail,
                arguments: report.id,
              );
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(value.isNotEmpty ? value : 'Not specified'),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {

    return RefreshIndicator(
      onRefresh: _refreshReports,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double horizontalPadding = constraints.maxWidth < 500 ? 8 : 32;
          final double verticalPadding = constraints.maxWidth < 500 ? 8 : 16;
          
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (_errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshReports,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (_completedReports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No completed reports yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.reportDetail),
                    child: const Text('Create Your First Report'),
                  ),
                ],
              ),
            );
          }
          
          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            itemCount: _completedReports.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final report = _completedReports[index];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.reportView,
                  arguments: report,
                ),
                child: ListTile(
                  leading: const Icon(Icons.insert_drive_file, color: Colors.blueAccent),
                  title: Text(
                    report.name.isNotEmpty ? report.name : 'Untitled Report',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${report.date.isNotEmpty ? report.date : _formatDate(report.createdAt)}\n${report.summary}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (report.attachments.isNotEmpty)
                        Icon(Icons.attach_file, size: 16, color: Colors.grey),
                      if (report.linkAttachment != null)
                        Icon(Icons.link, size: 16, color: Colors.grey),
                    ],
                  ),
                  isThreeLine: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: Colors.blue.withOpacity(0.05),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
