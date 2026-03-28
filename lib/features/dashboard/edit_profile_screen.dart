import 'package:bridgelingo/features/auth/presentation/auth_provider.dart';
import 'package:bridgelingo/features/dashboard/data/course_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nativeLangController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name = await _storage.read(key: 'user_name');
    final lang = await _storage.read(key: 'native_language');
    setState(() {
      _nameController.text = name ?? '';
      _nativeLangController.text = lang ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Enter name' : null,
                ),
                const Gap(16),
                TextFormField(
                  controller: _nativeLangController,
                  decoration: const InputDecoration(labelText: 'Native Language', border: OutlineInputBorder()),
                ),
                const Gap(32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                    child: _isLoading ? const CircularProgressIndicator() : const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) throw Exception('User not found');

      // Call API
      await ref.read(courseRepositoryProvider).dio.put('/users/$userId', data: {
        'fullName': _nameController.text,
        'nativeLanguage': _nativeLangController.text,
      });

      // Update Local Storage
      await _storage.write(key: 'user_name', value: _nameController.text);
      await _storage.write(key: 'native_language', value: _nativeLangController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
