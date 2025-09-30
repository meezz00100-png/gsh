import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/widgets/custom_button.dart';
import 'package:harari_prosperity_app/shared/services/report_service.dart';
import 'package:harari_prosperity_app/shared/localization/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AttachmentScreen extends StatefulWidget {
  const AttachmentScreen({super.key});

  @override
  State<AttachmentScreen> createState() => _AttachmentScreenState();
}

class _AttachmentScreenState extends State<AttachmentScreen> {
  final ReportService _reportService = ReportService();
  final TextEditingController _linkController = TextEditingController();
  String? _reportId;
  List<String> _selectedFiles = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      print('🔄 AttachmentScreen initState - arguments: $args');
      if (args is String) {
        setState(() => _reportId = args);
        print('✅ Report ID set: $_reportId');
      } else {
        print('❌ Invalid arguments type: ${args.runtimeType}');
      }
    });
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.files.map((file) => file.name).toList();
        });
      }
    } catch (e) {
      setState(
        () => _errorMessage = '${context.translate('failedToPickFiles')}: $e',
      );
    }
  }

  Future<void> _uploadAttachments() async {
    if (_reportId == null) {
      setState(() => _errorMessage = context.translate('noReportIdFound'));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Upload files if any selected
      if (_selectedFiles.isNotEmpty) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: [
            'pdf',
            'doc',
            'docx',
            'txt',
            'jpg',
            'jpeg',
            'png',
          ],
        );

        if (result != null) {
          for (PlatformFile file in result.files) {
            if (file.bytes != null) {
              final fileUrl = await _reportService.uploadAttachment(
                reportId: _reportId!,
                fileName: file.name,
                fileBytes: file.bytes!,
                contentType: _getContentType(file.extension),
              );

              await _reportService.addAttachmentToReport(_reportId!, fileUrl);
            }
          }
        }
      }

      // Add link if provided
      if (_linkController.text.isNotEmpty) {
        await _reportService.addLinkToReport(_reportId!, _linkController.text);
      }

      setState(() => _errorMessage = null);
    } catch (e) {
      setState(
        () => _errorMessage =
            '${context.translate('failedToUploadAttachments')}: $e',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _getContentType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return null;
    }
  }

  Future<void> _proceedToFinalStep() async {
    if (_selectedFiles.isNotEmpty || _linkController.text.isNotEmpty) {
      await _uploadAttachments();
      if (_errorMessage == null) {
        Navigator.pushNamed(context, AppRoutes.finalStep, arguments: _reportId);
      }
    } else {
      Navigator.pushNamed(context, AppRoutes.finalStep, arguments: _reportId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.translate('attachment'))),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth < 500 ? double.infinity : 400;
          EdgeInsets padding = constraints.maxWidth < 500
              ? const EdgeInsets.fromLTRB(12, 24, 12, 12)
              : const EdgeInsets.fromLTRB(20, 32, 20, 20);
          return SingleChildScrollView(
            child: Padding(
              padding: padding,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        context.translate('attachFilesOrLinks'),
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () =>
                                  setState(() => _errorMessage = null),
                            ),
                          ],
                        ),
                      ),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                context.translate('file').toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.attach_file),
                                label: Text(context.translate('chooseFile')),
                                onPressed: _pickFiles,
                              ),
                            ),
                            if (_selectedFiles.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                context.translate('selectedFiles'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...(_selectedFiles
                                  .map(
                                    (file) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.description, size: 16),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              file,
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList()),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                context.translate('link').toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _linkController,
                              decoration: InputDecoration(
                                labelText: context.translate('pasteLinkHere'),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: context.translate('skip'),
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.finalStep,
                              arguments: _reportId,
                            ),
                            filled: false,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomButton(
                            text: context.translate('next'),
                            onPressed: _proceedToFinalStep,
                            filled: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
