import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

class ProfileDestinationCard extends StatelessWidget {
  const ProfileDestinationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: ListTile(
      contentPadding: AppSpacing.card,
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.secondary,
        size: 32,
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Theme.of(context).colorScheme.secondary,
      ),
      onTap: onTap,
    ),
  );
}
