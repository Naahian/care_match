import 'package:care_match/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/shared/widgets/brand_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../widgets/auth_validators.dart';
import '../widgets/auth_error_message.dart';
import 'package:sizer/sizer.dart';
import '../widgets/auth_heading.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_social_options.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_terms_checkbox.dart';
import '../widgets/doctor_registration_fields.dart';
import '../widgets/email_verification_dialog.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _doctorFields = GlobalKey<DoctorRegistrationFieldsState>();
  bool _isDoctor = false;
  bool _agreed = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_agreed || !_formKey.currentState!.validate()) return;
    final email = _email.text.trim();
    final succeeded = await ref
        .read(authControllerProvider.notifier)
        .signUp(
          email: email,
          password: _password.text,
          displayName: _name.text.trim(),
          doctorDetails: _isDoctor ? _doctorFields.currentState!.value : null,
        );
    if (!mounted || !succeeded) return;
    FocusScope.of(context).unfocus();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EmailVerificationDialog(email: email),
    );
    if (!mounted) return;
    context.goNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(title: BrandHeader(), centerTitle: true),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: AppSpacing.page,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/welcome_4.png',
                      height: 20.h.clamp(120.0, 220.0),
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                    const AuthHeading(
                      title: 'Create your account',
                      subtitle:
                          'Get started in minutes and take the first\nstep towards better, personalized care.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DropdownButtonFormField<bool>(
                      initialValue: _isDoctor,
                      decoration: const InputDecoration(
                        labelText: 'Account type',
                      ),
                      items: const [
                        DropdownMenuItem(value: false, child: Text('Patient')),
                        DropdownMenuItem(value: true, child: Text('Doctor')),
                      ],
                      onChanged: auth.isLoading
                          ? null
                          : (value) =>
                                setState(() => _isDoctor = value ?? false),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AuthTextField(
                      controller: _name,
                      enabled: !auth.isLoading,
                      validator: AuthValidators.name,
                      label: 'Full name',
                      hint: 'e.g. Sarah Johnson',
                      icon: Icons.person_outline_rounded,
                      autofillHints: [AutofillHints.name],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AuthTextField(
                      controller: _email,
                      enabled: !auth.isLoading,
                      validator: AuthValidators.email,
                      label: 'Email address',
                      hint: 'you@example.com',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: [AutofillHints.email],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AuthTextField(
                      controller: _password,
                      enabled: !auth.isLoading,
                      validator: AuthValidators.newPassword,
                      label: 'Password',
                      hint: 'Create a strong password',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      autofillHints: [AutofillHints.newPassword],
                    ),
                    if (_isDoctor)
                      DoctorRegistrationFields(
                        key: _doctorFields,
                        enabled: !auth.isLoading,
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    AuthTermsCheckbox(
                      value: _agreed,
                      onChanged: (value) =>
                          setState(() => _agreed = value ?? false),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AuthErrorMessage(message: auth.errorMessage),
                    AuthPrimaryButton(
                      label: 'Create account',
                      isLoading: auth.isLoading,
                      onPressed: _agreed && !auth.isLoading ? _submit : null,
                    ),

                    const SizedBox(height: AppSpacing.md),
                    const AuthSocialOptions(),
                    const SizedBox(height: AppSpacing.sm),
                    AuthFooter(
                      prompt: 'Already have an account?',
                      action: 'Log in',
                      onPressed: auth.isLoading
                          ? null
                          : () {
                              ref
                                  .read(authControllerProvider.notifier)
                                  .clearPhoneVerification();
                              context.goNamed(AppRoutes.login);
                            },
                    ),
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
