import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_logo.dart';
import '../../../../core/widgets/diah_widgets.dart';

/// First-run language picker — English / Arabic / French available at launch.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              const Center(child: DiahLogo(size: 110)),
              const SizedBox(height: 20),
              Text(
                'Diah',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  color: DiahColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.t(
                  'اختاري لغتك',
                  'Choisissez votre langue',
                  'Choose your language',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: DiahColors.textMuted,
                ),
              ),
              const SizedBox(height: 36),
              _LangOption(
                flagLabel: 'EN',
                title: 'English',
                subtitle: 'Continue in English',
                selected: locale == AppLocale.en,
                onTap: () => ref
                    .read(localeProvider.notifier)
                    .setLocale(AppLocale.en),
              ),
              const SizedBox(height: 12),
              _LangOption(
                flagLabel: 'ع',
                title: 'العربية',
                subtitle: 'المتابعة بالعربية',
                selected: locale == AppLocale.ar,
                onTap: () => ref
                    .read(localeProvider.notifier)
                    .setLocale(AppLocale.ar),
              ),
              const SizedBox(height: 12),
              _LangOption(
                flagLabel: 'FR',
                title: 'Français',
                subtitle: 'Continuer en français',
                selected: locale == AppLocale.fr,
                onTap: () => ref
                    .read(localeProvider.notifier)
                    .setLocale(AppLocale.fr),
              ),
              const Spacer(flex: 2),
              PrimaryButton(
                label: s.continueText,
                onPressed: () => context.go('/onboarding'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.flagLabel,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String flagLabel;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? DiahColors.softLavender : DiahColors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? DiahColors.primary
                  : DiahColors.border.withValues(alpha: 0.8),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: selected
                    ? DiahColors.primary
                    : DiahColors.softLavender,
                child: Text(
                  flagLabel,
                  style: TextStyle(
                    color: selected ? Colors.white : DiahColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: DiahColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: DiahColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
