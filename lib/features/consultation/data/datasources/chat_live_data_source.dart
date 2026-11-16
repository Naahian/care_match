import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/chat_repository.dart';

abstract interface class ChatLiveDataSource {
  Stream<List<Map<String, dynamic>>> watchChats(String uid);
  Stream<List<Map<String, dynamic>>> watchMessages(String chatId);
}

class FirestoreChatDataSource implements ChatLiveDataSource {
  FirestoreChatDataSource({required this.firestore});
  final FirebaseFirestore firestore;

  Map<String, dynamic> _normalize(Map<String, dynamic> data) => data.map(
    (key, value) => MapEntry(
      key,
      value is Timestamp
          ? value.toDate()
          : value is Map<String, dynamic>
          ? _normalize(value)
          : value,
    ),
  );

  Stream<List<Map<String, dynamic>>> _watch(
    Query<Map<String, dynamic>> query,
    Map<String, dynamic> Function(QueryDocumentSnapshot<Map<String, dynamic>>)
    decode,
  ) async* {
    try {
      await for (final snapshot in query.snapshots()) {
        yield snapshot.docs.map(decode).toList();
      }
    } on FirebaseException catch (error) {
      print("ERROR DETAILS:\n $error");
      throw ChatException(
        'Live chat updates are unavailable. Please retry.',
        cause: error,
        accessDenied:
            error.code == 'permission-denied' ||
            error.code == 'unauthenticated',
      );
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> watchChats(String uid) => _watch(
    firestore
        .collection('chats')
        .where('participant_uids', arrayContains: uid)
        .orderBy('updated_at', descending: true)
        .limit(20),
    (doc) => {..._normalize(doc.data()), 'chat_id': doc.id},
  );

  @override
  Stream<List<Map<String, dynamic>>> watchMessages(String chatId) => _watch(
    firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('created_at', descending: true)
        .limit(50),
    (doc) => {
      ..._normalize(doc.data()),
      'message_id': doc.id,
      'chat_id': chatId,
    },
  );
}
