import 'package:flutter/material.dart';

enum QueueStatus { waiting, ongoing, completed }

enum PatientPriority { high, medium, low }

enum PortalConsultation {
  video('Video consult', Icons.videocam_outlined),
  chat('Chat consult', Icons.chat_bubble_outline_rounded),
  inPerson('In-person consult', Icons.person_outline_rounded);

  const PortalConsultation(this.label, this.icon);
  final String label;
  final IconData icon;
}

class PortalPatient {
  const PortalPatient({
    required this.id,
    required this.name,
    required this.age,
    required this.reason,
    required this.symptoms,
    required this.time,
    required this.type,
    this.priority = PatientPriority.low,
    this.status = QueueStatus.waiting,
  });
  final String id;
  final String name;
  final int age;
  final String reason;
  final String symptoms;
  final TimeOfDay time;
  final PortalConsultation type;
  final PatientPriority priority;
  final QueueStatus status;

  PortalPatient withStatus(QueueStatus value) => PortalPatient(
    id: id,
    name: name,
    age: age,
    reason: reason,
    symptoms: symptoms,
    time: time,
    type: type,
    priority: priority,
    status: value,
  );
}
