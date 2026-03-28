import 'package:bridgelingo/features/auth/presentation/auth_provider.dart';
import 'package:bridgelingo/features/dashboard/data/course_repository.dart';
import 'package:bridgelingo/features/dashboard/domain/activity_model.dart';
import 'package:bridgelingo/features/dashboard/domain/certificate_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController(); // Store specifically for PDF
  String _fullName = '';
  // ... other vars
  String _email = '';
  final _storage = const FlutterSecureStorage();

  int _xp = 0;
  int _lessons = 0;
  int _streak = 0;
  List<RecentActivity> _recentActivity = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId != null) {
        final dio = ref.read(courseRepositoryProvider).dio;
        
        // Fetch Stats
        final statsRes = await dio.get('/progress/stats/$userId');
        
        // Fetch Activity
        final actRes = await dio.get('/progress/activity/$userId');

        if (mounted) {
          setState(() {
            _xp = statsRes.data['totalXp'];
            _lessons = statsRes.data['lessonsCompleted'];
            _streak = statsRes.data['streakDays'];
            _recentActivity = (actRes.data as List).map((e) => RecentActivity.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
      print('Failed to load stats: $e');
    }
  }

  Future<List<Certificate>> _fetchCertificates() async {
    final userId = await _storage.read(key: 'user_id');
    if (userId != null) {
      return ref.read(courseRepositoryProvider).getUserCertificates(userId);
    }
    return [];
  }

  Future<void> _loadProfile() async {
    // We saved these keys in AuthNotifier
    final name = await _storage.read(key: 'user_name');
    final email = await _storage.read(key: 'user_email'); 
    
    // Fallback if not saved
    setState(() {
      _fullName = name ?? 'User';
      _nameController.text = _fullName;
      _email = email ?? 'user@example.com';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const Gap(16),
              Text(
                _fullName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                _email,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
              const Gap(16),
              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('XP', '$_xp', Colors.orange),
                  _buildStatCard('Lessons', '$_lessons', Colors.blue),
                  _buildStatCard('Streak', '$_streak🔥', Colors.red),
                ],
              ),
              const Gap(32),
              
              // Recent Activity
              Align(alignment: Alignment.centerLeft, child: Text("Recent Activity", style: Theme.of(context).textTheme.titleLarge)),
              const Gap(16),
              if (_recentActivity.isEmpty)
                const Text("No recent activity.")
              else
                ..._recentActivity.take(3).map((act) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.check, size: 16)),
                    title: Text(act.lessonTitle),
                    trailing: Text("+${act.score} XP", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ),
                )),

              const Gap(32),
              Align(alignment: Alignment.centerLeft, child: Text("My Certificates", style: Theme.of(context).textTheme.titleLarge)),
              const Gap(16),
              FutureBuilder<List<Certificate>>(
                future: _fetchCertificates(), 
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
                  final certs = snapshot.data ?? [];
                  if (certs.isEmpty) return const Text("No certificates yet. Keep learning!");
                  
                  return Column(
                    children: certs.map((cert) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.workspace_premium, color: Colors.amber),
                        title: Text(cert.courseTitle),
                        subtitle: Text("Code: ${cert.certificateCode}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () => _downloadCertificate(cert),
                        ),
                      ),
                    )).toList(),
                  );
                }
              ),
              const Gap(40),
              _buildProfileItem(Icons.edit, 'Edit Profile', () {
                context.go('/profile/edit');
              }),
              _buildProfileItem(Icons.language, 'Language Preferences', () {
                context.go('/profile/settings');
              }),
              _buildProfileItem(Icons.help, 'Help & Support', () {
                context.go('/profile/help');
              }),
              const Gap(40), // Replace Spacer with Gap
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const Gap(40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadCertificate(Certificate cert) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text("Certificate of Completion",
                    style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 30),
                pw.Text("This certifies that", style: const pw.TextStyle(fontSize: 20)),
                pw.SizedBox(height: 10),
                pw.Text(_nameController.text.isNotEmpty ? _nameController.text : "User",
                    style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text("has successfully completed the course", style: const pw.TextStyle(fontSize: 20)),
                pw.SizedBox(height: 20),
                pw.Text(cert.courseTitle,
                    style: pw.TextStyle(fontSize: 35, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                pw.SizedBox(height: 40),
                pw.Text("Date: ${cert.issueDate}", style: const pw.TextStyle(fontSize: 18)),
                pw.Text("Certificate ID: ${cert.certificateCode}",
                    style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'certificate_${cert.certificateCode}.pdf');
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProfileItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
