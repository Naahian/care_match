import '../../../consultation/domain/repositories/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers.dart';
import '../../domain/entities/payment_checkout.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/payments_repository.dart';
import '../../domain/usecases/start_appointment_payment.dart';
import '../../providers.dart';
import '../models/appointment_draft.dart';
import 'checkout_state.dart';

final checkoutControllerProvider = NotifierProvider.autoDispose
    .family<CheckoutController, CheckoutState, AppointmentDraft>(
      CheckoutController.new,
    );

class CheckoutController extends Notifier<CheckoutState> {
  CheckoutController(this.draft);
  final AppointmentDraft draft;
  StartAppointmentPayment? _start;
  String? _payerUid;
  bool? _isChatBooking;

  @override
  CheckoutState build() {
    ref.listen(authSessionProvider, (_, next) {
      if (_payerUid == null || next.isLoading) return;
      if (next.hasError || next.asData?.value?.uid != _payerUid) {
        state = const CheckoutState(
          hasStarted: true,
          errorMessage: 'Sign in again to continue payment.',
        );
      }
    });
    return const CheckoutState();
  }

  bool get _sameUser =>
      _payerUid != null &&
      ref.read(authSessionProvider).asData?.value?.uid == _payerUid;

  Future<PaymentCheckout?> start(BillingDetails billing) async {
    if (state.isLoading || state.isCreatingChat) return null;
    final user = ref.read(authSessionProvider).asData?.value;
    if (user == null || (_payerUid != null && !_sameUser)) {
      state = CheckoutState(
        hasStarted: state.hasStarted,
        errorMessage: 'Sign in again to continue payment.',
      );
      return null;
    }
    final total = draft.total;
    final scheduled = draft.scheduledAt;
    final doctorId = draft.doctor.id;
    if (total == null ||
        total <= 0 ||
        !total.isFinite ||
        scheduled == null ||
        doctorId == null) {
      state = const CheckoutState(
        errorMessage: 'Choose a valid doctor, appointment time, and price.',
      );
      return null;
    }
    _payerUid = user.uid;
    _isChatBooking ??= draft.type == ConsultationType.chat;
    state = CheckoutState(
      isLoading: true,
      hasStarted: true,
      payment: state.payment,
      chatId: state.chatId,
      chatErrorMessage: state.chatErrorMessage,
    );
    try {
      _start ??= StartAppointmentPayment(
        repository: ref.read(paymentsRepositoryProvider),
        newKey: ref.read(paymentKeyGeneratorProvider),
      );
      final payment =
          state.payment ??
          await _start!(
            BookingDetails(
              doctorId: doctorId,
              patientId: user.uid,
              scheduledFor: scheduled,
              reason: draft.reason,
              notes: draft.notes,
              amountCents: (total * 100).round(),
              type: switch (draft.type) {
                ConsultationType.video => AppointmentType.video,
                ConsultationType.chat => AppointmentType.chat,
                ConsultationType.inPerson => AppointmentType.inPerson,
              },
            ),
            billing,
          );
      if (!ref.mounted) return null;
      if (!_sameUser) {
        state = const CheckoutState(
          hasStarted: true,
          errorMessage: 'Sign in again to continue payment.',
        );
        return null;
      }
      state = CheckoutState(
        hasStarted: true,
        payment: payment,
        chatId: state.chatId,
        chatErrorMessage: state.chatErrorMessage,
      );
      await prepareChat();
      if (!ref.mounted || !_sameUser) return null;
      return payment;
    } catch (error) {
      if (ref.mounted) {
        state = CheckoutState(
          hasStarted: true,
          payment: state.payment,
          chatId: state.chatId,
          chatErrorMessage: state.chatErrorMessage,
          errorMessage: error is PaymentException
              ? error.message
              : 'Could not start payment. Please try again.',
        );
      }
      return null;
    }
  }

  Future<PaymentCheckout?> refresh() async {
    final previous = state.payment;
    if (previous == null ||
        state.isLoading ||
        state.isCreatingChat ||
        !_sameUser) {
      return null;
    }
    state = CheckoutState(
      isLoading: true,
      hasStarted: true,
      payment: previous,
      chatId: state.chatId,
      chatErrorMessage: state.chatErrorMessage,
    );
    try {
      final payment = await ref
          .read(paymentsRepositoryProvider)
          .getPayment(previous.id);
      if (!ref.mounted) return null;
      if (!_sameUser) {
        state = const CheckoutState(
          hasStarted: true,
          errorMessage: 'Sign in again to continue payment.',
        );
        return null;
      }
      if (payment.appointmentId != previous.appointmentId ||
          payment.amountCents != previous.amountCents ||
          payment.currency != previous.currency) {
        throw const PaymentException('Could not verify this payment.');
      }
      state = CheckoutState(
        hasStarted: true,
        payment: payment,
        chatId: state.chatId,
        chatErrorMessage: state.chatErrorMessage,
      );
      await prepareChat();
      if (!ref.mounted || !_sameUser) return null;
      return payment;
    } catch (error) {
      if (ref.mounted) {
        state = CheckoutState(
          hasStarted: true,
          payment: previous,
          chatId: state.chatId,
          chatErrorMessage: state.chatErrorMessage,
          errorMessage: error is PaymentException
              ? error.message
              : 'Could not check payment. Please try again.',
        );
      }
      return null;
    }
  }

  Future<void> prepareChat() async {
    final payment = state.payment;
    if (payment == null ||
        !payment.isPaid ||
        _isChatBooking != true ||
        state.chatId != null ||
        state.isCreatingChat ||
        !_sameUser) {
      return;
    }
    final patientUid = _payerUid!;
    final doctorUid = draft.doctor.id;
    state = CheckoutState(
      hasStarted: true,
      payment: payment,
      isCreatingChat: true,
    );
    try {
      if (doctorUid == null) {
        throw const ChatException('The booking doctor is unavailable.');
      }
      final chat = await ref.read(createPaidBookingChatProvider)(
        payment: payment,
        isChatConsultation: true,
        patientUid: patientUid,
        doctorUid: doctorUid,
      );
      if (!ref.mounted || !_sameUser) return;
      state = CheckoutState(
        hasStarted: true,
        payment: payment,
        chatId: chat?.id,
      );
    } catch (error) {
      if (!ref.mounted || !_sameUser) return;
      state = CheckoutState(
        hasStarted: true,
        payment: payment,
        chatErrorMessage: error is ChatException
            ? error.message
            : 'Could not prepare your chat. Please retry.',
      );
    }
  }
}
