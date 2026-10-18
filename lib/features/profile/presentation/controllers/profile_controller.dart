import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers.dart' show authSessionProvider;
import '../../domain/repositories/profile_repository.dart';
import '../../providers.dart';
import 'profile_state.dart';

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);

class ProfileController extends Notifier<ProfileState> {
  int _revision = 0;

  @override
  ProfileState build() {
    ref.onDispose(() => _revision++);
    // Keep account invalidation active even when this cached controller has
    // no screen listeners (Riverpod pauses ordinary ref.listen subscriptions).
    final sessionSubscription = ref.container.listen(authSessionProvider, (
      previous,
      next,
    ) {
      if (!ref.mounted) return;
      if (next.isLoading) return;
      if (next.hasError) {
        _revision++;
        state = const ProfileState(
          errorMessage: 'Sign in again to load your profile.',
        );
        return;
      }
      if (previous?.asData?.value?.uid == next.asData?.value?.uid) return;
      _revision++;
      state = const ProfileState();
      if (next.asData?.value != null) unawaited(load());
    });
    ref.onDispose(sessionSubscription.close);
    return const ProfileState();
  }

  Future<void> load({bool refresh = false}) async {
    if (state.isLoading || (state.profile != null && !refresh)) return;
    final revision = ++_revision;
    state = ProfileState(profile: state.profile, isLoading: true);
    try {
      final profile = await ref.read(profileRepositoryProvider).getProfile();
      if (!ref.mounted || revision != _revision) return;
      state = ProfileState(profile: profile);
    } catch (error) {
      if (!ref.mounted || revision != _revision) return;
      state = ProfileState(
        profile: state.profile,
        errorMessage: error is ProfileException
            ? error.message
            : 'Could not load your profile. Please try again.',
      );
    }
  }
}
