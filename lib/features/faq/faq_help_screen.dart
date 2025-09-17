import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/shared/widgets/responsive_widgets.dart';

class FaqHelpScreen extends StatelessWidget {
  const FaqHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FAQ And Help'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'FAQ'),
              Tab(text: 'Contact Us'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FaqTab(),
            ContactUsTab(),
          ],
        ),
      ),
    );
  }
}

class FaqTab extends StatelessWidget {
  const FaqTab({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      "How to use this app?",
      "What is the help of this app?",
      "How to contact support?",
      "How can I reset my password if I forget it?",
      "Are there any privacy or data security measures in place?",
      "How can I change the language?",
      "How can I delete my account?",
      "How do I access my Report history?",
      "Can I use the app offline?",
    ];

    return ResponsivePadding(
      child: ListView.builder(
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(faqs[index]),
            children: [const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Detailed answer to this question will appear here..."),
            )],
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
          const Text(
            "How Can We Help You?",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 30),
          _buildContactItem("Customer Service", "09......"),
          _buildContactItem("Website", "www.hrppapp.com.et"),
          _buildContactItem("Facebook", "@ProsperityPartyHR"),
          _buildContactItem("Telegram", "@ProsperityPartyHR"),
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
