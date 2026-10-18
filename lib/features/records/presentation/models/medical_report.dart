import 'package:flutter/material.dart';

enum ReportCategory {
  lab('Lab', 'Lab Report', Icons.science_outlined),
  imaging('Imaging', 'Imaging Report', Icons.monitor_heart_outlined),
  prescriptions('Prescriptions', 'Prescription', Icons.description_outlined);

  const ReportCategory(this.label, this.description, this.icon);
  final String label;
  final String description;
  final IconData icon;
}

class MedicalReport {
  const MedicalReport({
    required this.title,
    required this.doctor,
    required this.date,
    required this.category,
    required this.size,
  });
  final String title;
  final String doctor;
  final DateTime date;
  final ReportCategory category;
  final String size;
}
