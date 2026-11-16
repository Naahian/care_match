import 'package:care_match/core/constants/app_routes.dart';
import 'package:care_match/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/profile/account_profile_provider.dart';
import '../../features/notifications/providers.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends ConsumerWidget {
  final int current;
  const BottomNavBar({super.key, required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    String text(String value) => l10n?.text(value) ?? value;
    final unseen = ref.watch(notificationsControllerProvider).unseenCount;
    final notificationIcon = Badge(
      isLabelVisible: unseen > 0,
      label: Text(unseen > 99 ? '99+' : '$unseen'),
      child: const Icon(Icons.notifications_outlined),
    );
    final doctor =
        ref.watch(accountProfileProvider).asData?.value.role == 'doctor';
    // Call sites use the existing patient tab indices (0, 1, 2, 3).
    final selected = doctor
        ? switch (current) {
            2 => 1,
            3 => 2,
            _ => 0,
          }
        : current;
    final routes = doctor
        ? [AppRoutes.home, AppRoutes.notifications, AppRoutes.profile]
        : [
            AppRoutes.home,
            AppRoutes.doctors,
            AppRoutes.notifications,
            AppRoutes.profile,
          ];
    return NavigationBar(
      selectedIndex: selected,
      onDestinationSelected: (index) {
        if (index == selected) return;
        context.goNamed(routes[index]);
      },
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: text('Home'),
        ),
        if (!doctor)
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: text('Doctors'),
          ),
        NavigationDestination(
          icon: notificationIcon,
          selectedIcon: Badge(
            isLabelVisible: unseen > 0,
            label: Text(unseen > 99 ? '99+' : '$unseen'),
            child: const Icon(Icons.notifications),
          ),
          label: text('Notifications'),
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: text('Profile'),
        ),
      ],
    );
  }
}
