import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:care_match/shared/widgets/bottom_navbar.dart';
import 'package:care_match/shared/widgets/logout_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/profile_detail_row.dart';
import '../widgets/profile_destination_card.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});
  int _age() {
    final now = DateTime.now();
    return now.year -
        1996 -
        (now.month < 3 || (now.month == 3 && now.day < 14) ? 1 : 0);
  }

  void _edit(BuildContext context) {
    // TODO: load and save the current profile through the profile repository.
    context.pushNamed(AppRoutes.setUpProfile);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(current: 3),
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: IconButton.outlined(
              tooltip: 'Edit profile',
              style: IconButton.styleFrom(
                foregroundColor: scheme.primary,
                side: BorderSide(color: scheme.outlineVariant),
              ),
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _edit(context),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: AppSpacing.page,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            // TODO: replace with the patient's profile photo asset.
                            CircleAvatar(
                              radius: 56,
                              backgroundColor: scheme.primaryContainer,
                              child: Icon(
                                Icons.person_outline_rounded,
                                size: 64,
                                color: scheme.primary,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: IconButton.filled(
                                tooltip: 'Change profile photo',
                                onPressed: () {
                                  // TODO: pick and upload a profile photo.
                                },
                                icon: const Icon(Icons.camera_alt_outlined),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Sarah Johnson',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${_age()} years old · Female',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            ProfileDetailRow(
                              icon: Icons.mail_outline_rounded,
                              label: 'Email address',
                              value: 'sarah.johnson@gmail.com',
                              onTap: () {
                                // TODO: open the email editor and verify the new email address.
                              },
                            ),
                            const Divider(),
                            ProfileDetailRow(
                              icon: Icons.calendar_month_outlined,
                              label: 'Date of birth',
                              value: 'Mar 14, 1996',
                              onTap: () => _edit(context),
                            ),
                            const Divider(),
                            ProfileDetailRow(
                              icon: Icons.person_outline_rounded,
                              label: 'Gender',
                              value: 'Female',
                              onTap: () => _edit(context),
                            ),
                            const Divider(),
                            ProfileDetailRow(
                              icon: Icons.water_drop_outlined,
                              label: 'Blood group',
                              value: 'O+',
                              onTap: () => _edit(context),
                            ),
                            const Divider(),
                            ProfileDetailRow(
                              icon: Icons.language_rounded,
                              label: 'Preferred language',
                              value: 'English',
                              onTap: () => _edit(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ProfileDestinationCard(
                        icon: Icons.description_outlined,
                        title: 'My Reports',
                        subtitle: 'Lab reports, imaging, prescriptions',
                        onTap: () => context.pushNamed(AppRoutes.reports),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ProfileDestinationCard(
                        icon: Icons.calendar_month_rounded,
                        title: 'My Appointments',
                        subtitle: 'Upcoming and past visits',
                        onTap: () => context.pushNamed(AppRoutes.appointments),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const LogoutTile(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
