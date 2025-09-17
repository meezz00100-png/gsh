import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/widgets/custom_button.dart';
import 'package:harari_prosperity_app/shared/widgets/responsive_widgets.dart';
import 'package:harari_prosperity_app/shared/models/report_model.dart';
import 'package:harari_prosperity_app/shared/services/report_service.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({super.key});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  void previousStep() {
    if (currentStep > 1) {
      setState(() => currentStep--);
    }
  }
  int currentStep = 1;
  final ReportService _reportService = ReportService();
  Report? _currentReport;
  bool _isLoading = false;
  String? _errorMessage;
  final Map<int, GlobalKey<FormState>> _formKeys = {
    1: GlobalKey<FormState>(),
    2: GlobalKey<FormState>(),
    3: GlobalKey<FormState>(),
    4: GlobalKey<FormState>(),
    5: GlobalKey<FormState>(),
  };

  final Map<String, String> formData = {
    'name': '',
    'reportType': '',
    'type': '',
    'receiverName': '',
    'objective': '',
    'description': '',
    'importance': '',
    'mainPoints': '',
    'sources': '',
    'roles': '',
    'trends': '',
    'themes': '',
    'implications': '',
    'scenarios': '',
    'futurePlans': '',
    'approvingBody': '',
    'senderName': '',
    'role': '',
    'date': '',
  };

  void nextStep() async {
    if (_formKeys[currentStep]!.currentState!.validate()) {
      _formKeys[currentStep]!.currentState!.save();
      
      // Save current progress
      await _saveDraft();
      
      if (currentStep < 5) {
        setState(() => currentStep++);
      } else {
        // Pass the report ID to attachment screen
        Navigator.pushNamed(
          context, 
          AppRoutes.attachment,
          arguments: _currentReport?.id,
        );
      }
    }
  }

  Future<void> _saveDraft() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final report = Report(
        id: _currentReport?.id,
        name: formData['name'] ?? '',
        reportType: formData['reportType'] ?? '',
        type: formData['type'] ?? '',
        receiverName: formData['receiverName'] ?? '',
        objective: formData['objective'] ?? '',
        description: formData['description'] ?? '',
        importance: formData['importance'] ?? '',
        mainPoints: formData['mainPoints'] ?? '',
        sources: formData['sources'] ?? '',
        roles: formData['roles'] ?? '',
        trends: formData['trends'] ?? '',
        themes: formData['themes'] ?? '',
        implications: formData['implications'] ?? '',
        scenarios: formData['scenarios'] ?? '',
        futurePlans: formData['futurePlans'] ?? '',
        approvingBody: formData['approvingBody'] ?? '',
        senderName: formData['senderName'] ?? '',
        role: formData['role'] ?? '',
        date: formData['date'] ?? '',
        attachments: _currentReport?.attachments ?? [],
        linkAttachment: _currentReport?.linkAttachment,
        createdAt: _currentReport?.createdAt ?? now,
        updatedAt: now,
        status: 'draft',
      );
      
      _currentReport = await _reportService.saveReport(report);
      setState(() => _errorMessage = null);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to save progress: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadExistingReport();
  }

  Future<void> _loadExistingReport() async {
    // Check if there's a report ID passed as argument
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _loadReportById(args);
      }
    });
  }

  Future<void> _loadReportById(String reportId) async {
    setState(() => _isLoading = true);
    try {
      final report = await _reportService.getReportById(reportId);
      if (report != null) {
        _currentReport = report;
        _populateFormData(report);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load report: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _populateFormData(Report report) {
    setState(() {
      formData['name'] = report.name;
      formData['reportType'] = report.reportType;
      formData['type'] = report.type;
      formData['receiverName'] = report.receiverName;
      formData['objective'] = report.objective;
      formData['description'] = report.description;
      formData['importance'] = report.importance;
      formData['mainPoints'] = report.mainPoints;
      formData['sources'] = report.sources;
      formData['roles'] = report.roles;
      formData['trends'] = report.trends;
      formData['themes'] = report.themes;
      formData['implications'] = report.implications;
      formData['scenarios'] = report.scenarios;
      formData['futurePlans'] = report.futurePlans;
      formData['approvingBody'] = report.approvingBody;
      formData['senderName'] = report.senderName;
      formData['role'] = report.role;
      formData['date'] = report.date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (currentStep > 1) {
              previousStep();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: ResponsivePadding(
        child: Form(
          key: _formKeys[currentStep],
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
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
                          onPressed: () => setState(() => _errorMessage = null),
                        ),
                      ],
                    ),
                  ),
                _buildStepContent(),
                const SizedBox(height: 20),
                if (currentStep == 5)
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: "BACK",
                          onPressed: previousStep,
                          filled: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          text: "NEXT",
                          onPressed: nextStep,
                          filled: true,
                        ),
                      ),
                    ],
                  )
                else ...[
                  if (currentStep > 1)
                    CustomButton(
                      text: "BACK",
                      onPressed: previousStep,
                      filled: false,
                    ),
                  if (currentStep > 1) const SizedBox(height: 10),
                  CustomButton(
                    text: "NEXT",
                    onPressed: nextStep,
                    filled: true,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 1: return _buildStep1();
      case 2: return _buildStep2();
      case 3: return _buildStep3();
      case 4: return _buildStep4();
      case 5: return _buildStep5();
      default: return _buildStep1();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Heading title", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: "Name"),
          initialValue: formData['name'],
          validator: (value) => value?.isEmpty == true ? 'Please enter a name' : null,
          onSaved: (value) => formData['name'] = value ?? '',
        ),
        const SizedBox(height: 20),
        TextFormField(
          decoration: const InputDecoration(labelText: "Report Type"),
          initialValue: formData['reportType'],
          validator: (value) => value?.isEmpty == true ? 'Please enter a report type' : null,
          onSaved: (value) => formData['reportType'] = value ?? '',
        ),
        const SizedBox(height: 20),
        TextFormField(
          decoration: const InputDecoration(labelText: "Type"),
          initialValue: formData['type'],
          validator: (value) => null,
          onSaved: (value) => formData['type'] = value ?? '',
        ),
        const SizedBox(height: 20),
        TextFormField(
          decoration: const InputDecoration(labelText: "Receiver Name"),
          initialValue: formData['receiverName'],
          validator: (value) => null,
          onSaved: (value) => formData['receiverName'] = value ?? '',
        ),
        const SizedBox(height: 20),
        TextFormField(
          decoration: const InputDecoration(labelText: "Objective of Report"),
          initialValue: formData['objective'],
          validator: (value) => null,
          onSaved: (value) => formData['objective'] = value ?? '',
        ),
        const SizedBox(height: 20),
        TextFormField(
          decoration: const InputDecoration(labelText: "Description"),
          initialValue: formData['description'],
          maxLines: 3,
          validator: (value) => null,
          onSaved: (value) => formData['description'] = value ?? '',
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Importance of Report", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: "Explanation"),
          initialValue: formData['importance'],
          maxLines: 3,
          validator: (value) => null,
          onSaved: (value) => formData['importance'] = value ?? '',
        ),
        const SizedBox(height: 20),
        const Text("Main points", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: "Explanation"),
          initialValue: formData['mainPoints'],
          maxLines: 3,
          validator: (value) => null,
          onSaved: (value) => formData['mainPoints'] = value ?? '',
        ),
        const SizedBox(height: 20),
        const Text("Information Sources", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: "Explanation"),
          initialValue: formData['sources'],
          maxLines: 3,
          validator: (value) => null,
          onSaved: (value) => formData['sources'] = value ?? '',
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Roles of actors and stakeholders", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: "Description"),
          initialValue: formData['roles'],
          maxLines: 3,
          validator: (value) => null,
          onSaved: (value) => formData['roles'] = value ?? '',
        ),
        const SizedBox(height: 20),
        const Text("Positive and Negative trends", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: "Explanation"),
          initialValue: formData['trends'],
          maxLines: 3,
          validator: (value) => null,
          onSaved: (value) => formData['trends'] = value ?? '',
        ),
        const SizedBox(height: 20),
        const Text("Taken Themes", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: "Explanation"),
          initialValue: formData['themes'],
          maxLines: 3,
          validator: (value) => null,
          onSaved: (value) => formData['themes'] = value ?? '',
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Implications and Conclusions", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: "Explanation"),
          initialValue: formData['implications'],
          maxLines: 3,
          validator: (value) => null,
          onSaved: (value) => formData['implications'] = value ?? '',
        ),
        const SizedBox(height: 20),
        const Text("Scenarios", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: "Explanation"),
          initialValue: formData['scenarios'],
          maxLines: 3,
          validator: (value) => null,
          onSaved: (value) => formData['scenarios'] = value ?? '',
        ),
        const SizedBox(height: 20),
        const Text("Future plans and activities", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: "Explanation"),
          initialValue: formData['futurePlans'],
          maxLines: 3,
          validator: (value) => null,
          onSaved: (value) => formData['futurePlans'] = value ?? '',
        ),
      ],
    );
  }

  Widget _buildStep5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Report approving body", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: "Name"),
          initialValue: formData['approvingBody'],
          validator: (value) => null,
          onSaved: (value) => formData['approvingBody'] = value ?? '',
        ),
        const SizedBox(height: 20),
        const Text("Sender Name", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: "Name"),
          initialValue: formData['senderName'],
          validator: (value) => null,
          onSaved: (value) => formData['senderName'] = value ?? '',
        ),
        const SizedBox(height: 20),
        const Text("Role", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: "Role"),
          initialValue: formData['role'],
          validator: (value) => null,
          onSaved: (value) => formData['role'] = value ?? '',
        ),
        const SizedBox(height: 20),
        const Text("Time/Month/Date", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(labelText: "Time/Month/Date"),
          initialValue: formData['date'],
          validator: (value) => null,
          onSaved: (value) => formData['date'] = value ?? '',
        ),
      ],
    );
  }
}