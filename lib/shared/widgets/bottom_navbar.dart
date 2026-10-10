import 'package:care_match/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  final int current;
  const BottomNavBar({super.key, required this.current});

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: current,
    onDestinationSelected: (index) {
      if (index == current) return;
      switch (index) {
        case 0:
          context.goNamed(AppRoutes.home);
        case 1:
          context.goNamed(AppRoutes.doctors);
        case 2:
          context.goNamed(AppRoutes.notifications);
        case 3:
          context.pushNamed(AppRoutes.profile);
      }
    },
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Doctors'),
      NavigationDestination(
        icon: Icon(Icons.notifications_outlined),
        selectedIcon: Icon(Icons.notifications),
        label: 'Notifications',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ],
  );
}
