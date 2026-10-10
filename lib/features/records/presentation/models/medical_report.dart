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

final sampleReports = [
  MedicalReport(
    title: 'CBC Blood Test',
    doctor: 'Dr. Emily Carter',
    date: DateTime(2024, 1, 12),
    category: ReportCategory.lab,
    size: '2.1 MB',
  ),
  MedicalReport(
    title: 'Chest X-ray',
    doctor: 'Dr. James Patel',
    date: DateTime(2023, 12, 3),
    category: ReportCategory.imaging,
    size: '3.4 MB',
  ),
  MedicalReport(
    title: 'Prescription',
    doctor: 'Dr. Emily Carter',
    date: DateTime(2023, 11, 18),
    category: ReportCategory.prescriptions,
    size: '1.1 MB',
  ),
  MedicalReport(
    title: 'Thyroid Panel',
    doctor: 'Dr. Sophia Nguyen',
    date: DateTime(2023, 10, 20),
    category: ReportCategory.lab,
    size: '2.8 MB',
  ),
];
