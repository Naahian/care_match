import 'dart:async';
import 'package:care_match/features/consultation/domain/entities/chat.dart';
import 'package:care_match/features/consultation/domain/repositories/chat_repository.dart';
import 'package:care_match/features/consultation/presentation/controllers/chat_list_controller.dart';
import 'package:care_match/features/consultation/presentation/controllers/conversation_controller.dart';
import 'package:care_match/features/consultation/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/chat_test_scope.dart';

Future<void> flush() => Future<void>.delayed(Duration.zero);
final _user = NotifierProvider<_User, String?>(_User.new);

class _User extends Notifier<String?> {
  @override
  String? build() => 'patient';
  void change(String? uid) => state = uid;
}

void main() {
  late TestChatRepository repository;
  late ProviderContainer container;
  final provider = conversationControllerProvider(testChatId);
  setUp(() {
    repository = TestChatRepository();
    container = ProviderContainer(
      overrides: [
        consultationUserProvider.overrideWith((ref) => ref.watch(_user)),
        chatRepositoryProvider.overrideWithValue(repository),
        chatMessageIdProvider.overrideWithValue(() => testMessageId),
      ],
    );
    container.listen(provider, (_, _) {});
  });
  tearDown(() async {
    container.dispose();
    await repository.dispose();
  });

  test(
    'loads the inbox, receives live updates and creates a recipient chat',
    () async {
      container.listen(chatListControllerProvider, (_, _) {});
      final controller = container.read(chatListControllerProvider.notifier);
      await controller.load();
      expect(
        container.read(chatListControllerProvider).chats.single.id,
        testChatId,
      );
      repository.liveChats.add([testChat()]);
      await flush();
      expect(container.read(chatListControllerProvider).chats, hasLength(1));
      expect((await controller.startChat('doctor'))!.id, testChatId);
      expect(repository.recipient, 'doctor');
    },
  );
  test('merges API and live messages once, retaining older pages', () async {
    repository.messages = [testMessage()];
    repository.messageCursor = 'older';
    final controller = container.read(provider.notifier);
    await controller.open();
    repository.liveMessages.add([
      testMessage(),
      testMessage(id: 'new', minute: 2),
    ]);
    await flush();
    expect(container.read(provider).messages.map((m) => m.id), [
      'new',
      'message-1',
    ]);
    repository.messages = [testMessage(id: 'older', minute: -2)];
    repository.messageCursor = null;
    await controller.loadOlder();
    expect(repository.requestedCursors.last, 'older');
    repository.liveMessages.add([testMessage(id: 'new', minute: 2)]);
    await flush();
    expect(container.read(provider).messages, hasLength(3));
    expect(container.read(provider).nextCursor, isNull);
  });
  test(
    'retry reuses the UUID and text after a failed send; duplicate taps are ignored',
    () async {
      final controller = container.read(provider.notifier);
      await controller.open();
      repository.pendingSend = Completer<ConsultationMessage>();
      final send = controller.send(' Hello ');
      expect(await controller.send('Hello'), isFalse);
      expect(repository.sends, 1);
      repository.pendingSend!.completeError(
        const ChatException('Timed out', mayHaveSucceeded: true),
      );
      expect(await send, isFalse);
      expect(container.read(provider).pending!.id, testMessageId);
      repository.pendingSend = null;
      expect(await controller.send('Different text'), isFalse);
      expect(await controller.send('Hello'), isTrue);
      await flush();
      expect(repository.sentIds, [testMessageId, testMessageId]);
      expect(container.read(provider).messages, hasLength(1));
      expect(container.read(provider).pending, isNull);
    },
  );
  test(
    'permission errors clear messages and stop the live subscription',
    () async {
      repository.messages = [testMessage()];
      await container.read(provider.notifier).open();
      repository.liveMessages.addError(
        const ChatException('Denied', accessDenied: true),
      );
      await flush();
      expect(container.read(provider).messages, isEmpty);
      expect(container.read(provider).chat, isNull);
      expect(repository.liveMessages.hasListener, isFalse);
    },
  );
  test(
    'account changes clear history and ignore an old send completion',
    () async {
      repository.messages = [testMessage()];
      final controller = container.read(provider.notifier);
      await controller.open();
      repository.pendingSend = Completer<ConsultationMessage>();
      final sending = controller.send('Hello');
      container.read(_user.notifier).change('another-account');
      expect(container.read(provider).messages, isEmpty);
      repository.pendingSend!.complete(
        testMessage(id: testMessageId, text: 'Hello', sender: 'patient'),
      );
      expect(await sending, isFalse);
      await flush();
      expect(container.read(provider).messages, isEmpty);
      expect(repository.liveMessages.hasListener, isFalse);
    },
  );
  test('reconciles messages missed when the live window jumps ahead', () async {
    repository.messages = [testMessage(id: 'old')];
    final controller = container.read(provider.notifier);
    await controller.open();
    repository.messageLoader = (cursor) async => cursor == null
        ? ChatPage(
            items: [testMessage(id: 'new', minute: 10)],
            nextCursor: 'middle',
          )
        : ChatPage(
            items: [
              testMessage(id: 'middle', minute: 5),
              testMessage(id: 'old'),
            ],
          );
    repository.liveMessages.add([testMessage(id: 'new', minute: 10)]);
    await flush();
    await flush();
    expect(container.read(provider).messages.map((m) => m.id), [
      'new',
      'middle',
      'old',
    ]);
  });
  test('definite send rejections do not lock editing', () async {
    final controller = container.read(provider.notifier);
    await controller.open();
    repository.sendFailure = const ChatException('Message rejected');
    expect(await controller.send('Hello'), isFalse);
    expect(container.read(provider).pending, isNull);
    expect(container.read(provider).sendError, 'Message rejected');
  });

  test('live and history failures keep an in-flight send locked', () async {
    final controller = container.read(provider.notifier);
    await controller.open();
    repository.pendingSend = Completer<ConsultationMessage>();
    final sending = controller.send('Hello');

    repository.liveMessages.addError(const ChatException('Live disconnected'));
    await flush();
    expect(container.read(provider).liveError, 'Live disconnected');
    expect(container.read(provider).isSending, isTrue);
    expect(await controller.send('Hello'), isFalse);

    repository.messageLoader = (_) async =>
        throw const ChatException('Offline');
    await controller.refresh();
    expect(container.read(provider).isSending, isTrue);
    expect(await controller.send('Hello'), isFalse);
    expect(repository.sends, 1);

    repository.pendingSend!.complete(
      testMessage(id: testMessageId, text: 'Hello', sender: 'patient'),
    );
    expect(await sending, isTrue);
    expect(container.read(provider).isSending, isFalse);
    expect(container.read(provider).pending, isNull);
  });

  test('live inbox failures keep chat creation locked', () async {
    container.listen(chatListControllerProvider, (_, _) {});
    final controller = container.read(chatListControllerProvider.notifier);
    await controller.load();
    repository.pendingCreate = Completer<ConsultationChat>();
    final creating = controller.startChat('doctor');
    repository.liveChats.addError(const ChatException('Live disconnected'));
    await flush();
    expect(container.read(chatListControllerProvider).isCreating, isTrue);
    expect(await controller.startChat('doctor'), isNull);
    expect(repository.creates, 1);
    repository.pendingCreate!.complete(testChat());
    expect((await creating)!.id, testChatId);
    expect(container.read(chatListControllerProvider).isCreating, isFalse);
  });

  test(
    'new live gaps during catch-up queue another pass to the original anchor',
    () async {
      repository.messages = [testMessage(id: 'old')];
      final controller = container.read(provider.notifier);
      await controller.open();
      final firstPage = Completer<ChatPage<ConsultationMessage>>();
      var latestRequests = 0;
      repository.messageLoader = (cursor) async {
        if (cursor == null && latestRequests++ == 0) return firstPage.future;
        if (cursor == null) {
          return ChatPage(
            items: [testMessage(id: 'newest', minute: 20)],
            nextCursor: 'gap',
          );
        }
        return ChatPage(
          items: [
            testMessage(id: 'missed', minute: 15),
            testMessage(id: 'new', minute: 10),
            testMessage(id: 'old'),
          ],
        );
      };
      repository.liveMessages.add([testMessage(id: 'new', minute: 10)]);
      await flush();
      repository.liveMessages.add([testMessage(id: 'newest', minute: 20)]);
      await flush();
      firstPage.complete(
        ChatPage(
          items: [
            testMessage(id: 'new', minute: 10),
            testMessage(id: 'old'),
          ],
        ),
      );
      await flush();
      await flush();
      expect(container.read(provider).messages.map((m) => m.id), [
        'newest',
        'missed',
        'new',
        'old',
      ]);
      expect(latestRequests, 2);
    },
  );

  test(
    'reconnect starts catch-up while an obsolete refresh is pending',
    () async {
      repository.messages = [testMessage(id: 'old')];
      final controller = container.read(provider.notifier);
      await controller.open();
      final obsoletePage = Completer<ChatPage<ConsultationMessage>>();
      repository.messageLoader = (_) => obsoletePage.future;
      final obsoleteRefresh = controller.refresh();
      repository.messageLoader = (cursor) async => cursor == null
          ? ChatPage(
              items: [testMessage(id: 'new', minute: 10)],
              nextCursor: 'gap',
            )
          : ChatPage(
              items: [
                testMessage(id: 'missed', minute: 5),
                testMessage(id: 'old'),
              ],
            );
      await controller.open();
      expect(container.read(provider).messages.map((m) => m.id), [
        'new',
        'missed',
        'old',
      ]);
      obsoletePage.complete(ChatPage(items: [testMessage(id: 'obsolete')]));
      await obsoleteRefresh;
      expect(
        container.read(provider).messages.any((m) => m.id == 'obsolete'),
        isFalse,
      );
    },
  );

  test(
    'catch-up includes every page when the conversation was initially empty',
    () async {
      final controller = container.read(provider.notifier);
      await controller.open();
      repository.messageLoader = (cursor) async => cursor == null
          ? ChatPage(
              items: [testMessage(id: 'new', minute: 10)],
              nextCursor: 'middle',
            )
          : ChatPage(items: [testMessage(id: 'middle', minute: 5)]);
      repository.liveMessages.add([testMessage(id: 'new', minute: 10)]);
      await flush();
      await flush();
      expect(container.read(provider).messages.map((m) => m.id), [
        'new',
        'middle',
      ]);
    },
  );
  test('inbox refresh updates the cursor as conversations grow', () async {
    container.listen(chatListControllerProvider, (_, _) {});
    final controller = container.read(chatListControllerProvider.notifier);
    await controller.load();
    expect(container.read(chatListControllerProvider).nextCursor, isNull);
    repository.chatCursor = 'older-chat';
    await controller.load();
    expect(container.read(chatListControllerProvider).nextCursor, 'older-chat');
  });

  test(
    'reconnecting during a send preserves a retry without leaving it loading',
    () async {
      final controller = container.read(provider.notifier);
      await controller.open();
      repository.pendingSend = Completer<ConsultationMessage>();
      final sending = controller.send('Hello');
      await controller.open();
      expect(container.read(provider).isSending, isFalse);
      expect(container.read(provider).pending!.id, testMessageId);
      repository.pendingSend!.complete(
        testMessage(id: testMessageId, text: 'Hello', sender: 'patient'),
      );
      expect(await sending, isFalse);
      repository.pendingSend = null;
      expect(await controller.send('Hello'), isTrue);
      expect(repository.sentIds, [testMessageId, testMessageId]);
    },
  );
}
