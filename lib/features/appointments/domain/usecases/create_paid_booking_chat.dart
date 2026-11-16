import '../../../consultation/domain/entities/chat.dart';
import '../../../consultation/domain/repositories/chat_repository.dart';
import '../entities/payment_checkout.dart';

/// Opens the patient/doctor conversation only for a paid chat booking.
/// Chat failure never reverses a successful payment; callers may retry safely
/// because the backend reuses the conversation for the same participant pair.
class CreatePaidBookingChat {
  const CreatePaidBookingChat({required this.repository});
  final ChatRepository repository;

  Future<ConsultationChat?> call({
    required PaymentCheckout payment,
    required bool isChatConsultation,
    required String patientUid,
    required String doctorUid,
  }) async {
    if (!isChatConsultation || !payment.isPaid) return null;
    if (patientUid.isEmpty || doctorUid.isEmpty || patientUid == doctorUid) {
      throw const ChatException('Could not identify the booking participants.');
    }
    final chat = await repository.createChat(doctorUid);
    if (!chat.participantUids.contains(patientUid) ||
        !chat.participantUids.contains(doctorUid) ||
        chat.participantUids.length != 2) {
      throw const ChatException('Could not verify the booking conversation.');
    }
    return chat;
  }
}
