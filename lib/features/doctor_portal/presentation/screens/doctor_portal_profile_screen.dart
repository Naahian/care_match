import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../portal_controller.dart';
import '../widgets/portal_scaffold.dart';
import '../widgets/portal_profile_tile.dart';
import '../widgets/portal_edit_dialog.dart';

class DoctorPortalProfileScreen extends StatelessWidget {
  const DoctorPortalProfileScreen({super.key});

  Future<void> _editProfile(BuildContext context) async {
    final values = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => PortalEditDialog(
        title: 'Edit profile',
        fields: {
          'Name': doctorPortal.name,
          'Specialty': doctorPortal.specialty,
        },
      ),
    );
    if (values != null) {
      doctorPortal.updateProfile(
        doctorName: values['Name']!,
        doctorSpecialty: values['Specialty']!,
      );
    }
  }

  Future<void> _editDetail(
    BuildContext context,
    String field,
    String value,
  ) async {
    final values = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => PortalEditDialog(title: field, fields: {field: value}),
    );
    if (values != null) doctorPortal.updateDetail(field, values[field]!);
  }

  void _showInfo(BuildContext context, String title, String text) =>
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => PortalScaffold(
    current: 3,
    title: 'Doctor Profile',
    child: ListenableBuilder(
      listenable: doctorPortal,
      builder: (context, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final identity = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _editProfile(context),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit profile'),
              ),
            ),
            Text(
              doctorPortal.name,
              style: theme.textTheme.titleLarge?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              doctorPortal.specialty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Chip(
              avatar: Icon(
                Icons.verified_outlined,
                size: 18,
                color: scheme.primary,
              ),
              label: const Text('Verified doctor'),
              backgroundColor: scheme.primaryContainer,
              side: BorderSide.none,
            ),
          ],
        );
        final portrait = CircleAvatar(
          radius: 64,
          backgroundColor: scheme.secondaryContainer,
          child: ClipOval(
            child: Image.asset(
              'assets/images/female_doctor_avatar.png',
              width: 128,
              height: 128,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
        );
        return ListView(
          padding: AppSpacing.page,
          children: [
            LayoutBuilder(
              builder: (context, constraints) =>
                  constraints.maxWidth < 350 ||
                      MediaQuery.textScalerOf(context).scale(14) > 18
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: portrait),
                        identity,
                      ],
                    )
                  : Row(
                      children: [
                        portrait,
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: identity),
                      ],
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                Text(
                  '⌂  ${doctorPortal.hospital}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '⌖  ${doctorPortal.location}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            PortalProfileTile(
              icon: Icons.description_outlined,
              title: 'About',
              description: doctorPortal.about,
              onTap: () => _editDetail(context, 'About', doctorPortal.about),
            ),
            PortalProfileTile(
              icon: Icons.school_outlined,
              title: 'Qualifications',
              description: doctorPortal.qualifications,
              onTap: () => _editDetail(
                context,
                'Qualifications',
                doctorPortal.qualifications,
              ),
            ),
            PortalProfileTile(
              icon: Icons.language_rounded,
              title: 'Languages',
              description: doctorPortal.languages,
              onTap: () =>
                  _editDetail(context, 'Languages', doctorPortal.languages),
            ),
            PortalProfileTile(
              icon: Icons.paid_outlined,
              title: 'Consultation Fee',
              description: doctorPortal.fees,
              onTap: () =>
                  _editDetail(context, 'Consultation Fee', doctorPortal.fees),
            ),
            PortalProfileTile(
              icon: Icons.videocam_outlined,
              title: 'Consultation Types',
              description: 'Chat, Video, In-person',
              onTap: () => _showInfo(
                context,
                'Consultation Types',
                'This preview supports chat, video, and in-person appointments. Consultation services are not connected yet.',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.tonalIcon(
              onPressed: () => _showInfo(
                context,
                'Manage credentials',
                'The verified badge and qualifications are sample profile data. Credential upload and verification will be available when the doctor account service is connected.',
              ),
              icon: const Icon(Icons.verified_user_outlined),
              label: const Text('Manage credentials'),
            ),
          ],
        );
      },
    ),
  );
}
