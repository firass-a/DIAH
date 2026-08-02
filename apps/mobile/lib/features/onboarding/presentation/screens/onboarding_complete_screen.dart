import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_widgets.dart';

class OnboardingCompleteScreen extends ConsumerStatefulWidget {
  const OnboardingCompleteScreen({super.key, this.nextRoute = '/home'});

  final String nextRoute;

  @override
  ConsumerState<OnboardingCompleteScreen> createState() =>
      _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState
    extends ConsumerState<OnboardingCompleteScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) context.go(widget.nextRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: DiahColors.softLavender,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: DiahColors.primary.withValues(alpha: 0.2),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 56,
                  color: DiahColors.primary,
                ),
              )
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.easeOutBack)
                  .fadeIn(),
              const SizedBox(height: 28),
              Text(
                s.t(
                  'اكتمل ملفكِ!',
                  'Profil complété !',
                  'Profile completed!',
                ),
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 34,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 12),
              Text(
                s.t(
                  'مرحباً بكِ في دياه — جاري توجيهك إلى تجربتك',
                  'Bienvenue sur Diah — redirection…',
                  'Welcome to Diah — taking you to your experience…',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: DiahColors.textMuted,
                  height: 1.45,
                ),
              ).animate().fadeIn(delay: 350.ms),
              const Spacer(),
              PrimaryButton(
                label: s.continueText,
                onPressed: () => context.go(widget.nextRoute),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
