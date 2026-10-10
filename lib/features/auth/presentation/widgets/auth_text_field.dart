import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.hint,
    required this.icon,
    this.label,
    this.isPassword = false,
    this.keyboardType,
    this.autofillHints,
    this.prefix,
    this.validator,
    this.controller,
  });
  final String hint;
  final String? label;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final Widget? prefix;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final border = OutlineInputBorder(
      borderRadius: AppRadius.card,
      borderSide: BorderSide(color: scheme.outlineVariant),
    );
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && !_visible,
      keyboardType: widget.keyboardType,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      textInputAction: widget.isPassword
          ? TextInputAction.done
          : TextInputAction.next,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        fillColor: scheme.surface,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.primary),
        ),
        prefixIcon: Icon(widget.icon, color: scheme.onSurfaceVariant),
        prefix: widget.prefix,
        suffixIcon: widget.isPassword
            ? IconButton(
                tooltip: _visible ? 'Hide password' : 'Show password',
                onPressed: () => setState(() => _visible = !_visible),
                icon: Icon(
                  _visible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: scheme.onSurfaceVariant,
                ),
              )
            : null,
      ),
    );
  }
}
