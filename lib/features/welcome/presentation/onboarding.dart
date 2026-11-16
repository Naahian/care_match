import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/brand_header.dart';
import 'widgets/consultation_illustration.dart';
import 'widgets/final_controls.dart';
import 'widgets/final_page.dart';
import 'widgets/privacy_illustration.dart';
import 'widgets/standard_controls.dart';
import 'widgets/standard_page.dart';
import 'widgets/symptom_illustration.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onGetStarted,
    required this.onLogin,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _pageCount = 4;

  final PageController _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pageCount - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    _controller.nextPage(
      duration: AppConstants.animationDuration,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: BrandHeader(compact: true),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _index = i),
                    children: const [
                      StandardPage(
                        title: 'Describe your\nsymptoms',
                        description:
                            'Tell us what you\u2019re experiencing, and our AI '
                            'will match you with the right doctor \u2014 near you.',
                        imageAsset: 'assets/images/welcome_2.png',
                        illustration: SymptomIllustration(),
                      ),
                      StandardPage(
                        title: 'Consult via\nchat or video',
                        description:
                            'Get expert advice, ask questions, and get '
                            'personalized guidance \u2014 all from the comfort '
                            'of your home.',
                        imageAsset: 'assets/images/welcome_1.png',
                        illustration: ConsultationIllustration(),
                      ),
                      StandardPage(
                        title: 'Your health data\nstays private',
                        description:
                            'CareMatch uses your information to support your care. '
                            'Your privacy matters to us.',
                        imageAsset: 'assets/images/welcome_3.png',
                        illustration: PrivacyIllustration(
                          imageAsset: 'assets/images/welcome_3.png',
                        ),
                      ),
                      FinalPage(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    _isLast ? AppSpacing.md : AppSpacing.xxl - AppSpacing.xs,
                  ),
                  child: _isLast
                      ? FinalControls(
                          index: _index,
                          count: _pageCount,
                          onGetStarted: widget.onGetStarted,
                          onLogin: widget.onLogin,
                        )
                      : StandardControls(
                          index: _index,
                          count: _pageCount,
                          onNext: _next,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
