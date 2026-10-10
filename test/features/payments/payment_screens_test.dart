import 'dart:async';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:care_match/core/theme/theme.dart';
import 'package:care_match/features/home/presentation/home_screen.dart';
import 'package:care_match/features/payments/presentation/controllers/payment_checkout_controller.dart';
import 'package:care_match/features/payments/presentation/models/payment_checkout_session.dart';
import 'package:care_match/features/payments/presentation/screens/payment_webview_screen.dart';
import 'package:care_match/features/appointments/presentation/models/appointment_draft.dart';
import 'package:care_match/features/appointments/presentation/screens/appointment_confirmation_screen.dart';
import 'package:care_match/features/doctors/presentation/widgets/doctor_profile.dart';
import 'package:care_match/features/payments/presentation/screens/payment_failed_screen.dart';
import 'package:care_match/main.dart';
import 'package:care_match/router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

final receipt = PaymentReceipt(
  reference: 'CM-2026-VERIFIED-1234567890',
  provider: 'bKash',
  amount: '৳1,200',
  paidAt: DateTime(2026, 10, 10),
);

AppointmentDraft appointmentDraft() =>
    AppointmentDraft(doctor: sampleDoctorProfile)
      ..date = DateTime.now().add(const Duration(days: 1))
      ..time = const TimeOfDay(hour: 10, minute: 0);

PaymentCheckoutSession session({
  Future<PaymentVerification> Function()? verify,
  Future<PaymentCheckoutSession> Function()? retry,
}) => PaymentCheckoutSession(
  appointmentDraft: appointmentDraft(),
  provider: 'bKash',
  amount: '৳1,200',
  checkoutUrl: Uri.parse('https://checkout.example.com/session/123'),
  successReturnUrl: Uri.parse(
    'https://carematch.example.com/payment/success?order=123',
  ),
  failureReturnUrl: Uri.parse(
    'https://carematch.example.com/payment/failed?order=123',
  ),
  verifyPayment: verify ?? () async => const PaymentVerification.pending(),
  createRetrySession: retry,
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('Checkout return URLs match the expected host, path, and order', () {
    final checkout = session();
    expect(
      checkout.isReturnUrl(
        Uri.parse(
          'https://carematch.example.com/payment/success?order=123&status=success',
        ),
      ),
      isTrue,
    );
    expect(
      checkout.isReturnUrl(
        Uri.parse('https://carematch.example.com/payment/success?order=456'),
      ),
      isFalse,
    );
    expect(
      checkout.isReturnUrl(
        Uri.parse(
          'https://carematch.example.com.evil.test/payment/success?order=123',
        ),
      ),
      isFalse,
    );
    expect(
      checkout.isReturnUrl(
        Uri.parse(
          'https://carematch.example.com/payment/success-extra?order=123',
        ),
      ),
      isFalse,
    );
    expect(checkout.isReturnUrl(checkout.failureReturnUrl), isTrue);
    expect(checkout.allowsNavigation(checkout.checkoutUrl), isTrue);
    expect(
      checkout.allowsNavigation(Uri.parse('http://checkout.example.com')),
      isFalse,
    );
    expect(
      checkout.allowsNavigation(Uri.parse('https://other.example.com')),
      isFalse,
    );
    expect(
      () => PaymentCheckoutSession(
        appointmentDraft: appointmentDraft(),
        provider: 'Provider',
        amount: r'$10',
        checkoutUrl: Uri.parse('http://checkout.example.com'),
        successReturnUrl: checkout.successReturnUrl,
        failureReturnUrl: checkout.failureReturnUrl,
        verifyPayment: checkout.verifyPayment,
      ),
      throwsArgumentError,
    );
  });

  test(
    'Pending payments remain pending until the backend confirms a receipt',
    () async {
      var calls = 0;
      final pending = Completer<PaymentVerification>();
      final controller = PaymentCheckoutController(
        session(
          verify: () {
            calls++;
            return calls == 1
                ? pending.future
                : Future.value(PaymentVerification.succeeded(receipt));
          },
        ),
      );
      addTearDown(controller.dispose);
      final verification = controller.verify();
      await controller.verify();
      expect(calls, 1);
      pending.complete(const PaymentVerification.pending());
      await verification;
      expect(controller.verification!.status, PaymentStatus.pending);
      await controller.verify();
      expect(controller.verification!.receipt, receipt);
      await controller.verify();
      expect(calls, 2);
    },
  );

  test(
    'Verification errors stay unresolved and do not report success or failure',
    () async {
      final controller = PaymentCheckoutController(
        session(verify: () async => throw StateError('Network unavailable')),
      );
      addTearDown(controller.dispose);
      await controller.verify();
      expect(controller.verification!.status, PaymentStatus.pending);
      expect(controller.verification!.receipt, isNull);
    },
  );

  test(
    'Backend failures remain failures; disposed verification does not notify',
    () async {
      final controller = PaymentCheckoutController(
        session(
          verify: () async =>
              const PaymentVerification.failed('Payment declined'),
        ),
      );
      await controller.verify();
      expect(controller.verification!.status, PaymentStatus.failed);
      controller.dispose();
      final future = Completer<PaymentVerification>();
      final disposed = PaymentCheckoutController(
        session(verify: () => future.future),
      );
      final verification = disposed.verify();
      disposed.dispose();
      future.complete(PaymentVerification.succeeded(receipt));
      await verification;
      expect(disposed.verification, isNull);
    },
  );

  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('Payment screens fit $size with enlarged text in both themes', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        for (final screen in [
          const PaymentWebViewScreen(),
          PaymentFailedScreen(
            failure: PaymentFailure(
              session: session(retry: () async => session()),
            ),
          ),
        ]) {
          await tester.pumpWidget(
            Sizer(
              builder: (_, _, _) => MaterialApp(
                theme: theme,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(1.5)),
                  child: child!,
                ),
                home: screen,
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -600),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        }
      }
    });
  }

  testWidgets(
    'Checkout and failure support returning home; confirmation retains the draft',
    (tester) async {
      final router = createAppRouter(initialLocation: '/payments/checkout');
      addTearDown(router.dispose);
      await tester.pumpWidget(
        Sizer(builder: (_, _, _) => MyApp(router: router)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PaymentWebViewScreen), findsOneWidget);
      router.goNamed(AppRoutes.paymentFailed);
      await tester.pumpAndSettle();
      expect(find.text('Payment not completed'), findsOneWidget);
      await tester.ensureVisible(find.text('Back to Home'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Back to Home'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      final draft = appointmentDraft();
      router.pushReplacementNamed(
        AppRoutes.appointmentConfirmation,
        pathParameters: {
          'doctorId': doctorProfileId(draft.doctor.summary.name),
        },
        extra: draft,
      );
      await tester.pumpAndSettle();
      expect(find.text('Your appointment is booked!'), findsOneWidget);
      expect(
        tester
            .widget<AppointmentConfirmationScreen>(
              find.byType(AppointmentConfirmationScreen),
            )
            .draft,
        same(draft),
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('Retry obtains a fresh checkout session', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final router = createAppRouter(initialLocation: '/payments/failed');
    addTearDown(router.dispose);
    var retries = 0;
    final fresh = session();
    final failed = session(
      retry: () async {
        retries++;
        return fresh;
      },
    );
    await tester.pumpWidget(Sizer(builder: (_, _, _) => MyApp(router: router)));
    await tester.pumpAndSettle();
    router.goNamed(
      AppRoutes.paymentFailed,
      extra: PaymentFailure(session: failed),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Try again'));
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(retries, 1);
    expect(
      tester
          .widget<PaymentWebViewScreen>(find.byType(PaymentWebViewScreen))
          .session,
      same(fresh),
    );
    expect(find.text('Use a supported device'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    debugDefaultTargetPlatformOverride = null;
  });
}
