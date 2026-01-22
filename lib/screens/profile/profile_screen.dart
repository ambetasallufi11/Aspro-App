import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aspro_app/l10n/app_localizations.dart';

import '../../providers/mock_providers.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.person,
                    color: Theme.of(context).colorScheme.primary, size: 30),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? l10n.guest,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(user?.email ?? l10n.notSignedIn),
                  Text(user?.phone ?? ''),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.savedAddressesTitle,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...((user?.addresses ?? const <String>[]).map(
            (address) => Card(
              child: ListTile(
                leading: const Icon(Icons.place_outlined),
                title: Text(address),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          )),
          const SizedBox(height: 24),
          Text(
            l10n.preferencesTitle,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: isDark,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).state =
                  value ? ThemeMode.dark : ThemeMode.light;
            },
            title: Text(l10n.darkMode),
            secondary: const Icon(Icons.dark_mode_outlined),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.appSettings),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showAppSettings(context, ref),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.help_outline),
              title: Text(l10n.helpSupport),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 24),
          if (user != null) ...[
            Text(
              l10n.credentialsTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.mail_outline),
                title: Text(l10n.emailLabel),
                subtitle: Text(user.email),
              ),
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: user == null
                ? null
                : () {
                    ref.read(authProvider.notifier).logout();
                    context.go('/auth/login');
                  },
            icon: const Icon(Icons.logout),
            label: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}

void _showAppSettings(BuildContext parentContext, WidgetRef ref) {
  bool notificationsEnabled = true;
  bool smsUpdatesEnabled = false;
  bool emailUpdatesEnabled = true;
  Locale? selectedLocale = ref.read(localeProvider);

  showModalBottomSheet<void>(
    context: parentContext,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final theme = Theme.of(context);
      final l10n = AppLocalizations.of(context)!;
      return StatefulBuilder(
        builder: (context, setState) {
          final currentLocale =
              selectedLocale ?? Localizations.localeOf(context);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Text(
                    l10n.appSettings,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: notificationsEnabled,
                    onChanged: (value) =>
                        setState(() => notificationsEnabled = value),
                    title: Text(l10n.pushNotifications),
                    secondary: const Icon(Icons.notifications_outlined),
                  ),
                  SwitchListTile(
                    value: smsUpdatesEnabled,
                    onChanged: (value) =>
                        setState(() => smsUpdatesEnabled = value),
                    title: Text(l10n.smsUpdates),
                    secondary: const Icon(Icons.sms_outlined),
                  ),
                  SwitchListTile(
                    value: emailUpdatesEnabled,
                    onChanged: (value) =>
                        setState(() => emailUpdatesEnabled = value),
                    title: Text(l10n.emailUpdates),
                    secondary: const Icon(Icons.mail_outline),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: Text(l10n.language),
                  ),
                  RadioListTile<Locale?>(
                    value: const Locale('en'),
                    groupValue: currentLocale,
                    onChanged: (value) {
                      setState(() => selectedLocale = value);
                      ref.read(localeProvider.notifier).state = value;
                    },
                    title: Text(l10n.english),
                  ),
                  RadioListTile<Locale?>(
                    value: const Locale('sq'),
                    groupValue: currentLocale,
                    onChanged: (value) {
                      setState(() => selectedLocale = value);
                      ref.read(localeProvider.notifier).state = value;
                    },
                    title: Text(l10n.albanian),
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: Text(l10n.privacy),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).pop();
                      Future.delayed(
                        const Duration(milliseconds: 150),
                        () => _showPrivacyModal(parentContext),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.done),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void _showPrivacyModal(BuildContext context) {
  bool shareUsage = true;
  bool personalized = true;
  bool locationAccess = true;

  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final theme = Theme.of(context);
      final l10n = AppLocalizations.of(context)!;
      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.lock_outline,
                            color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.privacyTitle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.privacySubtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: shareUsage,
                    onChanged: (value) =>
                        setState(() => shareUsage = value),
                    title: Text(l10n.privacyShareUsage),
                    subtitle: Text(l10n.privacyShareUsageDesc),
                    secondary: const Icon(Icons.analytics_outlined),
                  ),
                  SwitchListTile(
                    value: personalized,
                    onChanged: (value) =>
                        setState(() => personalized = value),
                    title: Text(l10n.privacyPersonalized),
                    subtitle: Text(l10n.privacyPersonalizedDesc),
                    secondary: const Icon(Icons.auto_awesome_outlined),
                  ),
                  SwitchListTile(
                    value: locationAccess,
                    onChanged: (value) =>
                        setState(() => locationAccess = value),
                    title: Text(l10n.privacyLocation),
                    subtitle: Text(l10n.privacyLocationDesc),
                    secondary: const Icon(Icons.my_location_outlined),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.privacyDone),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
