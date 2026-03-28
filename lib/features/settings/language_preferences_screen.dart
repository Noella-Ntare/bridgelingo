import 'package:bridgelingo/features/dashboard/data/course_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class LanguagePreferencesScreen extends ConsumerStatefulWidget {
  const LanguagePreferencesScreen({super.key});

  @override
  ConsumerState<LanguagePreferencesScreen> createState() => _LanguagePreferencesScreenState();
}

class _LanguagePreferencesScreenState extends ConsumerState<LanguagePreferencesScreen> {
  final _storage = const FlutterSecureStorage();
  String _selectedLanguage = 'English';
  bool _isLoading = false;

  final List<String> _languages = ['English', 'French (Français)', 'Swahili (Kiswahili)'];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final lang = await _storage.read(key: 'native_language');
    if (lang != null && mounted) {
      if (_languages.contains(lang)) {
        setState(() => _selectedLanguage = lang);
      } else {
        // Handle case where stored string differs from options
        setState(() => _selectedLanguage = 'English');
      }
    }
  }

  Future<void> _saveLanguage() async {
    setState(() => _isLoading = true);
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) return;

      // Update Backend (Reusing user update endpoint)
      // Note: In real app, might want specific endpoint or ensure other fields aren't wiped.
      // For now assuming the PUT merges or we only send what we change if backend supports PATCH.
      // Based on previous edit_profile, it sends both name and lang. Let's try to get name first.
      
      final name = await _storage.read(key: 'user_name') ?? 'User';

      await ref.read(courseRepositoryProvider).dio.put('/users/$userId', data: {
        'fullName': name, 
        'nativeLanguage': _selectedLanguage,
      });

      await _storage.write(key: 'native_language', value: _selectedLanguage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Language updated!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language Preferences')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("Select your native language for translations."),
            const Gap(24),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              items: _languages.map((String lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _selectedLanguage = newValue);
                }
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const Gap(32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _saveLanguage,
                style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
