import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/shared/models/report_model.dart';
import 'package:harari_prosperity_app/shared/widgets/responsive_widgets.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';

class ReportViewScreen extends StatelessWidget {
  final Report report;

  const ReportViewScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(report.name.isNotEmpty ? report.name : 'Report Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.reportDetail,
                arguments: report.id,
              );
            },
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
                      report.name.isNotEmpty ? report.name : 'Untitled Report',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Text(
                        'COMPLETED',
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
                stepNumber: 1,
                title: 'Basic Information',
                children: [
                  _buildInfoRow('Report Type', report.reportType),
                  _buildInfoRow('Type', report.type),
                  _buildInfoRow('Receiver Name', report.receiverName),
                  _buildInfoRow('Objective of Report', report.objective),
                  _buildInfoRow('Description', report.description, isMultiline: true),
                ],
              ),

              // Step 2: Report Content
              _buildStepSection(
                stepNumber: 2,
                title: 'Report Content',
                children: [
                  _buildInfoRow('Importance of Report', report.importance, isMultiline: true),
                  _buildInfoRow('Main Points', report.mainPoints, isMultiline: true),
                  _buildInfoRow('Information Sources', report.sources, isMultiline: true),
                ],
              ),

              // Step 3: Analysis
              _buildStepSection(
                stepNumber: 3,
                title: 'Analysis',
                children: [
                  _buildInfoRow('Roles of Actors and Stakeholders', report.roles, isMultiline: true),
                  _buildInfoRow('Positive and Negative Trends', report.trends, isMultiline: true),
                  _buildInfoRow('Taken Themes', report.themes, isMultiline: true),
                ],
              ),

              // Step 4: Conclusions
              _buildStepSection(
                stepNumber: 4,
                title: 'Conclusions & Future',
                children: [
                  _buildInfoRow('Implications and Conclusions', report.implications, isMultiline: true),
                  _buildInfoRow('Scenarios', report.scenarios, isMultiline: true),
                  _buildInfoRow('Future Plans and Activities', report.futurePlans, isMultiline: true),
                ],
              ),

              // Step 5: Metadata
              _buildStepSection(
                stepNumber: 5,
                title: 'Report Metadata',
                children: [
                  _buildInfoRow('Report Approving Body', report.approvingBody),
                  _buildInfoRow('Sender Name', report.senderName),
                  _buildInfoRow('Role', report.role),
                  _buildInfoRow('Date', report.date),
                ],
              ),

              // Attachments Section
              if (report.attachments.isNotEmpty || report.linkAttachment != null)
                _buildStepSection(
                  stepNumber: 6,
                  title: 'Attachments',
                  children: [
                    if (report.attachments.isNotEmpty) ...[
                      const Text(
                        'File Attachments:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...report.attachments.map((attachment) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.attach_file, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                attachment.split('/').last,
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                      const SizedBox(height: 16),
                    ],
                    if (report.linkAttachment != null) ...[
                      const Text(
                        'Link Attachment:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.link, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              report.linkAttachment!,
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
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
                    const Text(
                      'Report Information',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Created', _formatDate(report.createdAt)),
                    _buildInfoRow('Last Updated', _formatDate(report.updatedAt)),
                    _buildInfoRow('Status', report.status.toUpperCase()),
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

  Widget _buildInfoRow(String label, String value, {bool isMultiline = false}) {
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
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
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
