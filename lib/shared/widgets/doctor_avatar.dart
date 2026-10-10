import 'package:flutter/material.dart';

/// Shared portraits for the demo doctors, until profile photos are provided.
class DoctorAvatar extends StatelessWidget {
  const DoctorAvatar({super.key, required this.doctorName, this.radius = 28});

  final String doctorName;
  final double radius;

  static const _femaleAsset = 'assets/images/female_doctor_avatar.png';
  static const _maleAsset = 'assets/images/male_doctor_avatar.png';
  static const _samplePortraits = {
    'Dr. Emily Carter': _femaleAsset,
    'Dr. James Patel': _maleAsset,
    'Dr. Sophia Nguyen': _femaleAsset,
    'Dr. Farzana Rahman': _femaleAsset,
    'Dr. Imtiaz Hossain': _maleAsset,
    'Dr. Nusrat Jahan': _femaleAsset,
    'Dr. Anika Sarker': _femaleAsset,
    'Dr. Rafiq Hasan': _maleAsset,
  };

  static String? assetFor(String doctorName) => _samplePortraits[doctorName];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final asset = assetFor(doctorName);
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.secondaryContainer,
      child: ClipOval(
        child: SizedBox.square(
          dimension: radius * 2,
          child: asset == null
              ? Icon(
                  Icons.person_outline_rounded,
                  color: scheme.secondary,
                  size: radius,
                )
              : Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
        ),
      ),
    );
  }
}
