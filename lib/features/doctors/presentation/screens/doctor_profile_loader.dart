import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/doctors_controller.dart';
import '../ui_models/doctor_presentation.dart';
import '../widgets/doctor_profile.dart';

/// Resolves direct links using the supported doctors directory endpoint.
class DoctorProfileLoader extends ConsumerStatefulWidget {
  const DoctorProfileLoader({
    super.key,
    required this.doctorId,
    required this.builder,
  });
  final String doctorId;
  final Widget Function(DoctorProfile) builder;

  @override
  ConsumerState<DoctorProfileLoader> createState() =>
      _DoctorProfileLoaderState();
}

class _DoctorProfileLoaderState extends ConsumerState<DoctorProfileLoader> {
  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() {
      if (mounted) {
        unawaited(ref.read(doctorsControllerProvider.notifier).load());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorsControllerProvider);
    if (state.hasLoaded && state.errorMessage == null) {
      for (final doctor in state.doctors) {
        if (doctor.id == widget.doctorId) return widget.builder(doctor.profile);
      }
    }
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child:
            state.isLoading || (!state.hasLoaded && state.errorMessage == null)
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Doctor not found'),
                  TextButton(
                    onPressed: () => ref
                        .read(doctorsControllerProvider.notifier)
                        .load(refresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
      ),
    );
  }
}
