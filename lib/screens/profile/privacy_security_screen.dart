import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _twoFactor = false;
  bool _biometrics = false;

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showChangePassword() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        return AlertDialog(
          title: Text(l10n.t('Change password')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.t('Current password'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.t('New password'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.t('Confirm password'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.t('Cancel')),
            ),
            FilledButton(
              onPressed: () {
                if (newController.text.isEmpty ||
                    newController.text != confirmController.text) {
                  _showSnack(l10n.t('Passwords do not match'));
                  return;
                }
                Navigator.pop(context, true);
              },
              child: Text(l10n.t('Save')),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _showSnack(context.l10n.t('Password updated'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.t('Privacy & security')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.l10n.t('Security'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(context.l10n.t('Change password')),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showChangePassword,
            ),
          ),
          SwitchListTile(
            value: _twoFactor,
            onChanged: (value) => setState(() => _twoFactor = value),
            title: Text(context.l10n.t('Two-factor authentication')),
            secondary: const Icon(Icons.verified_user_outlined),
          ),
          SwitchListTile(
            value: _biometrics,
            onChanged: (value) => setState(() => _biometrics = value),
            title: Text(context.l10n.t('Biometric unlock')),
            secondary: const Icon(Icons.fingerprint),
          ),
        ],
      ),
    );
  }
}
