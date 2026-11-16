import 'package:care_match/features/appointments/presentation/widgets/booking_chat_status.dart';
import 'dart:async';
import 'package:care_match/features/appointments/domain/usecases/create_paid_booking_chat.dart';
import 'package:care_match/features/appointments/presentation/controllers/checkout_controller.dart';
import 'package:care_match/features/appointments/presentation/models/appointment_draft.dart';
import 'package:care_match/features/appointments/providers.dart';
import 'package:care_match/features/auth/domain/entities/auth_user.dart';
import 'package:care_match/features/auth/providers.dart';
import 'package:care_match/features/consultation/domain/entities/chat.dart';
import 'package:care_match/features/consultation/domain/repositories/chat_repository.dart';
import 'package:care_match/features/consultation/providers.dart';
import 'package:care_match/features/doctors/presentation/widgets/doctor_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/chat_test_scope.dart';
import 'payment_test.dart' show FakePayments, billing, payment;
import 'appointment_screens_test.dart' show bookingProfile;

void main() {
  for (final status in ['pending', 'failed', 'cancelled', 'review']) {
    test('$status payment never creates a chat', () async {
      final chats = TestChatRepository();
      addTearDown(chats.dispose);
      expect(
        await CreatePaidBookingChat(repository: chats)(
          payment: payment(status: status),
          isChatConsultation: true,
          patientUid: 'patient',
          doctorUid: 'doctor',
        ),
        isNull,
      );
      expect(chats.creates, 0);
    });
  }
  test('paid video bookings never create a chat', () async {
    final chats = TestChatRepository();
    addTearDown(chats.dispose);
    expect(
      await CreatePaidBookingChat(repository: chats)(
        payment: payment(status: 'paid'),
        isChatConsultation: false,
        patientUid: 'patient',
        doctorUid: 'doctor',
      ),
      isNull,
    );
    expect(chats.creates, 0);
  });
  test(
    'paid chat creates or reopens the correct participant conversation',
    () async {
      final chats = TestChatRepository();
      addTearDown(chats.dispose);
      final chat = await CreatePaidBookingChat(repository: chats)(
        payment: payment(status: 'paid'),
        isChatConsultation: true,
        patientUid: 'patient',
        doctorUid: 'doctor',
      );
      expect(chat!.id, testChatId);
      expect(chats.recipient, 'doctor');
    },
  );

  test(
    'checkout prepares a chat once after verified payment and preserves it on refresh',
    () async {
      final chats = _Chats();
      final payments = FakePayments();
      final (container, draft) = await _scope(payments, chats);
      addTearDown(container.dispose);
      addTearDown(chats.dispose);
      final provider = checkoutControllerProvider(draft);
      container.listen(provider, (_, _) {});
      final controller = container.read(provider.notifier);
      await controller.start(billing);
      expect(chats.attempts, 0);
      payments.status = 'paid';
      expect((await controller.refresh())!.isPaid, isTrue);
      expect(container.read(provider).chatId, testChatId);
      await controller.refresh();
      await controller.start(billing);
      expect(chats.attempts, 1);
      expect(payments.bookings, 1);
    },
  );

  test(
    'chat failure preserves successful payment and retries without a new booking or payment',
    () async {
      final chats = _Chats()..fail = true;
      final payments = FakePayments();
      final (container, draft) = await _scope(payments, chats);
      addTearDown(container.dispose);
      addTearDown(chats.dispose);
      final provider = checkoutControllerProvider(draft);
      container.listen(provider, (_, _) {});
      final controller = container.read(provider.notifier);
      await controller.start(billing);
      payments.status = 'paid';
      expect((await controller.refresh())!.isPaid, isTrue);
      expect(container.read(provider).payment!.isPaid, isTrue);
      expect(container.read(provider).errorMessage, isNull);
      expect(container.read(provider).chatErrorMessage, isNotNull);
      chats.fail = false;
      await controller.prepareChat();
      expect(container.read(provider).chatId, testChatId);
      expect(container.read(provider).chatErrorMessage, isNull);
      expect(payments.bookings, 1);
      expect(payments.requests, hasLength(1));
    },
  );

  test(
    'repeated setup calls while creating do not duplicate chat requests',
    () async {
      final chats = _Chats()..pending = Completer<ConsultationChat>();
      final payments = FakePayments();
      final (container, draft) = await _scope(payments, chats);
      addTearDown(container.dispose);
      addTearDown(chats.dispose);
      final provider = checkoutControllerProvider(draft);
      container.listen(provider, (_, _) {});
      final controller = container.read(provider.notifier);
      await controller.start(billing);
      payments.status = 'paid';
      final refresh = controller.refresh();
      await Future<void>.delayed(Duration.zero);
      await controller.prepareChat();
      expect(chats.attempts, 1);
      chats.pending!.complete(testChat());
      await refresh;
      expect(container.read(provider).chatId, testChatId);
    },
  );
  testWidgets('confirmation offers chat-only retry and then Open chat', (
    tester,
  ) async {
    final chats = _Chats()..fail = true;
    final payments = FakePayments();
    final setup = await tester.runAsync(() async {
      final (container, draft) = await _scope(payments, chats);
      final provider = checkoutControllerProvider(draft);
      container.listen(provider, (_, _) {});
      final controller = container.read(provider.notifier);
      await controller.start(billing);
      payments.status = 'paid';
      await controller.refresh();
      return (container, draft);
    });
    final (container, draft) = setup!;
    addTearDown(container.dispose);
    addTearDown(chats.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(body: BookingChatStatus(draft: draft)),
        ),
      ),
    );
    expect(
      find.text('Your payment was successful. Your chat is not ready yet.'),
      findsOneWidget,
    );
    chats.fail = false;
    await tester.tap(find.text('Retry chat setup'));
    await tester.pumpAndSettle();
    expect(find.text('Open chat'), findsOneWidget);
    expect(find.text('Retry chat setup'), findsNothing);
    expect(payments.bookings, 1);
    expect(payments.requests, hasLength(1));
    await tester.pumpWidget(const SizedBox());
  });
}

Future<(ProviderContainer, AppointmentDraft)> _scope(
  FakePayments payments,
  _Chats chats,
) async {
  final container = ProviderContainer(
    overrides: [
      paymentsRepositoryProvider.overrideWithValue(payments),
      chatRepositoryProvider.overrideWithValue(chats),
      paymentKeyGeneratorProvider.overrideWithValue(() => 'key'),
      authSessionProvider.overrideWith(
        (ref) => Stream.value(const AuthUser(uid: 'patient')),
      ),
    ],
  );
  container.listen(authSessionProvider, (_, _) {});
  await container.read(authSessionProvider.future);
  final profile = DoctorProfile(
    summary: bookingProfile.summary,
    biography: '',
    hospital: '',
    careAreas: [],
    id: 'doctor',
  );
  final draft = AppointmentDraft(doctor: profile)
    ..type = ConsultationType.chat
    ..date = DateTime.now().add(const Duration(days: 1))
    ..time = const TimeOfDay(hour: 10, minute: 0);
  return (container, draft);
}

class _Chats extends TestChatRepository {
  bool fail = false;
  int attempts = 0;
  Completer<ConsultationChat>? pending;
  @override
  Future<ConsultationChat> createChat(String recipientUid) async {
    attempts++;
    if (fail) throw const ChatException('Chat service unavailable');
    if (pending != null) return pending!.future;
    return super.createChat(recipientUid);
  }
}
