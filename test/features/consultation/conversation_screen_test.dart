import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/consultation/presentation/screens/conversation_screen.dart';
import 'package:care_match/features/consultation/presentation/widgets/conversation.dart';
import 'package:care_match/features/consultation/presentation/widgets/conversation_card.dart';
import 'package:care_match/main.dart';
import 'package:care_match/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Conversation cards open the selected doctor and support back', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: '/consultation/chat');
    addTearDown(router.dispose);
    await tester.pumpWidget(Sizer(builder: (_, _, _) => MyApp(router: router)));
    await tester.pumpAndSettle();
    final doctor = find.text('Dr. Anika Sarker');
    await tester.scrollUntilVisible(doctor, 200);
    await tester.tap(doctor);
    await tester.pumpAndSettle();
    expect(find.byType(ConversationScreen), findsOneWidget);
    expect(find.text('Dr. Anika Sarker'), findsOneWidget);
    expect(find.text('Currently offline'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(ConversationCard), findsWidgets);
  });

  for (final size in [const Size(320, 640), const Size(1024, 768)]) {
    for (final isDark in [false, true]) {
      testWidgets('Local sending and layout at $size, dark: $isDark', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          Sizer(
            builder: (_, _, _) => MaterialApp(
              theme: isDark ? AppTheme.dark : AppTheme.light,
              home: ConversationScreen(conversation: sampleConversations.first),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final send = find.byWidgetPredicate(
          (widget) => widget is IconButton && widget.tooltip == 'Send message',
        );
        expect(tester.widget<IconButton>(send).onPressed, isNull);
        await tester.enterText(find.byType(TextField), '   ');
        await tester.pump();
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
        expect(tester.widget<IconButton>(send).onPressed, isNull);
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
