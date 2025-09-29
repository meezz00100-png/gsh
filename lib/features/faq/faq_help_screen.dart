import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/shared/widgets/responsive_widgets.dart';
import 'package:harari_prosperity_app/shared/localization/app_localizations.dart';

class FaqHelpScreen extends StatelessWidget {
  const FaqHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('ጥያቄዎች እና እርዳታ'),
          bottom: TabBar(
            tabs: [
              Tab(text: context.translate('faq')),
              Tab(text: context.translate('contactUs')),
            ],
          ),
        ),
        body: TabBarView(children: [FaqTab(), ContactUsTab()]),
      ),
    );
  }
}

class FaqTab extends StatelessWidget {
  const FaqTab({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      context.translate('howCreateReport'),
      context.translate('whatTypesReports'),
      context.translate('howAttachFiles'),
      context.translate('canSaveDraft'),
      context.translate('howViewReports'),
      context.translate('reportApprovalProcess'),
      context.translate('howEditProfile'),
      context.translate('howChangePassword'),
      context.translate('howContactSupport'),
    ];
    return ResponsivePadding(
      child: ListView.builder(
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(faqs[index]),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(context.translate('faqAnswer')),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ContactUsTab extends StatelessWidget {
  const ContactUsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsivePadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.translate('howCanWeHelp'),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 30),
          _buildContactItem(context.translate('customerService'), "09......"),
          _buildContactItem(context.translate('website'), "www.hrppapp.com.et"),
          _buildContactItem(
            context.translate('facebook'),
            "@ProsperityPartyHR",
          ),
          _buildContactItem(
            context.translate('telegram'),
            "@ProsperityPartyHR",
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
