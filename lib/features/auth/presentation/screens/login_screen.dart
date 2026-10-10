import 'package:care_match/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/shared/widgets/brand_header.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../widgets/auth_heading.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_social_options.dart';
import '../widgets/auth_footer.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                const SizedBox(height: AppSpacing.lg),
                const AuthHeading(
                  title: 'Welcome back',
                  subtitle:
                      'Log in to continue your care journey\nand access personalized support.',
                ),
                Image.asset(
                  'assets/images/login_hero.png',
                  height: 20.h.clamp(120.0, 220.0),
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
                const AuthTextField(
                  hint: 'Email or phone number',
                  icon: Icons.mail_outline_rounded,
                  autofillHints: [AutofillHints.username],
                ),
                const SizedBox(height: AppSpacing.sm),
                const AuthTextField(
                  hint: 'Password',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  autofillHints: [AutofillHints.password],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: route to password recovery.
                    },
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AuthPrimaryButton(
                  label: 'Log in',
                  onPressed: () {
                    // TODO: authenticate before entering the home screen.
                    context.goNamed(AppRoutes.home);
                  },
                ),
                const AuthSocialOptions(),
                const SizedBox(height: AppSpacing.sm),
                AuthFooter(
                  prompt: "Don’t have an account?",
                  action: 'Sign up',
                  onPressed: () {
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
