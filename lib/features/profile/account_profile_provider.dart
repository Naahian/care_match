import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/providers.dart' show authSessionProvider;
import 'domain/entities/user_profile.dart';
import 'providers.dart';

/// Shared role/profile lookup for navigation and account-specific features.
final accountProfileProvider = FutureProvider<UserProfile>((ref) async {
  ref.watch(
    authSessionProvider.select((session) => session.asData?.value?.uid),
  );
  return ref.watch(profileRepositoryProvider).getProfile();
});
