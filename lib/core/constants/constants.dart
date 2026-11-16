import 'package:flutter/material.dart';

// ------------- API ENDPOINTS -------------

abstract final class ApiEndpoints {
  static const String baseUrl =
      'https://care-match-backend.onrender.com/api/v1';
  static final String createDoctor = "/users/doctor";
  static final String createPatient = "/users/patient";
  static final String resetPassword = "/users/reset-password";
  static final String doctors = "/users/doctors";
  static final String profile = "/users/me";
  static const String medicalReports = "/users/me/medical-reports";
  static const String prescriptions = "/users/me/prescriptions";
  static final String payments = "/payments";
  static String paymentStatus(String id) => "/payments/$id";
  static final String triage = "/triage";

  static final String video = "/video/token";
  static final String chats = "/chats"; // create, list chats
  static String getChat(String id) => "/chats/$id";
  static String messages(String id) =>
      "/chats/$id/messages"; // list, send message

  static final String appointments = "/appointments";
  static String appointmentStatus(String id) => "/appointments/$id/status";
}

// ------------- APP CONSTANTS -------------

abstract final class AppConstants {
  static const String appName = 'Care Match';
  static const String agoraAppId = '1e93c2cab003458a8a8dee0717443573';
  static const int defaultConsultationFee = 100;
  static const String defaultConsultationPrice = '৳$defaultConsultationFee';

  static const int defaultPageSize = 20;
  static const int otpLength = 6;

  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Duration debounceDelay = Duration(milliseconds: 300);
  static const Duration requestTimeout = Duration(seconds: 30);
}

// ------------- APP RADIUS -------------

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;

  static const BorderRadius button = BorderRadius.all(Radius.circular(md));
  static const BorderRadius input = BorderRadius.all(Radius.circular(md));
  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius chip = BorderRadius.all(Radius.circular(full));
  static const BorderRadius sheet = BorderRadius.all(Radius.circular(xl));
}

// ------------- APP SPACING -------------

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsets page = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );
  static const EdgeInsets card = EdgeInsets.all(md);
  static const EdgeInsets gutter = EdgeInsets.symmetric(horizontal: md);
}
