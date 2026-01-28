import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() =>
      _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailUpdates = false;
  bool _marketingOptIn = false;

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showLanguagePicker() async {
    final l10n = context.l10n;
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: Text(l10n.t('Choose language'))),
              ListTile(
                title: Text(l10n.t('English')),
                onTap: () => Navigator.pop(context, 'en'),
              ),
              ListTile(
                title: Text(l10n.t('Albanian')),
                onTap: () => Navigator.pop(context, 'sq'),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      ref.read(localeProvider.notifier).setLocale(Locale(selected));
      _showSnack(l10n.t('Language updated'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final localeCode =
        locale?.languageCode ?? Localizations.localeOf(context).languageCode;
    final languageLabel =
        localeCode == 'sq' ? l10n.t('Albanian') : l10n.t('English');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('App settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.t('Notifications'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _pushNotifications,
            onChanged: (value) => setState(() => _pushNotifications = value),
            title: Text(l10n.t('Push notifications')),
            secondary: const Icon(Icons.notifications_outlined),
          ),
          SwitchListTile(
            value: _emailUpdates,
            onChanged: (value) => setState(() => _emailUpdates = value),
            title: Text(l10n.t('Email updates')),
            secondary: const Icon(Icons.mail_outline),
          ),
          SwitchListTile(
            value: _marketingOptIn,
            onChanged: (value) => setState(() => _marketingOptIn = value),
            title: Text(l10n.t('Marketing offers')),
            secondary: const Icon(Icons.campaign_outlined),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.t('Preferences'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text(l10n.t('Language')),
              subtitle: Text(languageLabel),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showLanguagePicker,
            ),
          ),
        ],
      ),
    );
  }
}
