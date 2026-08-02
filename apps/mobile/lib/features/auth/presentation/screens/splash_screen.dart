import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) context.go('/language');
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFE8DFEC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const DiahLogo(size: 160)
                .animate()
                .fadeIn(duration: 700.ms)
                .scale(begin: const Offset(0.88, 0.88)),
            const SizedBox(height: 28),
            Text(
              s.tagline,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: DiahColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(delay: 350.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
