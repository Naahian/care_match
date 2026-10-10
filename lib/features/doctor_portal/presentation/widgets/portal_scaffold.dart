import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';

class PortalScaffold extends StatelessWidget {
  const PortalScaffold({
    super.key,
    required this.current,
    required this.child,
    this.title,
  });
  final int current;
  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: title == null
        ? null
        : AppBar(
            centerTitle: true,
            title: Text(
              title!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            leading: IconButton(
              tooltip: 'Back to dashboard',
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () => context.goNamed(AppRoutes.doctorDashboard),
            ),
          ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: child,
        ),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: current,
      onDestinationSelected: (index) {
        if (index == current) return;
        context.goNamed(
          [
            AppRoutes.doctorDashboard,
            AppRoutes.doctorQueue,
            AppRoutes.doctorSchedule,
            AppRoutes.doctorProfile,
          ][index],
        );
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline_rounded),
          selectedIcon: Icon(Icons.people_rounded),
          label: 'Queue',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month_rounded),
          label: 'Schedule',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    ),
  );
}
