import 'features/doctors/presentation/screens/doctor_profile_loader.dart';
import 'features/nursai/domain/entities/triage_assessment.dart';
import 'features/nursai/presentation/screens/symptom_entry_screen.dart';
import 'features/nursai/presentation/screens/symptom_assessment_screen.dart';
import 'features/nursai/presentation/models/symptom_intake.dart';
import 'features/doctors/presentation/screens/recommended_doctors_screen.dart';
import 'features/appointments/presentation/models/appointment_draft.dart';
import 'features/appointments/presentation/screens/book_appointment_screen.dart';
import 'features/appointments/presentation/screens/appointment_date_time_screen.dart';
import 'features/appointments/presentation/screens/appointment_payment_screen.dart';
import 'features/appointments/presentation/screens/appointment_confirmation_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_routes.dart';
import 'features/auth/providers.dart';
import 'features/auth/presentation/screens/create_account_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/profile/presentation/screens/set_up_profile_screen.dart';
import 'features/auth/presentation/screens/verify_number_screen.dart';
import 'features/consultation/presentation/screens/chat_list_screen.dart';
import 'features/consultation/presentation/screens/conversation_screen.dart';
import 'features/consultation/presentation/widgets/conversation.dart';
import 'features/consultation/presentation/screens/video_onboarding_screen.dart';
import 'features/doctors/presentation/screens/doctor_detail_screen.dart';
import 'features/doctors/presentation/screens/doctor_search_screen.dart';
import 'features/doctors/presentation/widgets/doctor_profile.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/welcome/presentation/onboarding.dart';
import 'features/profile/presentation/screens/my_profile_screen.dart';
import 'features/settings/presentation/screens/preferences_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/records/presentation/screens/my_reports_screen.dart';
import 'features/appointments/presentation/screens/my_appointments_screen.dart';
import 'features/doctor_portal/presentation/screens/doctor_dashboard_screen.dart';
import 'features/doctor_portal/presentation/screens/patient_queue_screen.dart';
import 'features/doctor_portal/presentation/screens/doctor_schedule_screen.dart';
import 'features/doctor_portal/presentation/screens/doctor_portal_profile_screen.dart';

final appRouterProvider = Provider.family<GoRouter, bool>((ref, isFirstOpen) {
  bool signedIn() {
    final user = ref.read(authControllerProvider).user;
    return user != null && user.emailVerified && !user.isAnonymous;
  }

  final session = ValueNotifier(signedIn());
  ref.listen(authControllerProvider, (_, _) {
    session.value = signedIn();
  });
  final router = createAppRouter(
    isFirstOpen: isFirstOpen,
    isSignedIn: () => session.value,
    refreshListenable: session,
  );
  ref.onDispose(() {
    router.dispose();
    session.dispose();
  });
  return router;
});

GoRouter createAppRouter({
  String? initialLocation,
  bool isFirstOpen = true,
  bool Function()? isSignedIn,
  Listenable? refreshListenable,
}) => GoRouter(
  initialLocation:
      initialLocation ?? (isFirstOpen ? '/welcome' : '/auth/login'),
  refreshListenable: refreshListenable,
  redirect: (_, state) {
    final entryRoute = const {
      '/',
      '/welcome',
      '/auth/login',
      '/auth/create-account',
      '/auth/forgot-password',
    }.contains(state.uri.path);
    return entryRoute && (isSignedIn?.call() ?? false) ? '/home' : null;
  },
  routes: [
    GoRoute(
      path: '/consultation/chat/conversation',
      name: AppRoutes.conversation,
      builder: (_, state) {
        final doctor = state.uri.queryParameters['doctor'];
        final matches = sampleConversations.where(
          (conversation) => conversation.doctorName == doctor,
        );
        if (doctor != null && matches.isEmpty) {
          return const _RouteNotFound(message: 'Conversation not found');
        }
        return ConversationScreen(
          conversation: matches.isEmpty
              ? sampleConversations.first
              : matches.first,
        );
      },
    ),
    GoRoute(
      path: '/doctor-portal',
      name: AppRoutes.doctorDashboard,
      builder: (_, _) => const DoctorDashboardScreen(),
    ),
    GoRoute(
      path: '/doctor-portal/queue',
      name: AppRoutes.doctorQueue,
      builder: (_, _) => const PatientQueueScreen(),
    ),
    GoRoute(
      path: '/doctor-portal/schedule',
      name: AppRoutes.doctorSchedule,
      builder: (_, _) => const DoctorScheduleScreen(),
    ),
    GoRoute(
      path: '/doctor-portal/profile',
      name: AppRoutes.doctorProfile,
      builder: (_, _) => const DoctorPortalProfileScreen(),
    ),
    GoRoute(
      path: '/notifications',
      name: AppRoutes.notifications,
      builder: (_, _) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: AppRoutes.preferences,
      builder: (_, _) => const PreferencesScreen(),
    ),
    GoRoute(
      path: '/symptoms',
      name: AppRoutes.symptomEntry,
      builder: (_, state) => SymptomEntryScreen(
        initialSymptoms: state.uri.queryParameters['symptoms'] ?? '',
      ),
    ),
    GoRoute(
      path: '/symptoms/assessment',
      name: AppRoutes.symptomAssessment,
      redirect: (_, state) => state.extra is SymptomIntake ? null : '/symptoms',
      builder: (_, state) =>
          SymptomAssessmentScreen(intake: state.extra! as SymptomIntake),
    ),
    GoRoute(
      path: '/profile',
      name: AppRoutes.profile,
      builder: (_, _) => const MyProfileScreen(),
    ),
    GoRoute(
      path: '/reports',
      name: AppRoutes.reports,
      builder: (_, _) => const MyReportsScreen(),
    ),
    GoRoute(
      path: '/appointments',
      name: AppRoutes.appointments,
      builder: (_, state) =>
          MyAppointmentsScreen(refreshOnOpen: state.extra is AppointmentDraft),
    ),
    GoRoute(path: '/', redirect: (_, _) => '/doctors'),
    GoRoute(
      path: '/welcome',
      name: AppRoutes.welcome,
      builder: (context, _) => OnboardingScreen(
        onGetStarted: () => context.pushNamed(AppRoutes.createAccount),
        onLogin: () => context.pushNamed(AppRoutes.login),
      ),
    ),
    GoRoute(
      path: '/auth/login',
      name: AppRoutes.login,
      builder: (_, _) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/forgot-password',
      name: AppRoutes.forgotPassword,
      builder: (_, _) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/auth/create-account',
      name: AppRoutes.createAccount,
      builder: (_, _) => const CreateAccountScreen(),
    ),
    GoRoute(
      path: '/auth/verify-number',
      name: AppRoutes.verifyNumber,
      builder: (_, state) => VerifyNumberScreen(
        phoneNumber: state.uri.queryParameters['phone'] ?? '+1 987 654 3210',
      ),
    ),
    GoRoute(
      path: '/auth/profile',
      name: AppRoutes.setUpProfile,
      builder: (_, state) => SetUpProfileScreen(
        isEditProfile: state.extra is bool ? state.extra! as bool : false,
      ),
    ),
    GoRoute(
      path: '/home',
      name: AppRoutes.home,
      builder: (_, _) => const HomeScreen(),
    ),
    GoRoute(
      path: '/doctors',
      name: AppRoutes.doctors,
      builder: (_, state) => FindDoctorScreen(
        initialQuery: state.uri.queryParameters['query'] ?? '',
      ),
      routes: [
        GoRoute(
          path: 'recommended',
          name: AppRoutes.recommendedDoctors,
          builder: (_, state) => RecommendedDoctorsScreen(
            assessment: state.extra is TriageAssessment
                ? state.extra! as TriageAssessment
                : null,
            intake: state.extra is SymptomIntake
                ? state.extra! as SymptomIntake
                : null,
          ),
        ),
        GoRoute(
          path: ':doctorId',
          name: AppRoutes.doctorDetail,
          builder: (context, state) {
            final id = state.pathParameters['doctorId']!;
            final extra = state.extra;
            final profile = extra is DoctorProfile && extra.routeId == id
                ? extra
                : null;
            return profile == null
                ? DoctorProfileLoader(
                    doctorId: state.pathParameters['doctorId']!,
                    builder: (profile) => DoctorDetailScreen(profile: profile),
                  )
                : DoctorDetailScreen(profile: profile);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/appointments/:doctorId/book',
      name: AppRoutes.bookAppointment,
      builder: (_, state) {
        final draft = state.extra is AppointmentDraft
            ? state.extra! as AppointmentDraft
            : null;
        final id = state.pathParameters['doctorId']!;
        if (draft != null && draft.doctor.routeId == id) {
          return BookAppointmentScreen(draft: draft);
        }
        return DoctorProfileLoader(
          doctorId: id,
          builder: (profile) =>
              BookAppointmentScreen(draft: AppointmentDraft(doctor: profile)),
        );
      },
    ),
    GoRoute(
      path: '/appointments/:doctorId/date-time',
      name: AppRoutes.appointmentDateTime,
      redirect: (_, state) => _bookingRedirect(state),
      builder: (_, state) =>
          AppointmentDateTimeScreen(draft: state.extra! as AppointmentDraft),
    ),
    GoRoute(
      path: '/appointments/:doctorId/payment',
      name: AppRoutes.appointmentPayment,
      redirect: (_, state) => _bookingRedirect(state, requireSchedule: true),
      builder: (_, state) =>
          AppointmentPaymentScreen(draft: state.extra! as AppointmentDraft),
    ),
    GoRoute(
      path: '/appointments/:doctorId/confirmation',
      name: AppRoutes.appointmentConfirmation,
      redirect: (_, state) => _bookingRedirect(state, requireSchedule: true),
      builder: (_, state) => AppointmentConfirmationScreen(
        draft: state.extra! as AppointmentDraft,
      ),
    ),
    GoRoute(
      path: '/consultation/chat',
      name: AppRoutes.chat,
      builder: (_, _) => const ChatListScreen(),
    ),
    GoRoute(
      path: '/consultation/video',
      name: AppRoutes.video,
      builder: (_, _) => const VideoOnboardingScreen(),
    ),
  ],
  errorBuilder: (_, _) => const _RouteNotFound(message: 'Page not found'),
);

class _RouteNotFound extends StatelessWidget {
  const _RouteNotFound({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          TextButton(
            onPressed: () => context.goNamed(AppRoutes.home),
            child: const Text('Go to home'),
          ),
        ],
      ),
    ),
  );
}

// Drafts are local UI state. A refreshed later-step URL restarts booking until
// persisted appointment data is available from the backend.
String? _bookingRedirect(GoRouterState state, {bool requireSchedule = false}) {
  final draft = state.extra;
  if (draft is! AppointmentDraft ||
      draft.doctor.routeId != state.pathParameters['doctorId'] ||
      (requireSchedule && draft.scheduledAt == null)) {
    return '/appointments/${state.pathParameters['doctorId']}/book';
  }
  return null;
}
