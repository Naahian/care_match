import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class PortalEditDialog extends StatefulWidget {
  const PortalEditDialog({
    super.key,
    required this.title,
    required this.fields,
  });
  final String title;
  final Map<String, String> fields;

  @override
  State<PortalEditDialog> createState() => _PortalEditDialogState();
}

class _PortalEditDialogState extends State<PortalEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controllers = widget.fields.map(
    (key, value) => MapEntry(key, TextEditingController(text: value)),
  );
  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in _controllers.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: TextFormField(
                  controller: entry.value,
                  decoration: InputDecoration(labelText: entry.key),
                  minLines: 1,
                  maxLines: 4,
                  maxLength: 500,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter ${entry.key.toLowerCase()}.'
                      : null,
                ),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.pop(
              context,
              _controllers.map(
                (key, value) => MapEntry(key, value.text.trim()),
              ),
            );
          }
        },
        child: const Text('Save'),
      ),
    ],
  );
}
