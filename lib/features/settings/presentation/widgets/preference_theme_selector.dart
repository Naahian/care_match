import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/localization/app_localizations.dart';

class PreferenceThemeSelector extends StatelessWidget {
  const PreferenceThemeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: AppRadius.button,
      ),
      child: Wrap(
        children: [
          for (final entry in const {
            ThemeMode.light: 'Light',
            ThemeMode.dark: 'Dark',
            ThemeMode.system: 'System',
          }.entries)
            Semantics(
              selected: value == entry.key,
              child: TextButton(
                onPressed: () => onChanged(entry.key),
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  foregroundColor: value == entry.key
                      ? scheme.onPrimary
                      : scheme.onSurfaceVariant,
                  backgroundColor: value == entry.key
                      ? scheme.primary
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                  textStyle: theme.textTheme.labelSmall,
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                child: Text(l10n.text(entry.value)),
              ),
            ),
        ],
      ),
    );
  }
}
