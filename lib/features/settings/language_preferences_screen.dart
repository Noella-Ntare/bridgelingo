import 'package:bridgelingo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, bool>((ref) {
  return NotificationsNotifier();
});

class NotificationsNotifier extends StateNotifier<bool> {
  NotificationsNotifier() : super(true) {
    _load();
  }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(kNotificationsKey) ?? true;
  }
  Future<void> toggle(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kNotificationsKey, value);
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('English') {
    _load();
  }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(kLanguageKey) ?? 'English';
  }
  Future<void> setLanguage(String lang) async {
    state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kLanguageKey, lang);
  }
}

class LanguagePreferencesScreen extends ConsumerWidget {
  const LanguagePreferencesScreen({super.key});

  static const List<String> _languages = [
    'English',
    'French (Français)',
    'Swahili (Kiswahili)',
  ];

  static const List<String> _themeLabels = ['System', 'Light', 'Dark'];
  static const List<ThemeMode> _themeModes = [
    ThemeMode.system,
    ThemeMode.light,
    ThemeMode.dark,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final notifications = ref.watch(notificationsProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Gap(12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Theme'),
                  const Gap(8),
                  SegmentedButton<ThemeMode>(
                    segments: List.generate(_themeLabels.length, (i) =>
                      ButtonSegment(value: _themeModes[i], label: Text(_themeLabels[i])),
                    ),
                    selected: {themeMode},
                    onSelectionChanged: (Set<ThemeMode> val) {
                      ref.read(themeModeProvider.notifier).setTheme(val.first);
                    },
                  ),
                ],
              ),
            ),
          ),

          const Gap(24),
          Text('Language', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Gap(12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                value: language,
                decoration: const InputDecoration(
                  labelText: 'Native Language',
                  border: OutlineInputBorder(),
                ),
                items: _languages.map((lang) =>
                  DropdownMenuItem(value: lang, child: Text(lang)),
                ).toList(),
                onChanged: (val) {
                  if (val != null) ref.read(languageProvider.notifier).setLanguage(val);
                },
              ),
            ),
          ),

          const Gap(24),
          Text('Notifications', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Gap(12),
          Card(
            child: SwitchListTile(
              title: const Text('Daily Learning Reminders'),
              subtitle: const Text('Get reminded to practice every day'),
              value: notifications,
              onChanged: (val) => ref.read(notificationsProvider.notifier).toggle(val),
            ),
          ),

          const Gap(32),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preferences saved!')),
              );
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            child: const Text('Save Preferences'),
          ),
        ],
      ),
    );
  }
}
