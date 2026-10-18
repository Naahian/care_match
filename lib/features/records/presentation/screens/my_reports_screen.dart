import 'package:care_match/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My Reports')),
    body: const SafeArea(
      child: EmptyState(
        icon: Icons.description_outlined,
        message: 'Feature coming soon',
      ),
    ),
  );
}
