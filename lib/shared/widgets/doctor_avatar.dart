import 'package:flutter/material.dart';

/// Shared doctor portrait with a fallback for missing or unavailable photos.
class DoctorAvatar extends StatelessWidget {
  const DoctorAvatar({
    super.key,
    required this.doctorName,
    this.photoUrl,
    this.radius = 28,
  });

  final String doctorName;
  final String? photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = photoUrl?.trim();
    final fallback = Icon(
      Icons.person_outline_rounded,
      color: scheme.secondary,
      size: radius,
    );
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.secondaryContainer,
      child: ClipOval(
        child: SizedBox.square(
          dimension: radius * 2,
          child: url != null && url.isNotEmpty
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => fallback,
                )
              : fallback,
        ),
      ),
    );
  }
}
