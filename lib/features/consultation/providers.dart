import '../doctors/domain/entities/doctor.dart';
import '../doctors/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers.dart';
import '../auth/providers.dart';
import 'data/datasources/chat_live_data_source.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'data/repositories/video_call_repository_impl.dart';
import 'domain/repositories/chat_repository.dart';
import 'domain/repositories/video_call_repository.dart';

final consultationUserProvider = Provider<String?>(
  (ref) => ref.watch(authSessionProvider).asData?.value?.uid,
);
final chatFirestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);
final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepositoryImpl(
    dio: ref.watch(dioProvider),
    live: FirestoreChatDataSource(firestore: ref.watch(chatFirestoreProvider)),
  ),
);
final videoCallRepositoryProvider = Provider<VideoCallRepository>(
  (ref) => VideoCallRepositoryImpl(dio: ref.watch(dioProvider)),
);
final chatMessageIdProvider = Provider<String Function()>(
  (ref) =>
      () => const Uuid().v4(),
);

final consultationDoctorsProvider = FutureProvider<Map<String, Doctor>>((
  ref,
) async {
  final doctors = await ref.watch(doctorsRepositoryProvider).getDoctors();
  return {for (final doctor in doctors) doctor.id: doctor};
});
