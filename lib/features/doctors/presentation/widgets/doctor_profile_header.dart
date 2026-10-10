import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:care_match/shared/widgets/doctor_avatar.dart';
import 'doctor_profile.dart';

class DoctorProfileHeader extends StatelessWidget {
  const DoctorProfileHeader({super.key, required this.profile, this.portrait});
  final DoctorProfile profile;
  final Widget? portrait;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: AppRadius.sheet,
          child: SizedBox(
            height: 20.h.clamp(120.0, 220.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/doctor_background.png',
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
                portrait ??
                    (DoctorAvatar.assetFor(profile.summary.name) == null
                        ? Center(
                            child: DoctorAvatar(
                              doctorName: profile.summary.name,
                              radius: 48,
                            ),
                          )
                        : Image.asset(
                            DoctorAvatar.assetFor(profile.summary.name)!,
                            fit: BoxFit.contain,
                            excludeFromSemantics: true,
                          )),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          profile.summary.name,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: scheme.onPrimaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          profile.summary.specialty,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: profile.careAreas
              .map(
                (area) => Chip(
                  label: Text(area),
                  backgroundColor: scheme.primaryContainer,
                  side: BorderSide.none,
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.chip,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          profile.biography,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
