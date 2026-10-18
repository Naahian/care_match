import 'package:care_match/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../widgets/auth_error_message.dart';
import 'package:sizer/sizer.dart';
import '../widgets/auth_heading.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_security_notice.dart';
import '../widgets/otp_code_field.dart';

class VerifyNumberScreen extends ConsumerStatefulWidget {
  const VerifyNumberScreen({super.key, this.phoneNumber = '+1 987 654 3210'});
  final String phoneNumber;

  @override
  ConsumerState<VerifyNumberScreen> createState() => _VerifyNumberScreenState();
}

class _VerifyNumberScreenState extends ConsumerState<VerifyNumberScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _navigated = false;
  String _code = '';

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authControllerProvider);
    if (auth.codeSent && auth.phoneNumber == widget.phoneNumber) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _seconds = 24;
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

  void _continue() {
    if (_navigated || !mounted) return;
    _navigated = true;
    context.goNamed(AppRoutes.setUpProfile, extra: false);
  }

  Future<void> _verify() async {
    if (await ref.read(authControllerProvider.notifier).verifySmsCode(_code)) {
      _continue();
    }
  }

  Future<void> _resend() async {
    final auth = ref.read(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    if (auth.phoneNumber == widget.phoneNumber) {
      await controller.resendPhoneCode();
    } else {
      await controller.requestPhoneCode(
        phoneNumber: widget.phoneNumber,
        linkToCurrentUser: auth.isAuthenticated,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final hasCode = auth.codeSent && auth.phoneNumber == widget.phoneNumber;
    ref.listen(authControllerProvider, (previous, next) {
      if (next.codeSent &&
          next.phoneNumber == widget.phoneNumber &&
          (previous?.codeSent != true ||
              previous?.verificationId != next.verificationId)) {
        setState(_startCountdown);
      }
      if (!next.isLoading &&
          next.errorMessage == null &&
          next.user?.phoneNumber == widget.phoneNumber) {
        _continue();
      }
    });
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.read(authControllerProvider.notifier).clearPhoneVerification();
        }
      },
      child: Scaffold(
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
                      subtitle: hasCode
                          ? 'We’ve sent a 6-digit code to\n${widget.phoneNumber}'
                          : 'Request a verification code for\n${widget.phoneNumber}',
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
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        TextButton(
                          onPressed: _seconds == 0 && !auth.isLoading
                              ? _resend
                              : null,
                          child: const Text('Resend'),
                        ),
                      ],
                    ),
                    AuthErrorMessage(message: auth.errorMessage),
                    const SizedBox(height: AppSpacing.lg),
                    AuthPrimaryButton(
                      label: 'Verify & continue',
                      isLoading: auth.pendingAction == AuthAction.verifyCode,
                      onPressed:
                          hasCode &&
                              !auth.isLoading &&
                              _code.length == AppConstants.otpLength
                          ? _verify
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: auth.isLoading
                          ? null
                          : () {
                              ref
                                  .read(authControllerProvider.notifier)
                                  .clearPhoneVerification();
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
      ),
    );
  }
}
