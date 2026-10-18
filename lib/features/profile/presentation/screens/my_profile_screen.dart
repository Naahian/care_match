import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:care_match/shared/widgets/bottom_navbar.dart';
import 'package:care_match/shared/widgets/logout_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/profile_controller.dart';
import '../controllers/profile_state.dart';
import '../widgets/profile_detail_row.dart';
import '../widgets/profile_destination_card.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) ref.read(profileControllerProvider.notifier).load();
    });
  }

  void _edit(BuildContext context) {
    context.pushNamed(AppRoutes.setUpProfile, extra: true).then((_) {
      if (mounted) {
        ref.read(profileControllerProvider.notifier).load(refresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.profile;
    final birth = profile?.dateOfBirth;
    final birthLabel = birth == null || birth.isAfter(DateTime.now())
        ? 'unknown'
        : MaterialLocalizations.of(context).formatMediumDate(birth);
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
                  child: RefreshIndicator(
                    onRefresh: () => ref
                        .read(profileControllerProvider.notifier)
                        .load(refresh: true),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppSpacing.page,
                      children: [
                        if (profileState.isLoading)
                          const LinearProgressIndicator(),
                        if (profileState.errorMessage != null)
                          Column(
                            children: [
                              Text(profileState.errorMessage!),
                              TextButton(
                                onPressed: () => ref
                                    .read(profileControllerProvider.notifier)
                                    .load(refresh: true),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 56,
                                backgroundColor: scheme.primaryContainer,
                                child: profile?.photoUrl == null
                                    ? Icon(
                                        Icons.person_outline_rounded,
                                        size: 64,
                                        color: scheme.primary,
                                      )
                                    : ClipOval(
                                        child: Image.network(
                                          profile!.photoUrl!,
                                          width: 112,
                                          height: 112,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => Icon(
                                            Icons.person_outline_rounded,
                                            size: 64,
                                            color: scheme.primary,
                                          ),
                                        ),
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
                          ProfileState.display(profile?.displayName),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${profileState.ageLabel(DateTime.now())} · ${ProfileState.display(profile?.gender)}',
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
                                value: ProfileState.display(profile?.email),
                              ),
                              const Divider(),
                              ProfileDetailRow(
                                icon: Icons.calendar_month_outlined,
                                label: 'Date of birth',
                                value: birthLabel,
                              ),
                              const Divider(),
                              ProfileDetailRow(
                                icon: Icons.person_outline_rounded,
                                label: 'Gender',
                                value: ProfileState.display(profile?.gender),
                              ),
                              const Divider(),
                              ProfileDetailRow(
                                icon: Icons.water_drop_outlined,
                                label: 'Blood group',
                                value: ProfileState.display(
                                  profile?.bloodGroup,
                                ),
                              ),
                              const Divider(),
                              ProfileDetailRow(
                                icon: Icons.language_rounded,
                                label: 'Preferred language',
                                value: ProfileState.display(
                                  profile?.preferredLanguage,
                                ),
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
                          onTap: () =>
                              context.pushNamed(AppRoutes.appointments),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const LogoutTile(),
                      ],
                    ),
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
