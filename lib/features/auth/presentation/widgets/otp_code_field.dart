import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One native input supports SMS autofill, paste, deletion and selection;
/// the cells provide the six-digit presentation without splitting input focus.
class OtpCodeField extends StatefulWidget {
  const OtpCodeField({super.key, required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        ExcludeSemantics(
          child: IgnorePointer(
            child: Row(
              children: List.generate(
                AppConstants.otpLength,
                (index) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: index == AppConstants.otpLength - 1
                          ? 0
                          : AppSpacing.sm,
                    ),
                    constraints: const BoxConstraints(minHeight: 60),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: AppRadius.input,
                      border: Border.all(
                        color:
                            _focusNode.hasFocus &&
                                index ==
                                    _controller.text.length.clamp(
                                      0,
                                      AppConstants.otpLength - 1,
                                    )
                            ? scheme.primary
                            : scheme.outlineVariant,
                      ),
                    ),
                    child: Text(
                      index < _controller.text.length
                          ? _controller.text[index]
                          : '',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            alwaysIncludeSemantics: true,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(AppConstants.otpLength),
              ],
              decoration: const InputDecoration(
                labelText: '6-digit verification code',
                counterText: '',
              ),
              onChanged: (value) {
                setState(() {});
                widget.onChanged(value);
              },
              onEditingComplete: () => _focusNode.unfocus(),
            ),
          ),
        ),
      ],
    );
  }
}
