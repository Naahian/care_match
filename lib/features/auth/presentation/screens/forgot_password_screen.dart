import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/brand_header.dart';
import '../../providers.dart';
import '../widgets/auth_error_message.dart';
import '../widgets/auth_heading.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_validators.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _submitted = false;
  String? _sentEmail;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (ref.read(authControllerProvider).isLoading ||
        !_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    final email = _email.text.trim();
    setState(() => _submitted = true);
    final succeeded = await ref
        .read(authControllerProvider.notifier)
        .resetPassword(email: email);
    if (succeeded && mounted) setState(() => _sentEmail = email);
  }

  void _backToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final sentEmail = _sentEmail;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: _backToLogin),
        title: const BrandHeader(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: AppSpacing.page,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Icon(
                    sentEmail == null
                        ? Icons.lock_reset_rounded
                        : Icons.mark_email_read_outlined,
                    size: AppSpacing.xxl,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (sentEmail == null) ...[
                    const AuthHeading(
                      title: 'Forgot password?',
                      subtitle:
                          'Enter your email address and we’ll send you a link to reset your password.',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Form(
                      key: _formKey,
                      child: AuthTextField(
                        controller: _email,
                        enabled: !auth.isLoading,
                        label: 'Email address',
                        hint: 'Enter your email address',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        validator: AuthValidators.email,
                        textInputAction: TextInputAction.send,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                    ),
                    AuthErrorMessage(
                      message: _submitted ? auth.errorMessage : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AuthPrimaryButton(
                      label: 'Send reset link',
                      isLoading: auth.pendingAction == AuthAction.resetPassword,
                      onPressed: auth.isLoading ? null : _submit,
                    ),
                  ] else ...[
                    Semantics(
                      liveRegion: true,
                      child: AuthHeading(
                        title: 'Check your inbox',
                        subtitle:
                            'If an account exists for $sentEmail, you’ll receive a password reset link. Check your spam folder too.',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextButton(
                      onPressed: () => setState(() {
                        _sentEmail = null;
                        _submitted = false;
                      }),
                      child: const Text('Use another email'),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: _backToLogin,
                    child: const Text('Back to log in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
