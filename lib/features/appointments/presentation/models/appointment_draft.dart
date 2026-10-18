import 'package:flutter/material.dart';
import 'package:care_match/features/doctors/presentation/widgets/doctor_profile.dart';

enum ConsultationType {
  video(
    'Video Consult',
    Icons.videocam_outlined,
    'Talk face-to-face, from home.',
  ),
  chat(
    'Chat Consult',
    Icons.chat_bubble_outline_rounded,
    'Get a response within hours.',
  ),
  inPerson(
    'In person',
    Icons.local_hospital_outlined,
    'Visit the doctor at the clinic.',
  );

  const ConsultationType(this.label, this.icon, this.description);
  final String label;
  final IconData icon;
  final String description;
}

enum AppointmentPaymentMethod {
  sslcommerz('SSLCommerz'),
  bkash('bKash');

  const AppointmentPaymentMethod(this.label);
  final String label;
}

/// Local UI draft shared by the booking steps. Prices are expressed in BDT.
class AppointmentDraft {
  AppointmentDraft({required this.doctor});
  final DoctorProfile doctor;
  ConsultationType type = ConsultationType.video;
  String reason = '';
  String notes = '';
  DateTime? date;
  TimeOfDay? time;
  AppointmentPaymentMethod paymentMethod = AppointmentPaymentMethod.sslcommerz;

  String _rawPriceFor(ConsultationType type) => switch (type) {
    ConsultationType.video => doctor.videoPrice,
    ConsultationType.chat => doctor.chatPrice,
    ConsultationType.inPerson => doctor.inPersonPrice,
  };
  String priceFor(ConsultationType type) {
    final fee = double.tryParse(_rawPriceFor(type).replaceAll('৳', '').trim());
    return fee == null ? 'Not provided' : appointmentMoney(fee);
  }

  double? get consultationFee =>
      double.tryParse(_rawPriceFor(type).replaceAll('৳', '').trim());
  double get serviceFee => 4;
  double? get total =>
      consultationFee == null ? null : consultationFee! + serviceFee;
  DateTime? get scheduledAt => date == null || time == null
      ? null
      : DateTime(date!.year, date!.month, date!.day, time!.hour, time!.minute);
}

String appointmentMoney(double value) =>
    '৳${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 2)}';
