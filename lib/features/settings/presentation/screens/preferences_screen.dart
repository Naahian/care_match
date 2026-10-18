import 'package:flutter/material.dart';
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
                        icon: Icons.delete_outline_rounded,
                        iconColor: scheme.error,
                        iconBackground: scheme.errorContainer,
                        title: 'Account deletion',
                        subtitle: 'Permanently delete your account',
                        message:
                            'Account deletion is not yet available in this preview. No account will be deleted.',
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
