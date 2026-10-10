import 'package:care_match/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/shared/widgets/brand_header.dart';
import 'package:flutter/material.dart';
import '../widgets/auth_heading.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_social_options.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_terms_checkbox.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _agreed = false;
  String _dialCode = '+1';
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
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
                const SizedBox(height: AppSpacing.lg),
                const Center(
                  child: FittedBox(fit: BoxFit.scaleDown, child: BrandHeader()),
                ),
                const SizedBox(height: AppSpacing.xl),
                const AuthHeading(
                  title: 'Create your account',
                  subtitle:
                      'Get started in minutes and take the first\nstep towards better, personalized care.',
                ),
                const SizedBox(height: AppSpacing.lg),
                const AuthTextField(
                  label: 'Full name',
                  hint: 'e.g. Sarah Johnson',
                  icon: Icons.person_outline_rounded,
                  autofillHints: [AutofillHints.name],
                ),
                const SizedBox(height: AppSpacing.md),
                const AuthTextField(
                  label: 'Email address',
                  hint: 'you@example.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: [AutofillHints.email],
                ),
                const SizedBox(height: AppSpacing.md),
                AuthTextField(
                  label: 'Phone number',
                  controller: _phoneController,
                  hint: '987 654 3210',
                  icon: Icons.call_outlined,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumberNational],
                  prefix: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _dialCode,
                      isDense: true,
                      items: const ['+1', '+44', '+880']
                          .map(
                            (code) => DropdownMenuItem(
                              value: code,
                              child: Text(code),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _dialCode = value);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const AuthTextField(
                  label: 'Password',
                  hint: 'Create a strong password',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  autofillHints: [AutofillHints.newPassword],
                ),
                const SizedBox(height: AppSpacing.sm),
                AuthTermsCheckbox(
                  value: _agreed,
                  onChanged: (value) =>
                      setState(() => _agreed = value ?? false),
                ),
                const SizedBox(height: AppSpacing.md),
                AuthPrimaryButton(
                  label: 'Create account',
                  onPressed: _agreed
                      ? () {
                          // TODO: create the account and request an OTP before navigating.
                          context.pushNamed(
                            AppRoutes.verifyNumber,
                            queryParameters: {
                              'phone':
                                  '$_dialCode ${_phoneController.text.trim()}',
                            },
                          );
                        }
                      : null,
                ),
                const AuthSocialOptions(),
                const SizedBox(height: AppSpacing.md),
                AuthFooter(
                  prompt: 'Already have an account?',
                  action: 'Log in',
                  onPressed: () {
                    context.goNamed(AppRoutes.login);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
