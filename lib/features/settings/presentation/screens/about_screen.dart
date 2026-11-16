import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _features = [
    (
      Icons.medical_services_outlined,
      'Find the right care',
      'Discover healthcare professionals and connect with a doctor suited to your needs.',
    ),
    (
      Icons.health_and_safety_outlined,
      'AI health checkups',
      'Describe symptoms and get an assessment to help guide your next steps.',
    ),
    (
      Icons.calendar_month_outlined,
      'Manage appointments',
      'Book consultations, keep track of appointments, and access your care records.',
    ),
    (
      Icons.video_call_outlined,
      'Consult remotely',
      'Meet healthcare professionals through online consultations.',
    ),
  ];

  static const _technology = [
    'Flutter',
    'Riverpod',
    'Clean Architecture',
    'Firebase',
    'FastAPI',
    'Render',
    'Agora',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.text('About CareMatch')),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        size: 38,
                        color: colors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.text('Care, connected.'),
                        style: textTheme.headlineSmall?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.text(
                          'CareMatch brings patients and healthcare professionals together, making it easier to find care, manage appointments, and stay connected throughout the care journey.',
                        ),
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.onPrimaryContainer,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(l10n.text('What you can do'), style: textTheme.titleLarge),
                const SizedBox(height: 12),
                for (final feature in _features) ...[
                  Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: colors.secondaryContainer,
                        foregroundColor: colors.onSecondaryContainer,
                        child: Icon(feature.$1),
                      ),
                      title: Text(
                        l10n.text(feature.$2),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(l10n.text(feature.$3)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Text(l10n.text('Built with'), style: textTheme.titleLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in _technology)
                      Chip(
                        label: Text(item),
                        backgroundColor: colors.surfaceContainerHighest,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
