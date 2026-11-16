import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../domain/entities/payment_checkout.dart';

class PaymentBillingForm extends StatefulWidget {
  const PaymentBillingForm({
    super.key,
    required this.enabled,
    this.name,
    this.email,
    this.phone,
  });
  final bool enabled;
  final String? name, email, phone;
  @override
  State<PaymentBillingForm> createState() => PaymentBillingFormState();
}

class PaymentBillingFormState extends State<PaymentBillingForm> {
  final _form = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _fields = {
    'Name': TextEditingController(text: widget.name),
    'Email': TextEditingController(text: widget.email),
    'Phone': TextEditingController(text: widget.phone),
    'Address': TextEditingController(),
    'City': TextEditingController(),
    'Postcode': TextEditingController(),
  };

  @override
  void didUpdateWidget(covariant PaymentBillingForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final entry in {
      'Name': widget.name,
      'Email': widget.email,
      'Phone': widget.phone,
    }.entries) {
      if (_fields[entry.key]!.text.isEmpty && entry.value != null) {
        _fields[entry.key]!.text = entry.value!;
      }
    }
  }

  BillingDetails? validate() {
    if (_form.currentState?.validate() != true) return null;
    String value(String key) => _fields[key]!.text.trim();
    return BillingDetails(
      name: value('Name'),
      email: value('Email'),
      phone: value('Phone'),
      address: value('Address'),
      city: value('City'),
      postcode: value('Postcode'),
    );
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _field(BuildContext context, String name) {
    final field = MapEntry(name, _fields[name]!);
    final limit = name == 'Phone'
        ? 20
        : name == 'Postcode'
        ? 30
        : 50;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(name, style: theme.textTheme.labelSmall)),
            ValueListenableBuilder(
              valueListenable: field.value,
              builder: (_, value, _) => Text(
                '${value.text.characters.length} / $limit',
                style: theme.textTheme.labelSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: field.value,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: name,
            counterText: '',
            fillColor: theme.scaffoldBackgroundColor,
            enabledBorder: const OutlineInputBorder(
              borderRadius: AppRadius.button,
              borderSide: BorderSide.none,
            ),
          ),
          maxLength: limit,
          keyboardType: switch (field.key) {
            'Email' => TextInputType.emailAddress,
            'Phone' => TextInputType.phone,
            'Postcode' => TextInputType.text,
            _ => TextInputType.streetAddress,
          },
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) return 'Enter your ${field.key.toLowerCase()}';
            if (field.key == 'Email' &&
                !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) {
              return 'Enter a valid email';
            }
            if (field.key == 'Phone' && text.length < 6) {
              return 'Enter a valid phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _form,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Billing details', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: AppSpacing.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final name in ['Name', 'Email', 'Phone', 'Address']) ...[
                  _field(context, name),
                  const SizedBox(height: 20),
                ],
                if (MediaQuery.textScalerOf(context).scale(14) > 19) ...[
                  _field(context, 'City'),
                  const SizedBox(height: 16),
                  _field(context, 'Postcode'),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _field(context, 'City')),
                      const SizedBox(width: 12),
                      Expanded(child: _field(context, 'Postcode')),
                    ],
                  ),
                const SizedBox(height: 20),
                const Text('Country: Bangladesh'),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
