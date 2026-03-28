import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Frequently Asked Questions", style: Theme.of(context).textTheme.headlineSmall),
            const Gap(24),
            const _FaqItem(
              question: "How do I earn XP?",
              answer: "You earn XP by completing lessons, quizzes, and daily challenges.",
            ),
            const _FaqItem(
              question: "Can I use the app offline?",
              answer: "Currently, BridgeLingo requires an internet connection to sync your progress and access the latest lessons.",
            ),
            const _FaqItem(
              question: "How do I reset my password?",
              answer: "Go to the Login screen and tap 'Forgot Password?'. We will send you a reset link (simulation).",
            ),
            const Gap(32),
            Text("Contact Us", style: Theme.of(context).textTheme.headlineSmall),
            const Gap(16),
            const ListTile(
              leading: Icon(Icons.email),
              title: Text("support@bridgelingo.com"),
              subtitle: Text("Send us an email for further assistance."),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}
