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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final succeeded = await ref
        .read(authControllerProvider.notifier)
        .signIn(email: _email.text.trim(), password: _password.text);
    if (succeeded && mounted) context.goNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(title: BrandHeader(), centerTitle: true),
        body: SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: AppSpacing.page,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Image.asset(
                    'assets/images/login_hero.png',
                    height: 20.h.clamp(120.0, 220.0),
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  const AuthHeading(
                    title: 'Welcome back',
                    subtitle:
                        'Log in to continue your care journey\nand access personalized support.',
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  AuthTextField(
                    controller: _email,
                    enabled: !auth.isLoading,
                    validator: AuthValidators.email,
                    keyboardType: TextInputType.emailAddress,
                    hint: 'Email address',
                    icon: Icons.mail_outline_rounded,
                    autofillHints: [AutofillHints.username],
                  ),

                  const SizedBox(height: AppSpacing.sm),
                  AuthTextField(
                    controller: _password,
                    enabled: !auth.isLoading,
                    validator: AuthValidators.password,
                    hint: 'Password',
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    autofillHints: [AutofillHints.password],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: auth.isLoading
                          ? null
                          : () => context.pushNamed(AppRoutes.forgotPassword),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  AuthErrorMessage(message: auth.errorMessage),
                  const SizedBox(height: AppSpacing.md),
                  AuthPrimaryButton(
                    label: 'Log in',
                    isLoading: auth.pendingAction == AuthAction.signIn,
                    onPressed: auth.isLoading ? null : _submit,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const AuthSocialOptions(),
                  const SizedBox(height: AppSpacing.sm),
                  AuthFooter(
                    prompt: "Don’t have an account?",
                    action: 'Sign up',
                    onPressed: auth.isLoading
                        ? null
                        : () {
                            context.pushNamed(AppRoutes.createAccount);
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
}
