import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailUpdates = false;
  bool _marketingOptIn = false;
  String _language = 'English';

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showLanguagePicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Choose language')),
              ListTile(
                title: const Text('English'),
                onTap: () => Navigator.pop(context, 'English'),
              ),
              ListTile(
                title: const Text('Albanian'),
                onTap: () => Navigator.pop(context, 'Albanian'),
              ),
              ListTile(
                title: const Text('Italian'),
                onTap: () => Navigator.pop(context, 'Italian'),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null && selected != _language) {
      setState(() => _language = selected);
      _showSnack('Language updated to $selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Notifications',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _pushNotifications,
            onChanged: (value) => setState(() => _pushNotifications = value),
            title: const Text('Push notifications'),
            secondary: const Icon(Icons.notifications_outlined),
          ),
          SwitchListTile(
            value: _emailUpdates,
            onChanged: (value) => setState(() => _emailUpdates = value),
            title: const Text('Email updates'),
            secondary: const Icon(Icons.mail_outline),
          ),
          SwitchListTile(
            value: _marketingOptIn,
            onChanged: (value) => setState(() => _marketingOptIn = value),
            title: const Text('Marketing offers'),
            secondary: const Icon(Icons.campaign_outlined),
          ),
          const SizedBox(height: 20),
          Text(
            'Preferences',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.language_outlined),
              title: const Text('Language'),
              subtitle: Text(_language),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showLanguagePicker,
            ),
          ),
        ],
      ),
    );
  }
}
