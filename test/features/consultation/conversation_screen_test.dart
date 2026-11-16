import 'dart:async';
import 'package:care_match/features/consultation/domain/entities/chat.dart';
import 'package:care_match/features/consultation/presentation/widgets/conversation_card_shimmer.dart';
import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/consultation/domain/repositories/chat_repository.dart';
import 'package:care_match/features/consultation/presentation/screens/chat_list_screen.dart';
import 'package:care_match/features/consultation/presentation/screens/conversation_screen.dart';
import 'package:care_match/main.dart';
import 'package:care_match/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../support/chat_test_scope.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  testWidgets('API conversation cards open by ID and support back navigation', (
    tester,
  ) async {
    final repository = TestChatRepository();
    addTearDown(repository.dispose);
    final router = createAppRouter(initialLocation: '/consultation/chat');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      chatTestScope(
        Sizer(builder: (_, _, _) => MyApp(router: router)),
        repository: repository,
      ),
    );
    await tester.pumpAndSettle();
    final card = find.text('Conversation');
    await tester.scrollUntilVisible(card, 200);
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.byType(ConversationScreen), findsOneWidget);
    expect(
      tester.widget<ConversationScreen>(find.byType(ConversationScreen)).chatId,
      testChatId,
    );
    expect(repository.gets, 1);
    expect(find.text('No messages yet. Say hello!'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(ChatListScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('starting a doctor chat calls the API with the recipient UID', (
    tester,
  ) async {
    final repository = TestChatRepository();
    addTearDown(repository.dispose);
    final router = createAppRouter(
      initialLocation: '/consultation/chat?recipient=doctor',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      chatTestScope(
        Sizer(builder: (_, _, _) => MyApp(router: router)),
        repository: repository,
      ),
    );
    await tester.pumpAndSettle();
    expect(repository.creates, 1);
    expect(repository.recipient, 'doctor');
    expect(find.byType(ConversationScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('chat loading shows shimmer cards until the response arrives', (
    tester,
  ) async {
    final repository = TestChatRepository()
      ..pendingChats = Completer<ChatPage<ConsultationChat>>();
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      chatTestScope(
        Sizer(
          builder: (_, _, _) =>
              MaterialApp(theme: AppTheme.light, home: const ChatListScreen()),
        ),
        repository: repository,
      ),
    );
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byType(ConversationCardShimmer).first,
      150,
    );
    expect(find.byType(ConversationCardShimmer), findsWidgets);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    repository.pendingChats!.complete(ChatPage(items: []));
    await tester.pumpAndSettle();
    expect(find.byType(ConversationCardShimmer), findsNothing);
    expect(find.text('No conversations yet'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('empty inbox contains no demo conversations', (tester) async {
    final repository = TestChatRepository()..chats = [];
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      chatTestScope(
        Sizer(
          builder: (_, _, _) =>
              MaterialApp(theme: AppTheme.light, home: const ChatListScreen()),
        ),
        repository: repository,
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('No conversations yet'), 200);
    expect(find.text('No conversations yet'), findsOneWidget);
    expect(find.text('Dr. Farzana Rahman'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'failed send preserves the composer and retry displays one message',
    (tester) async {
      final repository = TestChatRepository()
        ..sendFailure = const ChatException(
          'Try again',
          mayHaveSucceeded: true,
        );
      addTearDown(repository.dispose);
      await tester.pumpWidget(
        chatTestScope(
          MaterialApp(
            theme: AppTheme.light,
            home: const ConversationScreen(chatId: testChatId),
          ),
          repository: repository,
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();
      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is IconButton && widget.tooltip == 'Send message',
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Hello',
      );
      expect(find.textContaining('Try again'), findsOneWidget);
      repository.sendFailure = null;
      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is IconButton && widget.tooltip == 'Send message',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsOneWidget);
      expect(repository.sentIds, [testMessageId, testMessageId]);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
  for (final size in [const Size(320, 640), const Size(1024, 768)]) {
    for (final isDark in [false, true]) {
      testWidgets('Stored messages and live updates at $size, dark: $isDark', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final repository = TestChatRepository();
        addTearDown(repository.dispose);
        await tester.pumpWidget(
          chatTestScope(
            Sizer(
              builder: (_, _, _) => MaterialApp(
                theme: isDark ? AppTheme.dark : AppTheme.light,
                home: const ConversationScreen(chatId: testChatId),
              ),
            ),
            repository: repository,
          ),
        );
        await tester.pumpAndSettle();
        final send = find.byWidgetPredicate(
          (widget) => widget is IconButton && widget.tooltip == 'Send message',
        );
        expect(tester.widget<IconButton>(send).onPressed, isNull);
        await tester.enterText(
          find.byType(TextField),
          '  Thank you, doctor!  ',
        );
        await tester.pump();
        await tester.tap(send);
        await tester.pumpAndSettle();
        expect(find.text('Thank you, doctor!'), findsOneWidget);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          isEmpty,
        );
        repository.liveMessages.add([
          testMessage(text: 'New reply', minute: 1),
          ...repository.messages,
        ]);
        await tester.pumpAndSettle();
        expect(find.text('New reply'), findsOneWidget);
        expect(tester.takeException(), isNull);
        tester.view.viewInsets = const FakeViewPadding(bottom: 260);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        tester.view.resetViewInsets();
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
