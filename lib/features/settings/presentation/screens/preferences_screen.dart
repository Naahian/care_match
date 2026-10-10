import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/logout_tile.dart';
import '../../preferences_controller.dart';
import '../widgets/preference_section.dart';
import '../widgets/preference_theme_selector.dart';
import '../widgets/preference_tile.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  void _showAvailability(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _destination(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String message,
    Color? iconColor,
    Color? iconBackground,
  }) => PreferenceTile(
    icon: icon,
    title: title,
    subtitle: subtitle,
    iconColor: iconColor,
    iconBackground: iconBackground,
    onTap: () => _showAvailability(context, title, message),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Preferences',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: scheme.onPrimaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.chevron_left_rounded),
          color: scheme.primary,
          onPressed: () => context.canPop()
              ? context.pop()
              : context.goNamed(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListenableBuilder(
              listenable: appPreferences,
              builder: (context, _) => ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                children: [
                  PreferenceSection(
                    title: 'App settings',
                    children: [
                      PreferenceTile(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        subtitle: 'Choose your preferred language',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'English',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: scheme.primary),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: scheme.primary,
                              size: 22,
                            ),
                          ],
                        ),
                        onTap: () => _showAvailability(
                          context,
                          'Language',
                          'English is currently available. More app languages are coming soon.',
                        ),
                      ),
                      PreferenceTile(
                        icon: Icons.dark_mode_outlined,
                        iconColor: scheme.tertiary,
                        iconBackground: scheme.tertiaryContainer,
                        title: 'Theme',
                        subtitle: 'Choose app appearance',
                        trailing: PreferenceThemeSelector(
                          value: appPreferences.themeMode,
                          onChanged: appPreferences.setThemeMode,
                        ),
                      ),
                    ],
                  ),
                  PreferenceSection(
                    title: 'Notifications',
                    children: [
                      _destination(
                        context,
                        icon: Icons.notifications_none_rounded,
                        title: 'Push notifications',
                        subtitle:
                            "Choose what you’d like to be notified about.",
                        message:
                            'Notification preferences will be available when push notifications are connected.',
                      ),
                    ],
                  ),
                  PreferenceSection(
                    title: 'Privacy controls',
                    children: [
                      _destination(
                        context,
                        icon: Icons.delete_outline_rounded,
                        iconColor: scheme.error,
                        iconBackground: scheme.errorContainer,
                        title: 'Account deletion',
                        subtitle: 'Permanently delete your account',
                        message:
                            'Account deletion is not yet available in this preview. No account will be deleted.',
                      ),
                      _destination(
                        context,
                        icon: Icons.storage_rounded,
                        title: 'Data deletion',
                        subtitle: 'Request a copy or deletion of your data',
                        message:
                            'Data export and deletion requests will be available when your account is connected.',
                      ),
                      _destination(
                        context,
                        icon: Icons.people_outline_rounded,
                        title: 'Share records with doctors',
                        subtitle: 'Control who can access your records',
                        message:
                            'Record access controls will be available when medical record sharing is connected.',
                      ),
                      PreferenceTile(
                        icon: Icons.shield_outlined,
                        iconColor: scheme.secondary,
                        iconBackground: scheme.secondaryContainer,
                        title: 'Share anonymized AI chat data',
                        subtitle:
                            'Help improve CareMatch with anonymous chat data',
                        trailing: Switch(
                          value: appPreferences.shareAnonymousData,
                          onChanged: appPreferences.setShareAnonymousData,
                          thumbIcon: WidgetStateProperty.all(const Icon(null)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        onTap: () => appPreferences.setShareAnonymousData(
                          !appPreferences.shareAnonymousData,
                        ),
                      ),
                    ],
                  ),
                  PreferenceSection(
                    title: 'Account',
                    children: [
                      _destination(
                        context,
                        icon: Icons.lock_outline_rounded,
                        title: 'Change password',
                        subtitle: 'Update your password',
                        message:
                            'Password changes will be available when account security is connected.',
                      ),
                      _destination(
                        context,
                        icon: Icons.link_rounded,
                        title: 'Linked accounts',
                        subtitle: 'Google, Apple, or other accounts',
                        message:
                            'Account linking will be available when sign-in providers are connected.',
                      ),
                    ],
                  ),
                  PreferenceSection(
                    title: 'Accessibility',
                    children: [
                      PreferenceTile(
                        icon: Icons.text_increase_rounded,
                        title: 'Larger text',
                        subtitle: 'Increase text size throughout the app',
                        trailing: Switch(
                          value: appPreferences.largerText,
                          onChanged: appPreferences.setLargerText,
                          thumbIcon: WidgetStateProperty.all(const Icon(null)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        onTap: () => appPreferences.setLargerText(
                          !appPreferences.largerText,
                        ),
                      ),
                    ],
                  ),
                  const LogoutTile(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
