import '../../domain/entities/payment_checkout.dart';

class CheckoutState {
  const CheckoutState({
    this.isLoading = false,
    this.hasStarted = false,
    this.payment,
    this.errorMessage,
    this.chatId,
    this.chatErrorMessage,
    this.isCreatingChat = false,
  });
  final bool isLoading, hasStarted;
  final PaymentCheckout? payment;
  final String? errorMessage;
  final String? chatId, chatErrorMessage;
  final bool isCreatingChat;
}
