import 'package:care_match/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../widgets/auth_heading.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_security_notice.dart';
import '../widgets/otp_code_field.dart';

class VerifyNumberScreen extends StatefulWidget {
  const VerifyNumberScreen({super.key, this.phoneNumber = '+1 987 654 3210'});
  final String phoneNumber;

  @override
  State<VerifyNumberScreen> createState() => _VerifyNumberScreenState();
}

class _VerifyNumberScreenState extends State<VerifyNumberScreen> {
  Timer? _timer;
  int _seconds = 24;
  String _code = '';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds <= 1) timer.cancel();
      setState(() => _seconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: AppSpacing.page,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // TODO: add the phone verification illustration.
                SizedBox(height: 26.h.clamp(140.0, 260.0)),
                AuthHeading(
                  title: 'Verify your number',
                  subtitle:
                      'We’ve sent a 6-digit code to\n${widget.phoneNumber}',
                ),
                const SizedBox(height: AppSpacing.lg),
                OtpCodeField(
                  onChanged: (value) => setState(() => _code = value),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.md,
                  children: [
                    Text(
                      _seconds > 0
                          ? 'Resend code in 00:${_seconds.toString().padLeft(2, '0')}'
                          : 'Didn’t receive a code?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: _seconds == 0
                          ? () {
                              // TODO: request another OTP for widget.phoneNumber.
                              setState(() => _seconds = 24);
                              _startCountdown();
                            }
                          : null,
                      child: const Text('Resend'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AuthPrimaryButton(
                  label: 'Verify & continue',
                  onPressed: _code.length == AppConstants.otpLength
                      ? () {
                          // TODO: verify the code with the backend before navigating.
                          context.pushNamed(AppRoutes.setUpProfile);
                        }
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed(AppRoutes.createAccount);
                    }
                  },
                  child: const Text('Change number'),
                ),
                const SizedBox(height: AppSpacing.xl),
                const AuthSecurityNotice(),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
