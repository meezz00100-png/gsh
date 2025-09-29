import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/shared/models/report_model.dart';
import 'package:harari_prosperity_app/shared/widgets/responsive_widgets.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/localization/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ReportViewScreen extends StatefulWidget {
  final Report report;

  const ReportViewScreen({super.key, required this.report});

  @override
  State<ReportViewScreen> createState() => _ReportViewScreenState();
}

class _ReportViewScreenState extends State<ReportViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.report.name.isNotEmpty
              ? widget.report.name
              : context.translate('reportDetails'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, size: 24),
            tooltip: context.translate('download'),
            onPressed: () => _downloadReportAsPdf(context, widget.report),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 24),
            tooltip: context.translate('share'),
            onPressed: () => _shareReportAsPdf(context, widget.report),
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined, size: 24),
            tooltip: context.translate('print'),
            onPressed: () => _printReport(context, widget.report),
          ),
        ],
      ),
      body: ResponsivePadding(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with logo
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/prosperity_logo.png',
                      height: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.report.name.isNotEmpty
                          ? widget.report.name
                          : context.translate('untitledReport'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        context.translate('completed'),
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Step 1: Basic Information
              _buildStepSection(
                context: context,
                stepNumber: 1,
                title: context.translate('basicInformation'),
                children: [
                  _buildInfoRow(
                    context,
                    context.translate('reportType'),
                    widget.report.reportType,
                  ),
                  _buildInfoRow(
                    context,
                    context.translate('type'),
                    widget.report.type,
                  ),
                  _buildInfoRow(
                    context,
                    context.translate('receiverName'),
                    widget.report.receiverName,
                  ),
                  _buildInfoRow(
                    context,
                    context.translate('objectiveOfReport'),
                    widget.report.objective,
                  ),
                  _buildInfoRow(
                    context,
                    context.translate('description'),
                    widget.report.description,
                    isMultiline: true,
                  ),
                ],
              ),

              // Step 2: Report Content
              _buildStepSection(
                context: context,
                stepNumber: 2,
                title: context.translate('reportContent'),
                children: [
                  _buildInfoRow(
                    context,
                    context.translate('importanceOfReport'),
                    widget.report.importance,
                    isMultiline: true,
                  ),
                  _buildInfoRow(
                    context,
                    context.translate('mainPoints'),
                    widget.report.mainPoints,
                    isMultiline: true,
                  ),
                  _buildInfoRow(
                    context,
                    context.translate('informationSources'),
                    widget.report.sources,
                    isMultiline: true,
                  ),
                ],
              ),

              // Step 3: Analysis
              _buildStepSection(
                context: context,
                stepNumber: 3,
                title: context.translate('analysis'),
                children: [
                  _buildInfoRow(
                    context,
                    context.translate('rolesOfActors'),
                    widget.report.roles,
                    isMultiline: true,
                  ),
                  _buildInfoRow(
                    context,
                    context.translate('positiveNegativeTrends'),
                    widget.report.trends,
                    isMultiline: true,
                  ),
                  _buildInfoRow(
                    context,
                    context.translate('takenThemes'),
                    widget.report.themes,
                    isMultiline: true,
                  ),
                ],
              ),

              // Step 4: Conclusions
              _buildStepSection(
                context: context,
                stepNumber: 4,
                title: context.translate('conclusionsFuture'),
                children: [
                  _buildInfoRow(
                    context,
                    context.translate('implicationsConclusions'),
                    widget.report.implications,
                    isMultiline: true,
                  ),
                  _buildInfoRow(
                    context,
                    context.translate('scenarios'),
                    widget.report.scenarios,
                    isMultiline: true,
                  ),
                  _buildInfoRow(
                    context,
                    context.translate('futurePlansActivities'),
                    widget.report.futurePlans,
                    isMultiline: true,
                  ),
                ],
              ),

              // Step 5: Metadata
              _buildStepSection(
                context: context,
                stepNumber: 5,
                title: context.translate('reportMetadata'),
                children: [
                  _buildInfoRow(
                    context,
                    context.translate('reportApprovingBody'),
                    widget.report.approvingBody,
                  ),
                  _buildInfoRow(
                    context,
                    context.translate('senderName'),
                    widget.report.senderName,
                  ),
                  _buildInfoRow(
                    context,
                    context.translate('role'),
                    widget.report.role,
                  ),
                  _buildInfoRow(
                    context,
                    context.translate('date'),
                    widget.report.date,
                  ),
                ],
              ),

              // Attachments Section
              if (widget.report.attachments.isNotEmpty ||
                  widget.report.linkAttachment != null)
                _buildStepSection(
                  context: context,
                  stepNumber: 6,
                  title: context.translate('attachments'),
                  children: [
                    if (widget.report.attachments.isNotEmpty) ...[
                      Text(
                        context.translate('fileAttachments'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...widget.report.attachments
                          .map(
                            (attachment) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: InkWell(
                                onTap: () => _launchUrl(attachment),
                                child: Row(
                                  children: [
                                    const Icon(Icons.attach_file, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        attachment.split('/').last,
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.download,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      const SizedBox(height: 16),
                    ],
                    if (widget.report.linkAttachment != null) ...[
                      Text(
                        context.translate('linkAttachment'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _launchUrl(widget.report.linkAttachment!),
                        child: Row(
                          children: [
                            const Icon(Icons.link, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.report.linkAttachment!,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.open_in_new,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

              // Report Info
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translate('reportInformation'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      context.translate('created'),
                      _formatDate(widget.report.createdAt, context),
                    ),
                    _buildInfoRow(
                      context,
                      context.translate('lastUpdated'),
                      _formatDate(widget.report.updatedAt, context),
                    ),
                    _buildInfoRow(
                      context,
                      context.translate('status'),
                      widget.report.status.toUpperCase(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepSection({
    required BuildContext context,
    required int stepNumber,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      stepNumber.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isMultiline = false,
  }) {
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    return '${date.day}/${date.month}/${date.year} ${context.translate('at')} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _downloadReportAsPdf(BuildContext context, Report report) async {
    try {
      final pdf = pw.Document();

      // Load logo image
      final logoImage = pw.MemoryImage(
        (await DefaultAssetBundle.of(
          context,
        ).load('assets/images/prosperity_logo.png')).buffer.asUint8List(),
      );

      // Add content to PDF
      pdf.addPage(
        pw.Page(
          build: (pw.Context pdfContext) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Logo and Header
                pw.Row(
                  children: [
                    pw.Image(logoImage, width: 60, height: 60),
                    pw.SizedBox(width: 20),
                    pw.Expanded(
                      child: pw.Text(
                        report.name.isNotEmpty
                            ? report.name
                            : 'Untitled Report',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Basic Information
                pw.Text(
                  context.translate('basicInformation'),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow(
                  context.translate('reportType'),
                  report.reportType,
                ),
                _buildPdfRow(context.translate('type'), report.type),
                _buildPdfRow(
                  context.translate('receiverName'),
                  report.receiverName,
                ),
                _buildPdfRow(
                  context.translate('objectiveOfReport'),
                  report.objective,
                ),
                _buildPdfRow(
                  context.translate('description'),
                  report.description,
                ),
                pw.SizedBox(height: 20),

                // Content
                pw.Text(
                  context.translate('reportContent'),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow(
                  context.translate('importanceOfReport'),
                  report.importance,
                ),
                _buildPdfRow(
                  context.translate('mainPoints'),
                  report.mainPoints,
                ),
                _buildPdfRow(
                  context.translate('informationSources'),
                  report.sources,
                ),
                pw.SizedBox(height: 20),

                // Analysis
                pw.Text(
                  context.translate('analysis'),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow(context.translate('rolesOfActors'), report.roles),
                _buildPdfRow(
                  context.translate('positiveNegativeTrends'),
                  report.trends,
                ),
                _buildPdfRow(context.translate('takenThemes'), report.themes),
                pw.SizedBox(height: 20),

                // Conclusions
                pw.Text(
                  context.translate('conclusionsFuture'),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow(
                  context.translate('implicationsConclusions'),
                  report.implications,
                ),
                _buildPdfRow(context.translate('scenarios'), report.scenarios),
                _buildPdfRow(
                  context.translate('futurePlansActivities'),
                  report.futurePlans,
                ),
                pw.SizedBox(height: 20),

                // Metadata
                pw.Text(
                  context.translate('reportMetadata'),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow(
                  context.translate('reportApprovingBody'),
                  report.approvingBody,
                ),
                _buildPdfRow(
                  context.translate('senderName'),
                  report.senderName,
                ),
                _buildPdfRow(context.translate('role'), report.role),
                _buildPdfRow(context.translate('date'), report.date),
                _buildPdfRow(
                  context.translate('created'),
                  _formatDateForPdf(report.createdAt),
                ),
                _buildPdfRow(
                  context.translate('completed'),
                  _formatDateForPdf(report.updatedAt),
                ),
                pw.SizedBox(height: 20),

                // Attachments
                if (report.attachments.isNotEmpty ||
                    report.linkAttachment != null) ...[
                  pw.Text(
                    context.translate('attachments'),
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  if (report.attachments.isNotEmpty)
                    pw.Text(
                      '${context.translate('files')}: ${report.attachments.length} ${context.translate('attached')}',
                    ),
                  if (report.linkAttachment != null)
                    _buildPdfRow(
                      context.translate('link'),
                      report.linkAttachment!,
                    ),
                ],
              ],
            );
          },
        ),
      );

      // Save PDF to Downloads directory (Android) or Documents directory (iOS)
      Directory? downloadDir;
      String fileName =
          '${report.name.isNotEmpty ? report.name.replaceAll(RegExp(r'[^\w\s-]'), '_') : 'report'}.pdf';

      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
        if (!await downloadDir.exists()) {
          downloadDir = await getExternalStorageDirectory();
        }
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      final file = File('${downloadDir!.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF downloaded successfully: $fileName'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareReportAsPdf(BuildContext context, Report report) async {
    try {
      final pdf = pw.Document();

      // Load logo image
      final logoImage = pw.MemoryImage(
        (await DefaultAssetBundle.of(
          context,
        ).load('assets/images/prosperity_logo.png')).buffer.asUint8List(),
      );

      // Add content to PDF (same as download)
      pdf.addPage(
        pw.Page(
          build: (pw.Context pdfContext) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Logo and Header
                pw.Row(
                  children: [
                    pw.Image(logoImage, width: 60, height: 60),
                    pw.SizedBox(width: 20),
                    pw.Expanded(
                      child: pw.Text(
                        report.name.isNotEmpty
                            ? report.name
                            : 'Untitled Report',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Basic Information
                pw.Text(
                  context.translate('basicInformation'),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow(
                  context.translate('reportType'),
                  report.reportType,
                ),
                _buildPdfRow(context.translate('type'), report.type),
                _buildPdfRow(
                  context.translate('receiverName'),
                  report.receiverName,
                ),
                _buildPdfRow(
                  context.translate('objectiveOfReport'),
                  report.objective,
                ),
                _buildPdfRow(
                  context.translate('description'),
                  report.description,
                ),
                pw.SizedBox(height: 20),

                // Content
                pw.Text(
                  context.translate('reportContent'),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow(
                  context.translate('importanceOfReport'),
                  report.importance,
                ),
                _buildPdfRow(
                  context.translate('mainPoints'),
                  report.mainPoints,
                ),
                _buildPdfRow(
                  context.translate('informationSources'),
                  report.sources,
                ),
                pw.SizedBox(height: 20),

                // Analysis
                pw.Text(
                  context.translate('analysis'),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow(context.translate('rolesOfActors'), report.roles),
                _buildPdfRow(
                  context.translate('positiveNegativeTrends'),
                  report.trends,
                ),
                _buildPdfRow(context.translate('takenThemes'), report.themes),
                pw.SizedBox(height: 20),

                // Conclusions
                pw.Text(
                  context.translate('conclusionsFuture'),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow(
                  context.translate('implicationsConclusions'),
                  report.implications,
                ),
                _buildPdfRow(context.translate('scenarios'), report.scenarios),
                _buildPdfRow(
                  context.translate('futurePlansActivities'),
                  report.futurePlans,
                ),
                pw.SizedBox(height: 20),

                // Metadata
                pw.Text(
                  context.translate('reportMetadata'),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow(
                  context.translate('reportApprovingBody'),
                  report.approvingBody,
                ),
                _buildPdfRow(
                  context.translate('senderName'),
                  report.senderName,
                ),
                _buildPdfRow(context.translate('role'), report.role),
                _buildPdfRow(context.translate('date'), report.date),
                _buildPdfRow(
                  context.translate('created'),
                  _formatDateForPdf(report.createdAt),
                ),
                _buildPdfRow(
                  context.translate('completed'),
                  _formatDateForPdf(report.updatedAt),
                ),
                pw.SizedBox(height: 20),

                // Attachments
                if (report.attachments.isNotEmpty ||
                    report.linkAttachment != null) ...[
                  pw.Text(
                    context.translate('attachments'),
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  if (report.attachments.isNotEmpty)
                    pw.Text(
                      '${context.translate('files')}: ${report.attachments.length} ${context.translate('attached')}',
                    ),
                  if (report.linkAttachment != null)
                    _buildPdfRow(
                      context.translate('link'),
                      report.linkAttachment!,
                    ),
                ],
              ],
            );
          },
        ),
      );

      // Save PDF to temporary file for sharing
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _printReport(BuildContext context, Report report) async {
    try {
      final pdf = pw.Document();

      // Load logo image
      final logoImage = pw.MemoryImage(
        (await DefaultAssetBundle.of(
          context,
        ).load('assets/images/prosperity_logo.png')).buffer.asUint8List(),
      );

      // Add content to PDF (same as download)
      pdf.addPage(
        pw.Page(
          build: (pw.Context pdfContext) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Logo and Header
                pw.Row(
                  children: [
                    pw.Image(logoImage, width: 60, height: 60),
                    pw.SizedBox(width: 20),
                    pw.Expanded(
                      child: pw.Text(
                        report.name.isNotEmpty
                            ? report.name
                            : 'Untitled Report',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Basic Information
                pw.Text(
                  context.translate('basicInformation'),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow(
                  context.translate('reportType'),
                  report.reportType,
                ),
                _buildPdfRow(context.translate('type'), report.type),
                _buildPdfRow(
                  context.translate('receiverName'),
                  report.receiverName,
                ),
                _buildPdfRow(
                  context.translate('objectiveOfReport'),
                  report.objective,
                ),
                _buildPdfRow(
                  context.translate('description'),
                  report.description,
                ),
                pw.SizedBox(height: 20),

                // Content
                pw.Text(
                  context.translate('reportContent'),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow(
                  context.translate('importanceOfReport'),
                  report.importance,
                ),
                _buildPdfRow(
                  context.translate('mainPoints'),
                  report.mainPoints,
                ),
                _buildPdfRow(
                  context.translate('informationSources'),
                  report.sources,
                ),
                pw.SizedBox(height: 20),

                // Analysis
                pw.Text(
                  context.translate('analysis'),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow(context.translate('rolesOfActors'), report.roles),
                _buildPdfRow(
                  context.translate('positiveNegativeTrends'),
                  report.trends,
                ),
                _buildPdfRow(context.translate('takenThemes'), report.themes),
                pw.SizedBox(height: 20),

                // Conclusions
                pw.Text(
                  context.translate('conclusionsFuture'),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow(
                  context.translate('implicationsConclusions'),
                  report.implications,
                ),
                _buildPdfRow(context.translate('scenarios'), report.scenarios),
                _buildPdfRow(
                  context.translate('futurePlansActivities'),
                  report.futurePlans,
                ),
                pw.SizedBox(height: 20),

                // Metadata
                pw.Text(
                  context.translate('reportMetadata'),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPdfRow(
                  context.translate('reportApprovingBody'),
                  report.approvingBody,
                ),
                _buildPdfRow(
                  context.translate('senderName'),
                  report.senderName,
                ),
                _buildPdfRow(context.translate('role'), report.role),
                _buildPdfRow(context.translate('date'), report.date),
                _buildPdfRow(
                  context.translate('created'),
                  _formatDateForPdf(report.createdAt),
                ),
                _buildPdfRow(
                  context.translate('completed'),
                  _formatDateForPdf(report.updatedAt),
                ),
                pw.SizedBox(height: 20),

                // Attachments
                if (report.attachments.isNotEmpty ||
                    report.linkAttachment != null) ...[
                  pw.Text(
                    context.translate('attachments'),
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  if (report.attachments.isNotEmpty)
                    pw.Text(
                      '${context.translate('files')}: ${report.attachments.length} ${context.translate('attached')}',
                    ),
                  if (report.linkAttachment != null)
                    _buildPdfRow(
                      context.translate('link'),
                      report.linkAttachment!,
                    ),
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
      // Handle error - in a real app, you'd show a snackbar or dialog
      print('Failed to print report: $e');
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

  String _formatDateForPdf(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
