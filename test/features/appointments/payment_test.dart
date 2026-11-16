import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:care_match/core/network/dio_client.dart';
import 'package:care_match/features/appointments/data/repositories/payments_repository_impl.dart';
import 'package:care_match/features/appointments/domain/entities/payment_checkout.dart';
import 'package:care_match/features/appointments/domain/entities/appointment.dart';
import 'package:care_match/features/appointments/domain/repositories/payments_repository.dart';
import 'package:care_match/features/appointments/domain/usecases/start_appointment_payment.dart';
import 'package:care_match/features/appointments/presentation/controllers/checkout_controller.dart';
import 'package:care_match/features/appointments/providers.dart';
import 'package:care_match/features/auth/providers.dart';
import 'package:care_match/features/auth/domain/entities/auth_user.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_match/features/doctors/presentation/widgets/doctor_profile.dart';
import 'package:care_match/features/appointments/presentation/models/appointment_draft.dart';
import 'package:flutter/material.dart';
import 'appointment_screens_test.dart' show bookingProfile;

const billing = BillingDetails(
  name: 'Test Patient',
  email: 'patient@example.com',
  phone: '01711111111',
  address: 'Test address',
  city: 'Dhaka',
  postcode: '1200',
);
final booking = BookingDetails(
  doctorId: 'doctor',
  patientId: 'patient',
  scheduledFor: DateTime.now().add(const Duration(days: 1)),
  reason: 'Follow-up',
  notes: '',
  amountCents: 10400,
);
PaymentCheckout payment({String status = 'pending'}) => PaymentCheckout(
  id: 'payment',
  appointmentId: 'appointment',
  amountCents: 10400,
  currency: 'BDT',
  status: status,
  checkoutUrl: Uri.parse('https://sandbox.sslcommerz.com/checkout'),
);

void main() {
  for (final type in AppointmentType.values) {
    test('booking sends ${type.value} to the appointment API', () async {
      final adapter = Adapter()
        ..overrides = {'doctor_id': 'doctor', 'patient_id': 'patient'};
      final dio = createDioClient(
        baseUrl: 'https://example.com/api/v1',
        readAccessToken: () async => 'token',
        adapter: adapter,
      );
      addTearDown(dio.close);
      await PaymentsRepositoryImpl(dio: dio).createAppointment(
        BookingDetails(
          doctorId: booking.doctorId,
          patientId: booking.patientId,
          scheduledFor: booking.scheduledFor,
          reason: booking.reason,
          notes: booking.notes,
          amountCents: booking.amountCents,
          type: type,
        ),
      );
      expect(adapter.request!.uri.path, '/api/v1/appointments');
      expect(adapter.request!.data['appointment_type'], type.value);
    });
  }
  test(
    'real repository sends exact authenticated payload and validates response',
    () async {
      final adapter = Adapter();
      final dio = createDioClient(
        baseUrl: 'https://example.com/api/v1',
        readAccessToken: () async => 'token',
        adapter: adapter,
      );
      addTearDown(dio.close);
      final repo = PaymentsRepositoryImpl(dio: dio);
      final result = await repo.createPayment(
        const PaymentRequest(
          appointmentId: 'appointment',
          amountCents: 10400,
          idempotencyKey: 'stable-key',
          billing: billing,
        ),
      );
      expect(adapter.request!.uri.path, '/api/v1/payments');
      expect(adapter.request!.headers['Authorization'], 'Bearer token');
      expect(adapter.request!.data, {
        'appointment_id': 'appointment',
        'amount_cents': 10400,
        'currency': 'BDT',
        'idempotency_key': 'stable-key',
        'customer_name': 'Test Patient',
        'customer_email': 'patient@example.com',
        'customer_phone': '01711111111',
        'customer_address': 'Test address',
        'customer_city': 'Dhaka',
        'customer_postcode': '1200',
        'customer_country': 'Bangladesh',
      });
      expect(result.checkoutUrl!.scheme, 'https');
      expect(result.isPaid, isFalse);
      await repo.getPayment('payment');
      expect(adapter.request!.uri.path, '/api/v1/payments/payment');
      expect(adapter.request!.method, 'GET');
    },
  );

  for (final overrides in [
    {'checkout_url': 'javascript:alert(1)'},
    {'amount_cents': 1},
    {'currency': 'USD'},
    {'appointment_id': 'wrong'},
  ]) {
    test('rejects malformed or mismatched payment $overrides', () async {
      final adapter = Adapter()..overrides = overrides;
      final dio = createDioClient(
        baseUrl: 'https://example.com/api/v1',
        readAccessToken: () async => 'token',
        adapter: adapter,
      );
      addTearDown(dio.close);
      await expectLater(
        PaymentsRepositoryImpl(dio: dio).createPayment(
          const PaymentRequest(
            appointmentId: 'appointment',
            amountCents: 10400,
            idempotencyKey: 'key',
            billing: billing,
          ),
        ),
        throwsA(isA<PaymentException>()),
      );
    });
  }

  test(
    'payment retry reuses appointment and complete frozen request',
    () async {
      final repo = FakePayments()..failPayment = true;
      final start = StartAppointmentPayment(
        repository: repo,
        newKey: () => 'stable-key',
      );
      await expectLater(
        start(booking, billing),
        throwsA(isA<PaymentException>()),
      );
      final first = repo.requests.single;
      repo.failPayment = false;
      await start(booking, billing);
      expect(repo.bookings, 1);
      expect(repo.requests.last, same(first));
    },
  );

  test('uncertain appointment creation is not retried', () async {
    final repo = FakePayments()..uncertain = true;
    final start = StartAppointmentPayment(
      repository: repo,
      newKey: () => 'stable-key',
    );
    await expectLater(
      start(booking, billing),
      throwsA(isA<PaymentException>()),
    );
    await expectLater(
      start(booking, billing),
      throwsA(isA<PaymentException>()),
    );
    expect(repo.bookings, 1);
    expect(repo.requests, isEmpty);
  });

  test(
    'controller converts BDT to hundredths and confirms only backend paid',
    () async {
      final repo = FakePayments();
      final container = ProviderContainer.test(
        overrides: [
          paymentsRepositoryProvider.overrideWithValue(repo),
          paymentKeyGeneratorProvider.overrideWithValue(() => 'stable-key'),
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
        careAreas: const [],
        id: 'doctor',
      );
      final draft = AppointmentDraft(doctor: profile)
        ..date = DateTime.now().add(const Duration(days: 1))
        ..time = const TimeOfDay(hour: 10, minute: 0);
      final provider = checkoutControllerProvider(draft);
      container.listen(provider, (_, _) {});
      final controller = container.read(provider.notifier);
      expect((await controller.start(billing))!.isPaid, isFalse);
      expect(repo.requests.single.amountCents, 10400);
      repo.status = 'review';
      expect((await controller.refresh())!.isPaid, isFalse);
      repo.status = 'paid';
      expect((await controller.refresh())!.isPaid, isTrue);
    },
  );
}

class FakePayments implements PaymentsRepository {
  int bookings = 0;
  bool failPayment = false, uncertain = false;
  String status = 'pending';
  final requests = <PaymentRequest>[];
  @override
  Future<String> createAppointment(BookingDetails details) async {
    bookings++;
    if (uncertain) {
      throw const PaymentException('Uncertain', uncertainBooking: true);
    }
    return 'appointment';
  }

  @override
  Future<PaymentCheckout> createPayment(PaymentRequest request) async {
    requests.add(request);
    if (failPayment) throw const PaymentException('Unavailable');
    return payment();
  }

  @override
  Future<PaymentCheckout> getPayment(String id) async =>
      payment(status: status);
}

class Adapter implements HttpClientAdapter {
  RequestOptions? request;
  Map<String, Object> overrides = {};
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode({
        'status': 200,
        'msg': 'Success',
        'data': {
          'payment_id': 'payment',
          'appointment_id': 'appointment',
          'amount_cents': 10400,
          'currency': 'BDT',
          'status': 'pending',
          'checkout_url': 'https://sandbox.sslcommerz.com/checkout',
          ...overrides,
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
