import 'package:flutter/material.dart';
import 'presentation/models/portal_patient.dart';

/// Shared preview state for the portal tabs; connect to repositories later.
final doctorPortal = PortalController();

class PortalController extends ChangeNotifier {
  final today = DateUtils.dateOnly(DateTime.now());
  late DateTime selectedDate = today;
  final Set<DateTime> _unavailableDates = {};
  String name = 'Dr. Emily Carter';
  String specialty = 'Internal Medicine';
  String hospital = 'Riverside Medical Center';
  String location = 'San Francisco, CA';
  String about =
      'Board certified internist with 10+ years of experience in preventive care and chronic condition management. Passionate about patient-centered, accessible healthcare.';
  String qualifications =
      'MD, Internal Medicine\nStanford University School of Medicine';
  String languages = 'English (Native), Spanish (Conversational)';
  String fees = r'$49 (Chat)   $79 (Video)   $99 (In-person)';
  final patients = <PortalPatient>[
    const PortalPatient(
      id: 'sarah',
      name: 'Sarah Johnson',
      age: 25,
      reason: 'Follow-up care',
      symptoms: 'Persistent headache and fatigue',
      time: TimeOfDay(hour: 10, minute: 0),
      type: PortalConsultation.video,
      priority: PatientPriority.high,
    ),
    const PortalPatient(
      id: 'michael',
      name: 'Michael Chen',
      age: 34,
      reason: 'Anxiety',
      symptoms: 'Work-related stress and sleep issues',
      time: TimeOfDay(hour: 10, minute: 30),
      type: PortalConsultation.chat,
      priority: PatientPriority.medium,
    ),
    const PortalPatient(
      id: 'priya',
      name: 'Priya Sharma',
      age: 28,
      reason: 'Skin condition',
      symptoms: 'Rash on arms, seeking advice',
      time: TimeOfDay(hour: 11, minute: 15),
      type: PortalConsultation.video,
    ),
    const PortalPatient(
      id: 'daniel',
      name: 'Daniel Kim',
      age: 42,
      reason: 'Diabetes',
      symptoms: 'Medication refill and consultation',
      time: TimeOfDay(hour: 11, minute: 45),
      type: PortalConsultation.chat,
    ),
    const PortalPatient(
      id: 'james',
      name: 'James Wilson',
      age: 51,
      reason: 'Routine checkup',
      symptoms: 'Annual health review',
      time: TimeOfDay(hour: 14, minute: 0),
      type: PortalConsultation.inPerson,
      status: QueueStatus.ongoing,
    ),
    const PortalPatient(
      id: 'emma',
      name: 'Emma Brown',
      age: 30,
      reason: 'Follow-up care',
      symptoms: 'Recovery review',
      time: TimeOfDay(hour: 8, minute: 0),
      type: PortalConsultation.video,
      status: QueueStatus.completed,
    ),
    const PortalPatient(
      id: 'oliver',
      name: 'Oliver Jones',
      age: 45,
      reason: 'General health',
      symptoms: 'Preventive care',
      time: TimeOfDay(hour: 8, minute: 30),
      type: PortalConsultation.chat,
      status: QueueStatus.completed,
    ),
    const PortalPatient(
      id: 'ava',
      name: 'Ava Davis',
      age: 26,
      reason: 'Follow-up care',
      symptoms: 'Treatment review',
      time: TimeOfDay(hour: 8, minute: 45),
      type: PortalConsultation.video,
      status: QueueStatus.completed,
    ),
  ];

  int count(QueueStatus status) =>
      patients.where((patient) => patient.status == status).length;
  bool availableOn(DateTime date) =>
      !_unavailableDates.contains(DateUtils.dateOnly(date));
  bool get available => availableOn(selectedDate);
  PortalPatient? get nextPatient {
    final waiting = patients.where(
      (patient) => patient.status == QueueStatus.waiting,
    );
    return waiting.isEmpty ? null : waiting.first;
  }

  void selectDate(DateTime date) {
    selectedDate = DateUtils.dateOnly(date);
    notifyListeners();
  }

  void setAvailable(bool value) {
    if (value) {
      _unavailableDates.remove(selectedDate);
    } else {
      _unavailableDates.add(selectedDate);
    }
    notifyListeners();
  }

  void setStatus(String id, QueueStatus status) {
    final index = patients.indexWhere((patient) => patient.id == id);
    if (index >= 0) {
      patients[index] = patients[index].withStatus(status);
    }
    notifyListeners();
  }

  PortalPatient? patientById(String id) {
    for (final patient in patients) {
      if (patient.id == id) return patient;
    }
    return null;
  }

  PortalPatient? bookingAt(TimeOfDay time) {
    if (selectedDate == today) {
      for (final patient in patients) {
        if (patient.time == time) return patient;
      }
    }
    return null;
  }

  void updateProfile({
    required String doctorName,
    required String doctorSpecialty,
  }) {
    name = doctorName;
    specialty = doctorSpecialty;
    notifyListeners();
  }

  void updateDetail(String field, String value) {
    switch (field) {
      case 'About':
        about = value;
      case 'Qualifications':
        qualifications = value;
      case 'Languages':
        languages = value;
      case 'Consultation Fee':
        fees = value;
    }
    notifyListeners();
  }
}
