import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/shared/services/report_service.dart';
import 'package:harari_prosperity_app/shared/models/report_model.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/localization/app_localizations.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

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
        title: Text(
          report.name.isNotEmpty
              ? report.name
              : context.translate('untitledReport'),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                context.translate('date'),
                report.date.isNotEmpty
                    ? report.date
                    : context.translate('notSpecified'),
              ),
              _buildDetailRow(
                context.translate('reportType'),
                report.reportType,
              ),
              _buildDetailRow(
                context.translate('receiver'),
                report.receiverName,
              ),
              _buildDetailRow(context.translate('sender'), report.senderName),
              if (report.objective.isNotEmpty)
                _buildDetailRow(
                  context.translate('objective'),
                  report.objective,
                ),
              if (report.description.isNotEmpty)
                _buildDetailRow(
                  context.translate('description'),
                  report.description,
                ),
              if (report.attachments.isNotEmpty)
                _buildDetailRow(
                  context.translate('attachments'),
                  '${report.attachments.length} ${context.translate('files')}',
                ),
              if (report.linkAttachment != null)
                _buildDetailRow(
                  context.translate('link'),
                  report.linkAttachment!,
                ),
              _buildDetailRow(
                context.translate('created'),
                _formatDate(report.createdAt),
              ),
              _buildDetailRow(
                context.translate('completed'),
                _formatDate(report.updatedAt),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.translate('close')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _downloadReportAsPdf(report);
            },
            child: Text(context.translate('download')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _printReport(report);
            },
            child: Text(context.translate('print')),
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
            child: Text(context.translate('view')),
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
            child: Text(context.translate('edit')),
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
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value.isNotEmpty ? value : context.translate('notSpecified')),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _downloadReportAsPdf(Report report) async {
    try {
      final pdf = pw.Document();

      // Add content to PDF
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Text(
                  report.name.isNotEmpty ? report.name : 'Untitled Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),

                // Basic Information
                pw.Text(
                  'Basic Information',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow('Report Type', report.reportType),
                _buildPdfRow('Type', report.type),
                _buildPdfRow('Receiver', report.receiverName),
                _buildPdfRow('Objective', report.objective),
                _buildPdfRow('Description', report.description),
                pw.SizedBox(height: 20),

                // Content
                pw.Text(
                  'Report Content',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow('Importance', report.importance),
                _buildPdfRow('Main Points', report.mainPoints),
                _buildPdfRow('Sources', report.sources),
                pw.SizedBox(height: 20),

                // Analysis
                pw.Text(
                  'Analysis',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow('Roles', report.roles),
                _buildPdfRow('Trends', report.trends),
                _buildPdfRow('Themes', report.themes),
                pw.SizedBox(height: 20),

                // Conclusions
                pw.Text(
                  'Conclusions & Future Plans',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow('Implications', report.implications),
                _buildPdfRow('Scenarios', report.scenarios),
                _buildPdfRow('Future Plans', report.futurePlans),
                pw.SizedBox(height: 20),

                // Metadata
                pw.Text(
                  'Report Metadata',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow('Approving Body', report.approvingBody),
                _buildPdfRow('Sender', report.senderName),
                _buildPdfRow('Role', report.role),
                _buildPdfRow('Date', report.date),
                _buildPdfRow('Created', _formatDate(report.createdAt)),
                _buildPdfRow('Completed', _formatDate(report.updatedAt)),
                pw.SizedBox(height: 20),

                // Attachments
                if (report.attachments.isNotEmpty ||
                    report.linkAttachment != null) ...[
                  pw.Text(
                    'Attachments',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  if (report.attachments.isNotEmpty)
                    pw.Text('Files: ${report.attachments.length} attached'),
                  if (report.linkAttachment != null)
                    _buildPdfRow('Link', report.linkAttachment!),
                ],
              ],
            );
          },
        ),
      );

      // Save PDF to file
      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/${report.name.isNotEmpty ? report.name : 'report'}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      // Share the file
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Report: ${report.name}');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to download PDF: $e')));
    }
  }

  Future<void> _printReport(Report report) async {
    try {
      final pdf = pw.Document();

      // Add content to PDF (same as download)
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Text(
                  report.name.isNotEmpty ? report.name : 'Untitled Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),

                // Basic Information
                pw.Text(
                  'Basic Information',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow('Report Type', report.reportType),
                _buildPdfRow('Type', report.type),
                _buildPdfRow('Receiver', report.receiverName),
                _buildPdfRow('Objective', report.objective),
                _buildPdfRow('Description', report.description),
                pw.SizedBox(height: 20),

                // Content
                pw.Text(
                  'Report Content',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow('Importance', report.importance),
                _buildPdfRow('Main Points', report.mainPoints),
                _buildPdfRow('Sources', report.sources),
                pw.SizedBox(height: 20),

                // Analysis
                pw.Text(
                  'Analysis',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow('Roles', report.roles),
                _buildPdfRow('Trends', report.trends),
                _buildPdfRow('Themes', report.themes),
                pw.SizedBox(height: 20),

                // Conclusions
                pw.Text(
                  'Conclusions & Future Plans',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow('Implications', report.implications),
                _buildPdfRow('Scenarios', report.scenarios),
                _buildPdfRow('Future Plans', report.futurePlans),
                pw.SizedBox(height: 20),

                // Metadata
                pw.Text(
                  'Report Metadata',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow('Approving Body', report.approvingBody),
                _buildPdfRow('Sender', report.senderName),
                _buildPdfRow('Role', report.role),
                _buildPdfRow('Date', report.date),
                _buildPdfRow('Created', _formatDate(report.createdAt)),
                _buildPdfRow('Completed', _formatDate(report.updatedAt)),
                pw.SizedBox(height: 20),

                // Attachments
                if (report.attachments.isNotEmpty ||
                    report.linkAttachment != null) ...[
                  pw.Text(
                    'Attachments',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  if (report.attachments.isNotEmpty)
                    pw.Text('Files: ${report.attachments.length} attached'),
                  if (report.linkAttachment != null)
                    _buildPdfRow('Link', report.linkAttachment!),
                ],
              ],
            );
          },
        ),
      );

      // Print the PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to print report: $e')));
    }
  }

  pw.Widget _buildPdfRow(String label, String value) {
    if (value.isEmpty) return pw.Container();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$label:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(value),
          pw.SizedBox(height: 8),
        ],
      ),
    );
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
            return const Center(child: CircularProgressIndicator());
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
                    child: Text(context.translate('retry')),
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
                  Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.translate('noCompletedReports'),
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.reportDetail),
                    child: Text(context.translate('createFirstReport')),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
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
                  leading: const Icon(
                    Icons.insert_drive_file,
                    color: Colors.blueAccent,
                  ),
                  title: Text(
                    report.name.isNotEmpty
                        ? report.name
                        : context.translate('untitledReport'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${report.date.isNotEmpty ? report.date : _formatDate(report.createdAt)}\n${report.summary}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: null,
                  isThreeLine: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: Colors.blue.withOpacity(0.05),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
