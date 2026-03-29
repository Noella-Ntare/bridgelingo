import 'package:bridgelingo/features/auth/data/auth_repository.dart';
import 'package:bridgelingo/features/auth/presentation/auth_provider.dart';
import 'package:bridgelingo/features/dashboard/data/course_repository.dart';
import 'package:bridgelingo/features/dashboard/data/user_stats_provider.dart';
import 'package:bridgelingo/features/dashboard/domain/certificate_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final statsAsync = ref.watch(userStatsProvider);
    final certsAsync = ref.watch(_certificatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null ? const Icon(Icons.person, size: 50) : null,
            ),
            const Gap(16),
            Text(
              user?.displayName ?? 'User',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
            const Gap(24),

            // Stats
            statsAsync.when(
              data: (stats) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statCard('${stats.totalXp}', 'XP', Colors.orange),
                  _statCard('${stats.lessonsCompleted}', 'Lessons', Colors.blue),
                  _statCard('${stats.streakDays}🔥', 'Streak', Colors.red),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Could not load stats'),
            ),

            const Gap(32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('My Certificates', style: Theme.of(context).textTheme.titleLarge),
            ),
            const Gap(16),
            certsAsync.when(
              data: (certs) => certs.isEmpty
                  ? const Text('No certificates yet. Keep learning!')
                  : Column(
                      children: certs.map((cert) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.workspace_premium, color: Colors.amber),
                          title: Text(cert.courseName),
                          subtitle: Text('Issued: ${cert.issuedAt.toLocal().toString().split(' ')[0]}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () => _downloadCertificate(context, cert, user?.displayName ?? 'User'),
                          ),
                        ),
                      )).toList(),
                    ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Could not load certificates'),
            ),

            const Gap(32),
            _profileItem(Icons.edit, 'Edit Profile', () => context.push('/profile/edit')),
            _profileItem(Icons.settings, 'Settings & Preferences', () => context.push('/profile/settings')),
            _profileItem(Icons.help, 'Help & Support', () => context.push('/profile/help')),
            const Gap(32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => ref.read(authProvider.notifier).logout(),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const Gap(24),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _profileItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _downloadCertificate(BuildContext context, Certificate cert, String userName) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context ctx) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text('Certificate of Completion',
                  style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 24),
              pw.Text('This certifies that', style: const pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 8),
              pw.Text(userName, style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('has successfully completed', style: const pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 16),
              pw.Text(cert.courseName,
                  style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
              pw.SizedBox(height: 32),
              pw.Text('Date: ${cert.issuedAt.toLocal().toString().split(' ')[0]}',
                  style: const pw.TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'certificate_${cert.id}.pdf');
  }
}

final _certificatesProvider = FutureProvider<List<Certificate>>((ref) {
  return ref.watch(courseRepositoryProvider).getUserCertificates();
});
