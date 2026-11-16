import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/app_localizations.dart';
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

  Future<void> _feedback(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@carematch.app',
      queryParameters: {'subject': 'CareMatch app feedback'},
    );
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        _showAvailability(
          context,
          'Feedback',
          'No email app is available on this device.',
        );
      }
    } on PlatformException {
      if (context.mounted) {
        _showAvailability(
          context,
          'Feedback',
          'Could not open the email app. Restart the app after updating it and try again.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        _showAvailability(context, 'Feedback', 'Could not open the email app.');
      }
    }
  }

  Future<void> _openPrivacyAndTerms(BuildContext context) async {
    try {
      final opened = await launchUrl(
        Uri.parse('https://naahian.vercel.app/'),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        _showAvailability(
          context,
          'Privacy and terms',
          'Could not open the privacy and terms page.',
        );
      }
    } on PlatformException {
      if (context.mounted) {
        _showAvailability(
          context,
          'Privacy and terms',
          'Could not open the privacy and terms page.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        _showAvailability(
          context,
          'Privacy and terms',
          'Could not open the privacy and terms page.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          l10n.text('Preferences'),
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
                    title: l10n.text('App settings'),
                    children: [
                      PreferenceTile(
                        icon: Icons.language_rounded,
                        title: l10n.text('Language'),
                        subtitle: l10n.text('Choose Bangla or English'),
                        trailing: Switch(
                          value: appPreferences.language == 'Bangla',
                          onChanged: (value) => appPreferences.setLanguage(
                            value ? 'Bangla' : 'English',
                          ),
                        ),
                        onTap: () => appPreferences.setLanguage(
                          appPreferences.language == 'Bangla'
                              ? 'English'
                              : 'Bangla',
                        ),
                      ),
                      PreferenceTile(
                        icon: Icons.dark_mode_outlined,
                        iconColor: scheme.tertiary,
                        iconBackground: scheme.tertiaryContainer,
                        title: l10n.text('Theme'),
                        subtitle: l10n.text('Choose app appearance'),
                        trailing: PreferenceThemeSelector(
                          value: appPreferences.themeMode,
                          onChanged: appPreferences.setThemeMode,
                        ),
                      ),
                      PreferenceTile(
                        icon: Icons.info_outline,
                        title: l10n.text('About'),
                        subtitle: l10n.text('About CareMatch'),
                        onTap: () => context.pushNamed(AppRoutes.about),
                      ),
                      PreferenceTile(
                        icon: Icons.privacy_tip_outlined,
                        title: l10n.text('Privacy and terms'),
                        subtitle: l10n.text(
                          'Read privacy and terms information',
                        ),
                        onTap: () => _openPrivacyAndTerms(context),
                      ),
                      PreferenceTile(
                        icon: Icons.feedback_outlined,
                        title: l10n.text('Feedback'),
                        subtitle: l10n.text('Send feedback by email'),
                        onTap: () => _feedback(context),
                      ),
                    ],
                  ),
                  PreferenceSection(
                    title: l10n.text('Privacy and terms'),
                    children: [
                      _destination(
                        context,
                        icon: Icons.delete_sweep_outlined,
                        iconColor: scheme.error,
                        iconBackground: scheme.errorContainer,
                        title: l10n.text(
                          'Delete prescription and appointment data',
                        ),
                        subtitle: l10n.text(
                          'Request removal of your medical records',
                        ),
                        message:
                            'Data deletion is not available yet. Your prescriptions and appointments have not been deleted.',
                      ),
                      PreferenceTile(
                        icon: Icons.psychology_outlined,
                        title: l10n.text('Share anonymized AI checkup data'),
                        subtitle: l10n.text(
                          'Help improve AI checkups without sharing your identity',
                        ),
                        trailing: Switch(
                          value: appPreferences.shareAnonymousData,
                          onChanged: appPreferences.setShareAnonymousData,
                        ),
                        onTap: () => appPreferences.setShareAnonymousData(
                          !appPreferences.shareAnonymousData,
                        ),
                      ),
                    ],
                  ),
                  PreferenceSection(
                    title: l10n.text('Account'),
                    children: [
                      _destination(
                        context,
                        icon: Icons.delete_outline_rounded,
                        iconColor: scheme.error,
                        iconBackground: scheme.errorContainer,
                        title: l10n.text('Account deletion'),
                        subtitle: l10n.text('Permanently delete your account'),
                        message:
                            'Account deletion is not yet available in this preview. No account will be deleted.',
                      ),
                      const LogoutTile(),
                    ],
                  ),
                  PreferenceSection(
                    title: l10n.text('Accessibility'),
                    children: [
                      PreferenceTile(
                        icon: Icons.text_increase_rounded,
                        title: l10n.text('Larger text'),
                        subtitle: l10n.text(
                          'Increase text size throughout the app',
                        ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
